import 'package:fieldsync_client/fieldsync_client.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:serverpod_offline_sync_client/serverpod_offline_sync_client.dart';

import '../client.dart';

class TaskService {
  static OfflineSyncDatabaseSession? _session;

  static Future<OfflineSyncDatabaseSession> get session async {
    if (_session != null) return _session!;

    final directory = await getApplicationDocumentsDirectory();
    final dbPath = p.join(directory.path, 'fieldsync.sqlite');

    _session = await client.createSyncSession(
      dbPath,
      persistentUserId: UuidValue.fromString(
        '11111111-1111-4111-8111-111111111111',
      ),
    );

    return _session!;
  }

  static Future<Task> createTask(String title) async {
    final dbSession = await session;

    final task = Task(
      title: title,
      status: 'pending',
      updatedAt: DateTime.now().toUtc(),
    );

    return Task.db.insertRow(dbSession, task);
  }

  static Future<List<Task>> getTasks() async {
    final dbSession = await session;
    return Task.db.find(dbSession);
  }

  static Future<void> syncTasks() async {
    final dbSession = await session;
    await client.offlineSync.syncOnce(dbSession);
  }
}
