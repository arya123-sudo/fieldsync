import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:serverpod_database/serverpod_database.dart';
import 'package:serverpod_offline_sync_client/serverpod_offline_sync_client.dart';
import 'package:fieldsync_client/fieldsync_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncService {
  SyncService(this._client);
  final Client _client;

  OfflineSyncDatabaseSession? session;
  OfflineSyncSubscription? _stream;
  SharedPreferences? _prefs;

  UuidValue? myId;
  UuidValue? teamSpaceId; // spaces are UUID-identified on the client

  int pendingWrites = 0;
  bool online = true;

  Future<void> init({required UuidValue me}) async {
    myId = me;
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    final spaceStr = prefs.getString('teamSpaceId');
    if (spaceStr == null) {
      final setup = await _client.setup.getOrCreateDemoTeam();
      teamSpaceId = setup.teamSpaceId;
      await prefs.setString('teamSpaceId', teamSpaceId.toString());
    } else {
      teamSpaceId = UuidValue.fromString(spaceStr);
    }
    // path_provider has no web implementation — sqlite3_web uses a virtual
    // filesystem, so a plain filename is enough on web.
    final String dbPath;
    if (kIsWeb) {
      dbPath = 'fieldsync.db';
    } else {
      final dir = await getApplicationSupportDirectory();
      dbPath = p.join(dir.path, 'fieldsync.db');
    }
    session = await _client.createSyncSession(
      dbPath,
      isDebugMode: kDebugMode,
      persistentUserId: me,
    );
  }

  void startStreaming() {
    _stream = _client.offlineSync.syncContinuously(session!);
  }

  Future<void> syncOnce() => _client.offlineSync.syncOnce(session!);

  // Every read/write goes through the shared team space. Bumps the
  // pending counter when offline (drives the "N changes pending" UI).
  Future<T> inTeamSpace<T>(Future<T> Function(Transaction tx) fn) {
    if (!online) pendingWrites++;
    return session!.db.transactionForUser(myId!, fn, spaceId: teamSpaceId);
  }

  Future<List<Task>> fetchTasks() async {
    final all = await inTeamSpace(
      (tx) => Task.db.find(session!, transaction: tx),
    );
    all.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return all;
  }

  Future<List<TaskEvent>> fetchEvents(UuidValue taskId) async {
    final all = await inTeamSpace(
      (tx) => TaskEvent.db.find(session!, transaction: tx),
    );
    final mine = all.where((e) => e.taskId == taskId).toList();
    mine.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return mine;
  }

  Future<void> addEvent({
    required UuidValue taskId,
    required String kind,
    required String message,
  }) => inTeamSpace(
    (tx) => TaskEvent.db.insertRow(
      session!,
      TaskEvent(
        taskId: taskId,
        kind: kind,
        message: message,
        createdAt: DateTime.now().toUtc(),
      ),
      transaction: tx,
    ),
  );

  Future<void> updateEvent(TaskEvent event) => inTeamSpace(
    (tx) => TaskEvent.db.updateRow(session!, event, transaction: tx),
  );

  Future<void> updateTask(Task task) {
    task.updatedAt = DateTime.now().toUtc();
    return inTeamSpace(
      (tx) => Task.db.updateRow(session!, task, transaction: tx),
    );
  }

  Future<void> savePendingPhoto(String eventKey, Uint8List bytes) async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    await prefs.setString('pendingPhoto:$eventKey', base64Encode(bytes));
  }

  Future<Uint8List?> loadPendingPhoto(String eventKey) async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    final encoded = prefs.getString('pendingPhoto:$eventKey');
    if (encoded == null) return null;
    try {
      return Uint8List.fromList(base64Decode(encoded));
    } on FormatException {
      await prefs.remove('pendingPhoto:$eventKey');
      return null;
    }
  }

  Future<void> clearPendingPhoto(String eventKey) async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    await prefs.remove('pendingPhoto:$eventKey');
  }

  Future<void> dispose() async {
    await _stream?.cancel();
    await session?.close();
  }
}
