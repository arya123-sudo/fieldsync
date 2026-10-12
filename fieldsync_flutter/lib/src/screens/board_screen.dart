import 'dart:async';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fieldsync_client/fieldsync_client.dart';

import '../sync/demo_ids.dart';
import '../sync/sync_service.dart';

// ── Design tokens ──────────────────────────────────────────────
const _sidebarBg = Color(0xFF161D33);
const _sidebarFg = Color(0xFFE8ECF5);
const _sidebarMuted = Color(0xFF8E97B8);
const _pageBg = Color(0xFFF3F5FA);
const _ink = Color(0xFF161D33);
const _inkSoft = Color(0xFF626B8A);
const _accent = Color(0xFF4F6DF5);
const _online = Color(0xFF16A34A);
const _offline = Color(0xFFDC2626);
const _amber = Color(0xFFD97706);

// Pairs a TaskEvent with its parent task's title for the activity feed.
class _ActivityItem {
  _ActivityItem({required this.event, required this.taskTitle});
  final TaskEvent event;
  final String taskTitle;
}

class BoardScreen extends StatefulWidget {
  final Client client;
  const BoardScreen({super.key, required this.client});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  late final SyncService _sync;
  bool _ready = false;
  String? _error;
  bool _isSupervisor = true;
  int _navIndex = 0; // 0 = board, 1 = team, 2 = activity
  List<Task> _tasks = [];
  Timer? _refreshTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _syncing = false;
  DateTime? _lastSynced;
  final Map<String, Uint8List> _pendingPhotos = {};
  final Map<String, UuidValue> _eventTask = {};

  UuidValue get _me => _isSupervisor ? demoSupervisorId : demoWorkerId;

  @override
  void initState() {
    super.initState();
    _sync = SyncService(widget.client);
    _boot();
    _connectivitySub =
        Connectivity().onConnectivityChanged.listen(_onConnectivity);
    _refreshTimer =
        Timer.periodic(const Duration(seconds: 3), (_) => _reload());
  }

  Future<void> _boot() async {
    try {
      final conn = await Connectivity().checkConnectivity();
      _sync.online = !conn.contains(ConnectivityResult.none);
      await _sync.init(me: demoSupervisorId);
      _sync.startStreaming();
      setState(() => _ready = true);
      unawaited(_restoreAndUploadPendingPhotos());
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _reload() async {
    if (!_ready && _error == null) return;
    try {
      final tasks =
          await _sync.fetchTasks().timeout(const Duration(seconds: 8));
      if (mounted) setState(() => _tasks = tasks);
    } catch (_) {}
  }

  Future<void> _restoreAndUploadPendingPhotos() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      await _restorePendingPhotos();
      if (_sync.online) await _uploadPendingPhotos();
      await _reload();
    } catch (_) {}
  }

  Future<void> _onConnectivity(List<ConnectivityResult> results) async {
    final nowOnline = !results.contains(ConnectivityResult.none);
    final wasOffline = !_sync.online;
    _sync.online = nowOnline;
    if (nowOnline && wasOffline) {
      setState(() => _syncing = true);
      try {
        await _uploadPendingPhotos();
        await _sync.syncOnce();
        _sync.pendingWrites = 0;
        _lastSynced = DateTime.now();
      } catch (e) {
        _error = 'Sync failed: $e';
      }
      setState(() => _syncing = false);
      await _reload();
    }
    if (mounted) setState(() {});
  }

  Future<void> _uploadPendingPhotos() async {
    for (final entry in _pendingPhotos.entries.toList()) {
      final eventKey = entry.key;
      final bytes = entry.value;
      final taskId = _eventTask[eventKey];
      if (taskId == null) continue;
      final url = await widget.client.task.uploadEvidencePhoto(
        bytes.buffer.asByteData(),
        'photo_$eventKey.jpg',
      );
      final events = await _sync.fetchEvents(taskId);
      for (final ev in events) {
        if (ev.kind == 'photo_pending' &&
            ev.message.startsWith('$eventKey|')) {
          ev.kind = 'photo';
          ev.message = url;
          await _sync.updateEvent(ev);
          break;
        }
      }
      _pendingPhotos.remove(eventKey);
      _eventTask.remove(eventKey);
      await _sync.clearPendingPhoto(eventKey);
    }
  }

  Future<void> _restorePendingPhotos() async {
    final tasks = await _sync.fetchTasks();
    for (final task in tasks) {
      final taskId = task.id;
      if (taskId == null) continue;
      final events = await _sync.fetchEvents(taskId);
      for (final event in events) {
        if (event.kind != 'photo_pending') continue;
        final eventKey = event.message.split('|').first;
        final bytes = await _sync.loadPendingPhoto(eventKey);
        if (bytes == null) continue;
        _pendingPhotos[eventKey] = bytes;
        _eventTask[eventKey] = taskId;
      }
    }
  }

  Future<void> _assignTask() async {
    final titleCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final minutesCtrl = TextEditingController(text: '30');
    final formKey = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assign task'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    key: const ValueKey('task_title'),
                    controller: titleCtrl,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText:
                          'Title (e.g. Inspect transformer #42)',
                    ),
                    validator: (v) => (v == null ||
                            v.trim().isEmpty)
                        ? 'Required'
                        : null,
                  ),
                  TextFormField(
                    key: const ValueKey('task_notes'),
                    controller: notesCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Notes (optional)'),
                  ),
                  TextFormField(
                    key: const ValueKey(
                        'task_escalation_minutes'),
                    controller: minutesCtrl,
                    decoration: const InputDecoration(
                      labelText:
                          'Escalate if not started within (minutes)',
                      hintText: 'Use 2 for the demo',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const ValueKey('submit_task'),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final title = titleCtrl.text.trim();
    try {
      await widget.client.task.createTask(
        title: title,
        assigneeId: demoWorkerId,
        notes: notesCtrl.text.trim().isEmpty
            ? null
            : notesCtrl.text.trim(),
        teamSpaceId: _sync.teamSpaceId!,
        actorId: _me,
        escalationAfterMinutes:
            int.tryParse(minutesCtrl.text) ?? 30,
      );
    } catch (e) {
      // Known issue on the deployed server: createTask succeeds
      // server-side but the client fails to decode the response.
      // Fall through and verify via the sync layer instead.
    }
    await _reload();
    // The new task may take a moment to arrive via the sync stream —
    // poll briefly before deciding it failed.
    var created = _tasks.any((t) => t.title == title);
    for (var i = 0; i < 5 && !created; i++) {
      await Future.delayed(const Duration(seconds: 1));
      await _reload();
      created = _tasks.any((t) => t.title == title);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          created ? 'Task assigned' : 'Assign failed — try again',
        ),
      ),
    );
  }

  Future<void> _setStatus(
      Task task, String status, String eventKind) async {
    task.status = status;
    await _sync.updateTask(task);
    await _sync.addEvent(
      taskId: task.id!,
      kind: eventKind,
      message: 'Status → $status',
    );
    await _reload();
  }

  Future<void> _addNote(Task task) async {
    final ctrl = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add note'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
              hintText: 'e.g. Voltage: 231V'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (text == null || text.isEmpty) return;
    await _sync.addEvent(
        taskId: task.id!, kind: 'note', message: text);
    await _reload();
  }

  Future<void> _attachPhoto(Task task) async {
    final XFile? picked = await ImagePicker()
        .pickImage(source: ImageSource.camera);
    final XFile? file = picked ??
        await ImagePicker()
            .pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (_sync.online) {
      try {
        final url =
            await widget.client.task.uploadEvidencePhoto(
          bytes.buffer.asByteData(),
          file.name,
        );
        await _sync.addEvent(
            taskId: task.id!, kind: 'photo', message: url);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: $e')),
          );
        }
        return;
      }
    } else {
      final eventKey = UniqueKey().toString();
      await _sync.savePendingPhoto(eventKey, bytes);
      _eventTask[eventKey] = task.id!;
      _pendingPhotos[eventKey] = bytes;
      await _sync.addEvent(
        taskId: task.id!,
        kind: 'photo_pending',
        message: '$eventKey|${file.name}',
      );
    }
    await _reload();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _connectivitySub?.cancel();
    _sync.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────

  Color _statusColor(String s) => switch (s) {
        'completed' => const Color(0xFF16A34A),
        'in_progress' => const Color(0xFF2563EB),
        'escalated' => const Color(0xFFDC2626),
        'overdue' => const Color(0xFFD97706),
        _ => const Color(0xFF64748B),
      };

  String _statusLabel(String s) => switch (s) {
        'in_progress' => 'In Progress',
        _ => s.replaceAll('_', ' ').split(' ').map((w) =>
            w.isEmpty
                ? w
                : '${w[0].toUpperCase()}${w.substring(1)}').join(' '),
      };

  /// Priority derived from urgency — no model change needed.
  String _priority(Task t) => switch (t.status) {
        'escalated' || 'overdue' => 'High',
        'in_progress' => 'Medium',
        _ => 'Low',
      };

  Color _priorityColor(String p) => switch (p) {
        'High' => const Color(0xFFDC2626),
        'Medium' => const Color(0xFFD97706),
        _ => const Color(0xFF16A34A),
      };

  Color _priorityBg(String p) => switch (p) {
        'High' => const Color(0xFFFDECEC),
        'Medium' => const Color(0xFFFEF3E2),
        _ => const Color(0xFFE8F7EE),
      };

  String _fmtTime(DateTime t) {
    final l = t.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  String _assigneeName(UuidValue? id) {
    if (id == demoWorkerId) return 'Field Worker';
    if (id == demoSupervisorId) return 'Supervisor';
    return 'Unassigned';
  }

  // ── Sidebar ────────────────────────────────────────────────

  Widget _buildSidebar() {
    return Container(
      width: 264,
      color: _sidebarBg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _accent,
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                    child: const Icon(
                        Icons.sync_rounded,
                        color: Colors.white,
                        size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text('FieldSync',
                          style: TextStyle(
                              color: _sidebarFg,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3)),
                      Text(
                          'Work anywhere. Sync everything.',
                          style: TextStyle(
                              color: _sidebarMuted,
                              fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 20),
              child: Text('WORKSPACE',
                  style: TextStyle(
                      color: _sidebarMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2)),
            ),
            const SizedBox(height: 6),
            _navItem(
                Icons.dashboard_outlined,
                'Task board',
                0),
            _navItem(Icons.group_outlined, 'Team',
                1),
            _navItem(Icons.history_outlined,
                'Activity', 2),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white
                      .withValues(alpha: 0.08),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _roleChip(
                        true,
                        Icons
                            .manage_accounts_outlined,
                        'Supervisor'),
                    _roleChip(false,
                        Icons.handyman_outlined,
                        'Worker'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Connection status footer — offline-first highlight
            Container(
              margin:
                  const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white
                    .withValues(alpha: 0.06),
                borderRadius:
                    BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.white
                        .withValues(alpha: 0.10)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _sync.online
                          ? _online
                          : _offline,
                      boxShadow: [
                        BoxShadow(
                          color: (_sync.online
                                  ? _online
                                  : _offline)
                              .withValues(alpha: 0.6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          _sync.online
                              ? 'Online'
                              : 'Offline',
                          style: const TextStyle(
                              color: _sidebarFg,
                              fontSize: 13,
                              fontWeight:
                                  FontWeight.w600),
                        ),
                        Text(
                          _sync.online
                              ? _syncing
                                  ? 'Syncing changes…'
                                  : 'Everything up to date'
                              : '${_sync.pendingWrites} change${_sync.pendingWrites == 1 ? '' : 's'} queued locally',
                          style: const TextStyle(
                              color: _sidebarMuted,
                              fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  if (_syncing)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child:
                          CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white70),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
      IconData icon, String label, int index) {
    final active = _navIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 2),
      child: Container(
        decoration: BoxDecoration(
          color: active
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(10),
        ),
        child: ListTile(
          dense: true,
          leading: Icon(icon,
              color: active
                  ? Colors.white
                  : _sidebarMuted,
              size: 20),
          title: Text(label,
              style: TextStyle(
                  color: active
                      ? Colors.white
                      : _sidebarMuted,
                  fontSize: 14,
                  fontWeight: active
                      ? FontWeight.w600
                      : FontWeight.w400)),
          onTap: () =>
              setState(() => _navIndex = index),
        ),
      ),
    );
  }

  Widget _roleChip(
      bool value, IconData icon, String label) {
    final selected = _isSupervisor == value;
    return Expanded(
      child: GestureDetector(
        onTap: () =>
            setState(() => _isSupervisor = value),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 9),
          decoration: BoxDecoration(
            color:
                selected ? _accent : Colors.transparent,
            borderRadius:
                BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 15,
                  color: selected
                      ? Colors.white
                      : _sidebarMuted),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: selected
                          ? Colors.white
                          : _sidebarMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header + stats ─────────────────────────────────────────

  // ── Header + stats ─────────────────────────────────────────

  // ── Team view ────────────────────────────────────────────────
  // Shows every team member with their role and live task stats,
  // computed from the synced task list (works offline too).

  Widget _buildTeamView() {
    final members = [
      {
        'id': demoSupervisorId,
        'name': 'Supervisor',
        'role': 'Assigns work · reviews evidence',
        'icon': Icons.manage_accounts_outlined,
        'color': const Color(0xFF4F6DF5),
      },
      {
        'id': demoWorkerId,
        'name': 'Field Worker',
        'role': 'Executes tasks · captures evidence',
        'icon': Icons.handyman_outlined,
        'color': const Color(0xFF16A34A),
      },
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
      children: [
        for (final m in members)
          Builder(builder: (context) {
            final id = m['id'] as UuidValue;
            final mine =
                _tasks.where((t) => t.assigneeId == id).toList();
            final open =
                mine.where((t) => t.status == 'open').length;
            final prog = mine
                .where((t) => t.status == 'in_progress')
                .length;
            final done = mine
                .where((t) => t.status == 'completed')
                .length;
            final isMe = _me == id;
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: isMe
                        ? const Color(0xFF4F6DF5)
                        : const Color(0xFFE8ECF3),
                    width: isMe ? 2 : 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: (m['color'] as Color)
                          .withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(m['icon'] as IconData,
                        color: m['color'] as Color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(m['name'] as String,
                                style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: _ink)),
                            if (isMe) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4F6DF5)
                                      .withValues(alpha: 0.12),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: const Text('YOU',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight:
                                            FontWeight.w700,
                                        color:
                                            Color(0xFF4F6DF5))),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(m['role'] as String,
                            style: const TextStyle(
                                fontSize: 13,
                                color: _inkSoft)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _memberStat('$open', 'Open',
                                const Color(0xFF64748B)),
                            const SizedBox(width: 16),
                            _memberStat('$prog',
                                'In progress',
                                const Color(0xFF2563EB)),
                            const SizedBox(width: 16),
                            _memberStat('$done',
                                'Completed',
                                const Color(0xFF16A34A)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _sync.online
                          ? const Color(0xFF16A34A)
                              .withValues(alpha: 0.12)
                          : const Color(0xFFF59E0B)
                              .withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _sync.online
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFF59E0B),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                            _sync.online
                                ? 'Online'
                                : 'Offline',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _sync.online
                                    ? const Color(0xFF16A34A)
                                    : const Color(
                                        0xFFB45309))),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF4F6DF5)
                .withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: const Color(0xFF4F6DF5)
                    .withValues(alpha: 0.2)),
          ),
          child: const Row(
            children: [
              Icon(Icons.offline_bolt_outlined,
                  color: Color(0xFF4F6DF5), size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Shared team space — every member\'s tasks sync through Serverpod\'s CRDT engine, online or off.',
                  style: TextStyle(
                      fontSize: 13,
                      color: _inkSoft,
                      height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _memberStat(
      String value, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color)),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: _inkSoft)),
      ],
    );
  }

  // ── Activity view ────────────────────────────────────────────
  // Global feed of every TaskEvent across all tasks, newest first.
  // Built from the synced local DB — no server round-trip needed.

  Widget _buildActivityView() {
    return FutureBuilder<List<_ActivityItem>>(
      future: _loadActivity(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(
              child: CircularProgressIndicator());
        }
        final items = snap.data!;
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history_outlined,
                    size: 48,
                    color: Colors.grey.shade300),
                const SizedBox(height: 12),
                const Text('No activity yet',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _inkSoft)),
                const SizedBox(height: 6),
                const Text(
                    'Assign a task to kick things off.',
                    style: TextStyle(
                        fontSize: 13,
                        color: _inkSoft)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding:
              const EdgeInsets.fromLTRB(28, 8, 28, 28),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final it = items[i];
            return _activityRow(it);
          },
        );
      },
    );
  }

  Future<List<_ActivityItem>> _loadActivity() async {
    final out = <_ActivityItem>[];
    for (final task in _tasks) {
      if (task.id == null) continue;
      try {
        final events = await _sync
            .fetchEvents(task.id!)
            .timeout(const Duration(seconds: 5));
        for (final e in events) {
          out.add(_ActivityItem(
              event: e, taskTitle: task.title));
        }
      } catch (_) {}
    }
    out.sort((a, b) => b.event.createdAt
        .compareTo(a.event.createdAt));
    return out;
  }

  Widget _activityRow(_ActivityItem it) {
    final e = it.event;
    IconData icon;
    Color color;
    switch (e.kind) {
      case 'assigned':
        icon = Icons.assignment_add_outlined;
        color = const Color(0xFF4F6DF5);
        break;
      case 'started':
        icon = Icons.play_circle_outline;
        color = const Color(0xFF2563EB);
        break;
      case 'note':
        icon = Icons.note_add_outlined;
        color = const Color(0xFF7C3AED);
        break;
      case 'photo':
        icon = Icons.photo_camera_outlined;
        color = const Color(0xFFDB2777);
        break;
      case 'completed':
        icon = Icons.check_circle_outline;
        color = const Color(0xFF16A34A);
        break;
      case 'escalated':
        icon = Icons.warning_amber_outlined;
        color = const Color(0xFFDC2626);
        break;
      default:
        icon = Icons.circle_outlined;
        color = const Color(0xFF64748B);
    }
    final time = _formatActivityTime(e.createdAt);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFFE8ECF3)),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(it.taskTitle,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _ink)),
                const SizedBox(height: 2),
                Text(e.message,
                    style: const TextStyle(
                        fontSize: 13,
                        color: _inkSoft,
                        height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(time,
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  String _formatActivityTime(DateTime dt) {
    final now = DateTime.now().toUtc();
    final diff = now.difference(dt.toUtc());
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding:
          const EdgeInsets.fromLTRB(28, 22, 28, 18),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      _navIndex == 1
                          ? 'Team'
                          : _navIndex == 2
                              ? 'Activity'
                              : _isSupervisor
                                  ? 'Operations board'
                                  : 'My assignments',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                          letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _navIndex == 1
                          ? 'Everyone keeping the field running — online or off.'
                          : _navIndex == 2
                              ? 'Every assignment, update, note and photo — as it happened.'
                              : 'Assign work, track field progress, review evidence — online or off.',
                      style: const TextStyle(
                          fontSize: 13,
                          color: _inkSoft),
                    ),
                  ],
                ),
              ),
              _syncStatusPill(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statCard(
                  'Open',
                  _count('open'),
                  const Color(0xFF64748B),
                  Icons.radio_button_unchecked),
              const SizedBox(width: 12),
              _statCard(
                  'In progress',
                  _count('in_progress'),
                  const Color(0xFF2563EB),
                  Icons.timelapse_outlined),
              const SizedBox(width: 12),
              _statCard(
                  'Completed',
                  _count('completed'),
                  const Color(0xFF16A34A),
                  Icons.check_circle_outline),
              const SizedBox(width: 12),
              _statCard(
                  'Needs attention',
                  _count('escalated') +
                      _count('overdue'),
                  const Color(0xFFDC2626),
                  Icons.warning_amber_outlined),
            ],
          ),
        ],
      ),
    );
  }

  int _count(String status) =>
      _tasks.where((t) => t.status == status).length;

  Widget _statCard(String label, int value,
      Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _pageBg,
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
              color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _sidebarBg,
                borderRadius:
                    BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  color: Colors.white, size: 19),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text('$value',
                    style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                        height: 1.1)),
                Text(label,
                    style: const TextStyle(
                        fontSize: 12,
                        color: _inkSoft)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Offline-first hero: connection, queue, and sync progress.
  Widget _syncStatusPill() {
    final online = _sync.online;
    final pending = _sync.pendingWrites;
    final Color dot = !online
        ? _offline
        : (_syncing || pending > 0 ? _amber : _online);
    final String label = !online
        ? 'Offline'
        : (_syncing
            ? 'Syncing…'
            : (pending > 0
                ? '$pending pending'
                : 'Synced'));
    final String sub = !online
        ? 'Saving on this device'
        : (_lastSynced != null
            ? 'Last sync ${_fmtTime(_lastSynced!)}'
            : 'Live');
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: dot.withValues(alpha: 0.10),
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
            color: dot.withValues(alpha: 0.35),
            width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_syncing)
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: dot),
            )
          else
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dot),
            ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: dot,
                      height: 1.1)),
              Text(sub,
                  style: const TextStyle(
                      fontSize: 11,
                      color: _inkSoft,
                      height: 1.2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _offlineBanner() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFEF3C7),
      padding: const EdgeInsets.symmetric(
          horizontal: 28, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_outlined,
              size: 17,
              color: Color(0xFFB45309)),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "You're offline — every change is saved on this device and syncs automatically on reconnect.",
              style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF92400E),
                  fontWeight: FontWeight.w500),
            ),
          ),
          if (_sync.pendingWrites > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFB45309),
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Text(
                '${_sync.pendingWrites} queued',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }

  // ── Kanban ─────────────────────────────────────────────────

  Widget _buildKanban(List<Task> visible) {
    final urgent = visible
        .where((t) =>
            t.status == 'escalated' ||
            t.status == 'overdue')
        .toList();
    final open = visible
        .where((t) => t.status == 'open')
        .toList();
    // Urgent tasks float to the top of the Open column.
    final openCol = [...urgent, ...open];
    final inProgress = visible
        .where((t) => t.status == 'in_progress')
        .toList();
    final done = visible
        .where((t) => t.status == 'completed')
        .toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          28, 18, 28, 18),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _kanbanColumn(
              'Open', openCol, const Color(0xFFDC2626),
              flex: 1),
          const SizedBox(width: 16),
          _kanbanColumn('In Progress', inProgress,
              const Color(0xFFD97706),
              flex: 1),
          const SizedBox(width: 16),
          _kanbanColumn('Completed', done,
              const Color(0xFF16A34A),
              flex: 1),
        ],
      ),
    );
  }

  Widget _kanbanColumn(
      String title, List<Task> tasks, Color dot,
      {required int flex}) {
    return Expanded(
      flex: flex,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: 4, bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dot),
                ),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _ink)),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2),
                  decoration: BoxDecoration(
                    color:
                        Colors.grey.shade200,
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Text('${tasks.length}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w700,
                          color: _inkSoft)),
                ),
              ],
            ),
          ),
          Expanded(
            child: tasks.isEmpty
                ? Container(
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withValues(alpha: 0.55),
                      borderRadius:
                          BorderRadius.circular(
                              14),
                      border: Border.all(
                          color:
                              Colors.grey.shade200,
                          style: BorderStyle.none),
                    ),
                    child: Center(
                      child: Text(
                        'No tasks',
                        style: TextStyle(
                            color: Colors
                                .grey.shade400,
                            fontSize: 13),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (_, i) =>
                        _taskCard(tasks[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _taskCard(Task task) {
    final color = _statusColor(task.status);
    final priority = _priority(task);
    final pColor = _priorityColor(priority);
    final urgent = priority == 'High';
    final mine = task.assigneeId == _me;
    return Container(
      margin:
          const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
            color: urgent
                ? pColor.withValues(alpha: 0.5)
                : Colors.grey.shade200,
            width: urgent ? 1.4 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(14),
        onTap: () => _openDetail(task),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3),
                    decoration: BoxDecoration(
                      color:
                          _priorityBg(priority),
                      borderRadius:
                          BorderRadius.circular(
                              6),
                    ),
                    child: Text(priority,
                        style: TextStyle(
                            color: pColor,
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w700)),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(
                          alpha: 0.10),
                      borderRadius:
                          BorderRadius.circular(
                              6),
                    ),
                    child: Text(
                      _statusLabel(task.status)
                          .toUpperCase(),
                      style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight:
                              FontWeight.w800,
                          letterSpacing: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                task.title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                    letterSpacing: -0.2),
              ),
              if (task.notes?.isNotEmpty ==
                  true) ...[
                const SizedBox(height: 6),
                Text(
                  task.notes!,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13,
                      color: _inkSoft,
                      height: 1.35),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: mine
                        ? _accent
                        : Colors.grey.shade400,
                    child: Text(
                      _assigneeName(
                              task.assigneeId)
                          [0]
                          .toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight:
                              FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      _assigneeName(
                          task.assigneeId),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w600,
                          color: _inkSoft),
                      overflow:
                          TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                      Icons.access_time_outlined,
                      size: 13,
                      color: _inkSoft),
                  const SizedBox(width: 4),
                  Text(
                    _fmtTime(task.updatedAt),
                    style: const TextStyle(
                        fontSize: 12,
                        color: _inkSoft),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openDetail(Task task) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _TaskDetailSheet(
        task: task,
        sync: _sync,
        isWorker: !_isSupervisor,
        onSetStatus: (s, k) =>
            _setStatus(task, s, k),
        onAddNote: () => _addNote(task),
        onAttachPhoto: () =>
            _attachPhoto(task),
      ),
    );
    await _reload();
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_error != null && !_ready) {
      return Scaffold(
        appBar:
            AppBar(title: const Text('FieldSync')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to start:\n$_error',
              style:
                  const TextStyle(color: Colors.red),
            ),
          ),
        ),
      );
    }
    if (!_ready) {
      return const Scaffold(
          body: Center(
              child:
                  CircularProgressIndicator()));
    }

    final visible = _isSupervisor
        ? _tasks
        : _tasks
            .where((t) => t.assigneeId == _me)
            .toList();

    return Scaffold(
      backgroundColor: _pageBg,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                if (!_sync.online)
                  _offlineBanner(),
                Expanded(
                  child: _navIndex == 1
                      ? _buildTeamView()
                      : _navIndex == 2
                          ? _buildActivityView()
                          : visible.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              Icon(
                                  Icons
                                      .assignment_outlined,
                                  size: 48,
                                  color: Colors
                                      .grey.shade300),
                              const SizedBox(
                                  height: 12),
                              Text(
                                _isSupervisor
                                    ? 'No tasks yet — assign the first one.'
                                    : 'No assignments yet — check back soon.',
                                style:
                                    const TextStyle(
                                        color:
                                            _inkSoft,
                                        fontSize:
                                            14),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            if (_sync.online) {
                              await _sync
                                  .syncOnce();
                              _sync.pendingWrites =
                                  0;
                            }
                            await _reload();
                          },
                          child:
                              SingleChildScrollView(
                            physics:
                                const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height:
                                  MediaQuery.of(context)
                                          .size
                                          .height -
                                      260,
                              child: _buildKanban(
                                  visible),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _isSupervisor && _navIndex == 0
          ? FloatingActionButton.extended(
              key:
                  const ValueKey('assign_task'),
              onPressed: _assignTask,
              backgroundColor: _accent,
              icon:
                  const Icon(Icons.add_task),
              label:
                  const Text('Assign task'),
            )
          : null,
    );
  }
}

class _TaskDetailSheet extends StatefulWidget {
  final Task task;
  final SyncService sync;
  final bool isWorker;
  final Future<void> Function(String, String)
      onSetStatus;
  final Future<void> Function() onAddNote;
  final Future<void> Function() onAttachPhoto;

  const _TaskDetailSheet({
    required this.task,
    required this.sync,
    required this.isWorker,
    required this.onSetStatus,
    required this.onAddNote,
    required this.onAttachPhoto,
  });

  @override
  State<_TaskDetailSheet> createState() =>
      _TaskDetailSheetState();
}

class _TaskDetailSheetState
    extends State<_TaskDetailSheet> {
  List<TaskEvent> _events = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final events = await widget.sync
          .fetchEvents(widget.task.id!);
      if (mounted)
        setState(() => _events = events);
    } catch (_) {}
  }

  IconData _iconFor(String kind) =>
      switch (kind) {
        'assigned' =>
          Icons.assignment_ind_outlined,
        'started' =>
          Icons.play_arrow_outlined,
        'note' => Icons.note_outlined,
        'photo' => Icons.photo_outlined,
        'photo_pending' =>
          Icons.cloud_upload_outlined,
        'completed' =>
          Icons.check_circle_outline,
        'escalated' =>
          Icons.warning_amber_outlined,
        _ => Icons.circle_outlined,
      };

  Widget _eventTile(TaskEvent e) {
    final msg = e.message.contains('|')
        ? e.message.split('|').last
        : e.message;
    return ListTile(
      leading:
          Icon(_iconFor(e.kind), size: 20),
      title: e.kind == 'photo'
          ? ClipRRect(
              borderRadius:
                  BorderRadius.circular(8),
              child: Image.network(
                msg,
                height: 140,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const Text(
                        'Photo unavailable offline'),
              ),
            )
          : Text(msg),
      subtitle: Text(
        '${e.kind.replaceAll('_', ' ')} · ${_fmtTime(e.createdAt)}',
      ),
      dense: true,
    );
  }

  String _fmtTime(DateTime t) {
    final l = t.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.task;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color:
                        Colors.grey.shade300,
                    borderRadius:
                        BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(t.title,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                'Status: ${t.status.replaceAll('_', ' ')}'
                '${t.notes?.isNotEmpty == true ? '\nNotes: ${t.notes}' : ''}',
              ),
              const SizedBox(height: 12),
              if (widget.isWorker) ...[
                Wrap(
                  spacing: 8,
                  children: [
                    if (t.status == 'open')
                      FilledButton.tonal(
                        onPressed: () async {
                          await widget.onSetStatus(
                              'in_progress',
                              'started');
                          if (context.mounted) {
                            Navigator.pop(
                                context);
                          }
                        },
                        child: const Text(
                            'Start work'),
                      ),
                    if (t.status ==
                            'in_progress' ||
                        t.status == 'open')
                      FilledButton(
                        onPressed: () async {
                          await widget.onSetStatus(
                              'completed',
                              'completed');
                          if (context.mounted) {
                            Navigator.pop(
                                context);
                          }
                        },
                        child: const Text(
                            'Complete'),
                      ),
                    OutlinedButton.icon(
                      onPressed:
                          widget.onAddNote,
                      icon: const Icon(
                          Icons.note_add_outlined,
                          size: 18),
                      label:
                          const Text('Note'),
                    ),
                    OutlinedButton.icon(
                      onPressed:
                          widget.onAttachPhoto,
                      icon: const Icon(
                          Icons
                              .photo_camera_outlined,
                          size: 18),
                      label:
                          const Text('Photo'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              const Text('Evidence timeline',
                  style: TextStyle(
                      fontWeight:
                          FontWeight.bold)),
              const Divider(),
              Expanded(
                child: _events.isEmpty
                    ? const Center(
                        child: Text(
                            'No activity yet'))
                    : ListView.builder(
                        controller: ctrl,
                        itemCount:
                            _events.length,
                        itemBuilder: (_, i) =>
                            _eventTile(
                                _events[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
