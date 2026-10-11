import 'dart:io';
import 'package:serverpod/serverpod.dart' hide Serverpod;

import 'package:serverpod/serverpod.dart' as serverpod;
import 'package:serverpod_cloud_storage/serverpod_cloud_storage.dart';
import 'package:serverpod_offline_sync_server/serverpod_offline_sync_server.dart';

import 'src/cache_busting.dart';
import 'src/generated/protocol.dart';
import 'src/generated/serverpod.dart';
import 'src/util/demo_ids.dart';
import 'src/web/routes/app_config_route.dart';
import 'src/web/routes/root.dart';

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  // Initialize Serverpod. The generated Serverpod class is already connected
  // with your project's generated code.
  //
  // The offlineSyncDatabaseInterceptor wraps every session database in a
  // CRDT-aware layer so the offline sync engine tracks changes on
  // sync tables.
  //
  // Demo auth: the offline-sync stream endpoint requires login, but this
  // demo has no auth system. The token IS the user UUID — the handler
  // accepts the two demo identities so the sync stream can authenticate.
  // TODO: replace with serverpod_auth before production use.
  final pod = Serverpod(
    args,
    databaseInterceptor: offlineSyncDatabaseInterceptor,
    authenticationHandler: (session, token) async {
      print('CUSTOM AUTH HANDLER CALLED: token=$token');
      try {
        final userId = serverpod.UuidValue.withValidation(token);
        if (userId == demoSupervisorId || userId == demoWorkerId) {
          return serverpod.AuthenticationInfo(
            userId.toString(),
            const <serverpod.Scope>{},
            authId: 'demo-${userId.toString()}',
          );
        }
      } catch (_) {}
      return null;
    },
  );

  // Configure the CRDT sync engine with our sync tables. Must run before any
  // sync request is served.
  pod.initializeOfflineSync(syncTables: [Task.t, TaskEvent.t]);

  // Setup a default page at the web root.
  // These are used by the default page.
  pod.webServer.addRoute(RootRoute(), '/');
  pod.webServer.addRoute(RootRoute(), '/index.html');

  // Serve all files in the web/static relative directory under /web.
  // These are used by the default web page.
  pod.webServer.addRoute(
    StaticRoute.withCacheBusting(cacheBustingConfig),
    cacheBustingConfig.mountPrefix,
  );

  // Setup the app config route.
  // We build this configuration based on the servers api url and serve it to
  // the flutter app.
  pod.webServer.addRoute(
    AppConfigRoute(apiConfig: pod.config.apiServer),
    '/app/assets/assets/config.json',
  );

  // Checks if the flutter web app has been built and serves it if it has.
  final appDir = Directory(Uri(path: 'web/app').toFilePath());
  if (appDir.existsSync()) {
    // Serve the flutter web app under the /app path.
    pod.webServer.addRoute(
      FlutterRoute(
        appDir,
        // If building the Flutter app with WASM, set the below parameter to
        // true and add the --wasm flag to the flutter build command.
        enableWasmHeaders: false,
      ),
      '/app',
    );
  } else {
    // If the flutter web app has not been built, serve the build app page.
    final defaultRoute = StaticRoute.file(
      File(
        Uri(path: 'web/pages/build_flutter_app.html').toFilePath(),
      ),
    );

    pod.webServer.addRoute(
      defaultRoute,
      '/app/**',
    );
  }

  // Configure cloud storage.
  // This setup works with Serverpod Cloud without extra configuration.
  // If you want to use a custom provider for cloud storage, replace these
  // with your preferred provider.
  pod.addCloudStorage(
    await ServerpodCloudProvider.private(
      fallback: () => DatabaseCloudStorage('private'),
    ),
  );
  pod.addCloudStorage(
    await ServerpodCloudProvider.public(
      fallback: () => DatabaseCloudStorage('public'),
    ),
  );

  // Start the server.
  await pod.start();
}
