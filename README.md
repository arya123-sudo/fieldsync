# FieldSync

**Work anywhere. Sync everything.**

🔗 **Live demo:** https://fieldsync.serverpod.space/app/
🎥 **Demo video:** https://youtu.be/I6a5SK4aNXw

FieldSync is an offline-first maintenance coordination app for field teams. Supervisors assign inspection and repair tasks; technicians keep working with zero connectivity — updating status, adding notes, capturing photo evidence — and everything synchronizes automatically when they're back online.

Built for the [Build Something Real: The Serverpod Hackathon](https://builderbase.com/event/build-something-real-the-serverpod-hackathon) — finished **#30 of ~200 entries**, overall judge score **4.10/5**.

## Screenshots

### Kanban Board
![FieldSync Kanban Board](docs/screenshots/kanban-board.png)

### Team
![Team](docs/screenshots/team.png)

### Activity
![Activity](docs/screenshots/activity.png)

### Evidence Timeline
![FieldSync Evidence Timeline](docs/screenshots/evidence-timeline.png)

---
## Why it exists

Field workers don't stop working when the internet does. In factories, rural sites, basements, and remote installations, connectivity is a luxury — but the job isn't. FieldSync treats offline as the normal case, not the exception: every task, note, and status change is written to a local CRDT-backed database first, then merged with the team when a connection returns. No spinners, no "retry" buttons, no lost work.

## How conflicts are resolved

Every change is written to the local CRDT-backed database first, so nobody is ever blocked by a bad connection. When a device reconnects, Serverpod's offline sync merges its changes with the team's shared space using CRDT semantics: edits to different parts of a task merge cleanly, and if two people change the same field while offline, the merge resolves deterministically instead of corrupting the record. Nothing is silently lost either way — every assignment, status change, note and photo is preserved in the task's evidence timeline, so a supervisor can always reconstruct what happened, in what order.

Example: Worker A adds the note "Voltage: 231V" offline while Worker B marks the same task complete from another site. On reconnect, the completed task carries A's note — no retry, no overwrite, no lost evidence.

## What it does

- **Supervisor view** — assign tasks with notes and an escalation deadline
- **Worker view** — start/complete tasks, add field notes, attach photo evidence
- **Offline-first sync** — full read/write offline via CRDT merge; pending-change badge shows exactly what's queued
- **Evidence timeline** — every assignment, note, photo, and status change on a per-task timeline
- **Escalation** — tasks untouched past their deadline are auto-escalated server-side (works even if every client is offline)
- **Live sync badge** — Offline / Syncing / Pending / Synced states, always visible

## Tech stack

- **Serverpod 4** — backend, ORM, auth-ready endpoints, future calls
- **serverpod_offline_sync 0.0.10** (experimental) — CRDT-based offline sync (`database: sync` tables, shared team spaces)
- **Flutter (web)** — supervisor/worker board
- **PostgreSQL** (embedded, via `serverpod start`) — no Docker needed for local dev

Serverpod isn't glue here — it's the product. The offline merge engine, the shared-space model, the server-side escalation timer, and the generated type-safe client are all Serverpod. Without it, FieldSync is a todo list.

## Run it locally

Prerequisites: Flutter SDK, Dart, Serverpod CLI 4.x. Clone the repo, then from the project root:

```bash
# 1. Install dependencies
cd fieldsync_flutter
flutter pub get

# 2. Generate code and create the migration (from the project root)
cd ..
serverpod generate
serverpod create-migration

# 3. Start everything (server + embedded Postgres + Flutter web)
serverpod start
```

Open the "Fieldsync app running at" URL from the log. No `config/passwords.yaml`? Create one:

```yaml
# fieldsync_server/config/passwords.yaml
development:
  database: 'pick-a-local-password'
```

## The 2-minute demo

1. As **Supervisor**, assign "Inspect transformer #42" with a 2-minute escalation deadline.
2. Switch to **Worker**, open the task: Start work → add note "Voltage: 231V" → attach a photo → Complete.
3. **Turn off WiFi.** Keep working — update another task, add a note. The badge goes red: "N changes pending".
4. **Reconnect.** The badge goes amber (Syncing…), then green (Synced). The supervisor sees everything, including the photo.
5. Assign a task and *don't touch it* — after the deadline it escalates to `escalated` with a timeline entry, entirely server-side.

## Project structure

```
fieldsync_server/
  lib/server.dart                  # sync engine wiring (databaseInterceptor + initializeOfflineSync)
  lib/src/models/                  # Task, TaskEvent (database: sync), AppConfig, sync payloads
  lib/src/endpoints/               # setup (team-space bootstrap), task (assign, photo upload)
  lib/src/future_calls/            # escalation timer
  config/generator.yaml            # offline_sync module + databaseSync experimental flag
fieldsync_flutter/
  lib/src/screens/board_screen.dart
  lib/src/sync/sync_service.dart    # sync session, team-space reads/writes, reconnect flush
  lib/src/widgets/sync_badge.dart
```

## AI disclosure

Per the hackathon rules: this project was built with AI assistance (code generation, API research against the `serverpod_offline_sync` 0.0.10 sources, and debugging). The product decisions, testing, demo, and submission are the team's own work.

## Team

Arya Yaligar and Sanjana T D — team "Vibe and theme".
