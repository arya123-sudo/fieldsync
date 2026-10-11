import 'package:serverpod/serverpod.dart';
import 'package:serverpod_offline_sync_server/serverpod_offline_sync_server.dart';
import 'package:fieldsync_server/src/generated/protocol.dart';
import '../util/demo_ids.dart';

class SetupEndpoint extends Endpoint {
  @override
  bool get requireLogin => false; // demo mode

  // One-time bootstrap, idempotent. Creates the shared team space and
  // remembers its UUID in AppConfig so repeat calls return the same space.
  Future<DemoSetup> getOrCreateDemoTeam(Session session) async {
    final configs = await AppConfig.db.find(session);
    for (final c in configs) {
      if (c.key == 'demo_team_space') {
        return DemoSetup(
          supervisorId: demoSupervisorId,
          workerId: demoWorkerId,
          teamSpaceId: UuidValue.fromString(c.value),
        );
      }
    }
    final spaceUuid = await session.offlineSync.spaces.create(grants: {
      demoSupervisorId: OfflineSyncSpaceRole.readWrite,
      demoWorkerId: OfflineSyncSpaceRole.readWrite,
    });
    await AppConfig.db.insertRow(
      session,
      AppConfig(key: 'demo_team_space', value: spaceUuid.toString()),
    );
    return DemoSetup(
      supervisorId: demoSupervisorId,
      workerId: demoWorkerId,
      teamSpaceId: spaceUuid,
    );
  }
}
