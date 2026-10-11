import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_offline_sync_server/serverpod_offline_sync_server.dart';
import 'package:fieldsync_server/src/generated/future_calls.dart';
import 'package:fieldsync_server/src/generated/protocol.dart';

class TaskEndpoint extends Endpoint {
  @override
  bool get requireLogin => false; // demo mode

  // Sync tables carry an int spaceId FK; spaces are publicly identified by
  // UUID. Resolve the UUID to its DB row id for server-side writes.
  Future<int?> _spaceDbId(Session session, UuidValue spaceUuid) async {
    final row = await OfflineSyncSpace.db.findFirstRow(
      session,
      where: (t) => t.uuidSpaceId.equals(spaceUuid),
    );
    return row?.id;
  }

  // Supervisor assigns a task. Writes into the shared team space and
  // schedules the escalation check. Online-only by design.
  Future<Task> createTask(
    Session session, {
    required String title,
    required UuidValue assigneeId,
    String? notes,
    required UuidValue teamSpaceId,
    required UuidValue actorId,
    int escalationAfterMinutes = 30,
  }) async {
    final spaceDbId = await _spaceDbId(session, teamSpaceId);
    late Task created;
    final syncDatabase = session.db as OfflineSyncDatabase;
    await syncDatabase.transactionForUser(
      actorId,
      (tx) async {
        created = await Task.db.insertRow(
          session,
          Task(
            title: title,
            status: 'open',
            assigneeId: assigneeId,
            notes: notes,
            updatedAt: DateTime.now().toUtc(),
            spaceId: spaceDbId,
          ),
          transaction: tx,
        );
        await TaskEvent.db.insertRow(
          session,
          TaskEvent(
            taskId: created.id!,
            kind: 'assigned',
            message: 'Task assigned',
            createdAt: DateTime.now().toUtc(),
            spaceId: spaceDbId,
          ),
          transaction: tx,
        );
      },
      spaceId: teamSpaceId,
    );

    // v4 scheduling: futureCalls.callWithDelay(...).taskEscalation.checkEscalation(...)
    await session.serverpod.futureCalls
        .callWithDelay(Duration(minutes: escalationAfterMinutes))
        .taskEscalation
        .checkEscalation(
          EscalationCheck(
            taskId: created.id!,
            teamSpaceId: teamSpaceId,
            actorId: actorId,
          ),
        );

    return created;
  }

  // Stores an evidence photo in public storage, returns a public URL.
  // Online-only; the client uploads queued photos on reconnect.
  Future<String> uploadEvidencePhoto(
    Session session,
    ByteData data,
    String fileName,
  ) async {
    final safeName =
        'evidence/${DateTime.now().toUtc().millisecondsSinceEpoch}_$fileName';
    await session.storage.storeFile(
      storageId: 'public',
      path: safeName,
      byteData: data,
    );
    final url = await session.storage.publicDownloadUrl(
      storageId: 'public',
      path: safeName,
    );
    return url.toString();
  }
}
