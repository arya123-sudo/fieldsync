import 'package:serverpod/serverpod.dart';
import 'package:serverpod_offline_sync_server/serverpod_offline_sync_server.dart';
import 'package:fieldsync_server/src/generated/protocol.dart';

// Fires once per task after the escalation delay. If the task is still
// 'open', it is escalated and a timeline event is recorded.
// Runs fully server-side — works even if every client is offline.
class TaskEscalationFutureCall extends FutureCall {
  Future<void> checkEscalation(Session session, EscalationCheck check) async {
    final task = await Task.db.findById(session, check.taskId);
    if (task == null) return;
    final spaceRow = await OfflineSyncSpace.db.findFirstRow(
      session,
      where: (t) => t.uuidSpaceId.equals(check.teamSpaceId),
    );
    if (task.spaceId != spaceRow?.id) return;
    if (task.status == 'open') {
      task.status = 'escalated';
      task.updatedAt = DateTime.now().toUtc();
      await Task.db.updateRow(session, task);
      await TaskEvent.db.insertRow(
        session,
        TaskEvent(
          taskId: task.id!,
          kind: 'escalated',
          message: 'No worker started in time — escalated to team lead.',
          createdAt: DateTime.now().toUtc(),
          spaceId: spaceRow?.id,
        ),
      );
    }
  }
}
