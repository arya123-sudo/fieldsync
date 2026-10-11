import 'package:serverpod/serverpod.dart';

// Demo-mode identities. Stable across restarts (the sync engine requires it).
// TODO: replace with serverpod_auth user UUIDs before submission polish.
final UuidValue demoSupervisorId = UuidValue.fromString(
  '11111111-1111-4111-8111-111111111111',
);
final UuidValue demoWorkerId = UuidValue.fromString(
  '22222222-2222-4222-8222-222222222222',
);
