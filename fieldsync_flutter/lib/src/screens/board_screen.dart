import 'dart:async';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:serverpod_client/serverpod_client.dart';
import 'package:fieldsync_client/fieldsync_client.dart';

import '../sync/demo_ids.dart';
import '../sync/sync_service.dart';
import '../widgets/sync_badge.dart';

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
  List<Task> _tasks = [];
  Timer? _refreshTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _syncing = false;
  DateTime? _lastSynced;
  final Map<String, Uint8List> _pendingPhotos = {}; // eventKey -> bytes
  final Map<String, UuidValue> _eventTask = {}; // eventKey -> taskId

  UuidValue get _me => _isSupervisor ? demoSupervisorId : demoWorkerId;

  @override
  void initState() {
    super.initState();
    _sync = SyncService(widget.client);
    _boot();
    _connectivitySub = Connectivity().onConnectivityChanged.listen(
      _onConnectivity,
    );
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _reload(),
    );
  }

  Future<void> _boot() async {
    try {
      final conn = await Connectivity().checkConnectivity();
      _sync.online = !conn.contains(ConnectivityResult.none);
      await _sync.init(me: _me);
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
      final tasks = await _sync.fetchTasks().timeout(
        const Duration(seconds: 8),
      );
      if (mounted) setState(() => _tasks = tasks);
    } catch (_) {
      // keep old list while offline
    }
  }

  Future<void> _restoreAndUploadPendingPhotos() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await _restorePendingPhotos();
      if (_sync.online) await _uploadPendingPhotos();
      await _reload();
    } catch (_) {
      // Keep the board usable; the next connectivity/reload cycle retries.
    }
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
        if (ev.kind == 'photo_pending' && ev.message.startsWith('$eventKey|')) {
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
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const ValueKey('task_title'),
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title (e.g. Inspect transformer #42)',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                key: const ValueKey('task_notes'),
                controller: notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                ),
              ),
              TextFormField(
                key: const ValueKey('task_escalation_minutes'),
                controller: minutesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Escalate if not started within (minutes)',
                  hintText: 'Use 2 for the demo',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
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
              if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await widget.client.task.createTask(
        title: titleCtrl.text.trim(),
        assigneeId: demoWorkerId,
        notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
        teamSpaceId: _sync.teamSpaceId!,
        actorId: _me,
        escalationAfterMinutes: int.tryParse(minutesCtrl.text) ?? 30,
      );
      await _reload();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Assign failed: $e')));
      }
    }
  }

  Future<void> _setStatus(Task task, String status, String eventKind) async {
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
          decoration: const InputDecoration(hintText: 'e.g. Voltage: 231V'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (text == null || text.isEmpty) return;
    await _sync.addEvent(taskId: task.id!, kind: 'note', message: text);
    await _reload();
  }

  Future<void> _attachPhoto(Task task) async {
    final XFile? picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    final XFile? file =
        picked ?? await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (_sync.online) {
      try {
        final url = await widget.client.task.uploadEvidencePhoto(
          bytes.buffer.asByteData(),
          file.name,
        );
        await _sync.addEvent(taskId: task.id!, kind: 'photo', message: url);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
        }
        return;
      }
    } else {
      // Offline: record immediately, upload the bytes on reconnect.
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

  Color _statusColor(String s) => switch (s) {
    'completed' => Colors.green.shade700,
    'in_progress' => Colors.blue.shade700,
    'escalated' => Colors.red.shade700,
    'overdue' => Colors.orange.shade800,
    _ => Colors.grey.shade700,
  };

  String _fmtTime(DateTime t) {
    final l = t.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  Widget _taskTile(Task task) {
    final mine = task.assigneeId == _me;
    return Card(
      child: ListTile(
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Updated ${_fmtTime(task.updatedAt)}${mine ? ' · assigned to you' : ''}',
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _statusColor(task.status).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _statusColor(task.status)),
          ),
          child: Text(
            task.status.replaceAll('_', ' ').toUpperCase(),
            style: TextStyle(
              color: _statusColor(task.status),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
        onTap: () => _openDetail(task),
      ),
    );
  }

  Future<void> _openDetail(Task task) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _TaskDetailSheet(
        task: task,
        sync: _sync,
        isWorker: !_isSupervisor,
        onSetStatus: (s, k) => _setStatus(task, s, k),
        onAddNote: () => _addNote(task),
        onAttachPhoto: () => _attachPhoto(task),
      ),
    );
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null && !_ready) {
      return Scaffold(
        appBar: AppBar(title: const Text('FieldSync')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to start:\n$_error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      );
    }
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final visible = _isSupervisor
        ? _tasks
        : _tasks.where((t) => t.assigneeId == _me).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('FieldSync'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: SyncBadge(
                online: _sync.online,
                pendingWrites: _sync.pendingWrites,
                syncing: _syncing,
                lastSynced: _lastSynced,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  label: Text('Supervisor'),
                  icon: Icon(Icons.manage_accounts_outlined),
                ),
                ButtonSegment(
                  value: false,
                  label: Text('Worker'),
                  icon: Icon(Icons.handyman_outlined),
                ),
              ],
              selected: {_isSupervisor},
              onSelectionChanged: (s) =>
                  setState(() => _isSupervisor = s.first),
            ),
          ),
        ),
      ),
      body: visible.isEmpty
          ? const Center(
              child: Text(
                'No tasks yet — supervisors assign from the + button.',
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                if (_sync.online) {
                  await _sync.syncOnce();
                  _sync.pendingWrites = 0;
                }
                await _reload();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: visible.length,
                itemBuilder: (_, i) => _taskTile(visible[i]),
              ),
            ),
      floatingActionButton: _isSupervisor
          ? FloatingActionButton.extended(
              key: const ValueKey('assign_task'),
              onPressed: _assignTask,
              icon: const Icon(Icons.add_task),
              label: const Text('Assign task'),
            )
          : null,
    );
  }
}

class _TaskDetailSheet extends StatefulWidget {
  final Task task;
  final SyncService sync;
  final bool isWorker;
  final Future<void> Function(String, String) onSetStatus;
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
  State<_TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends State<_TaskDetailSheet> {
  List<TaskEvent> _events = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final events = await widget.sync.fetchEvents(widget.task.id!);
      if (mounted) setState(() => _events = events);
    } catch (_) {}
  }

  IconData _iconFor(String kind) => switch (kind) {
    'assigned' => Icons.assignment_ind_outlined,
    'started' => Icons.play_arrow_outlined,
    'note' => Icons.note_outlined,
    'photo' => Icons.photo_outlined,
    'photo_pending' => Icons.cloud_upload_outlined,
    'completed' => Icons.check_circle_outline,
    'escalated' => Icons.warning_amber_outlined,
    _ => Icons.circle_outlined,
  };

  Widget _eventTile(TaskEvent e) {
    final msg = e.message.contains('|') ? e.message.split('|').last : e.message;
    return ListTile(
      leading: Icon(_iconFor(e.kind), size: 20),
      title: e.kind == 'photo'
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                msg,
                height: 140,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Text('Photo unavailable offline'),
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
      builder: (_, ctrl) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
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
                        await widget.onSetStatus('in_progress', 'started');
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('Start work'),
                    ),
                  if (t.status == 'in_progress' || t.status == 'open')
                    FilledButton(
                      onPressed: () async {
                        await widget.onSetStatus('completed', 'completed');
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('Complete'),
                    ),
                  OutlinedButton.icon(
                    onPressed: widget.onAddNote,
                    icon: const Icon(Icons.note_add_outlined, size: 18),
                    label: const Text('Note'),
                  ),
                  OutlinedButton.icon(
                    onPressed: widget.onAttachPhoto,
                    icon: const Icon(Icons.photo_camera_outlined, size: 18),
                    label: const Text('Photo'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            const Text(
              'Evidence timeline',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: _events.isEmpty
                  ? const Center(child: Text('No activity yet'))
                  : ListView.builder(
                      controller: ctrl,
                      itemCount: _events.length,
                      itemBuilder: (_, i) => _eventTile(_events[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
