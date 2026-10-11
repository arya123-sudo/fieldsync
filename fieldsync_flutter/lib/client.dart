import 'dart:async';

import 'package:fieldsync_client/fieldsync_client.dart';
import 'package:serverpod_client/serverpod_client.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

import 'src/sync/demo_ids.dart';

// When you are running the app on a physical device, you need to set the
// server URL to the IP address of your computer. You can find the IP
// address by running `ipconfig` on Windows or `ifconfig` on Mac/Linux.
//
// You can set the variable when running or building your app like this:
// E.g. `flutter run --dart-define=SERVER_URL=https://api.example.com/`.
//
// Otherwise, the server URL is fetched from the assets/config.json file or
// defaults to http://$localhost:8080/ if not found.
final serverUrl = getServerUrl();

/// Sets up a global client object that can be used to talk to the server from
/// anywhere in our app. The client is generated from your server code
/// and is set up to connect to a Serverpod running on a local server on
/// the default port. You will need to modify this to connect to staging or
/// production servers.
/// In a larger app, you may want to use the dependency injection of your choice
/// instead of using a global client object. This is just a simple example.
late final Client client;

/// Demo auth: the offline-sync stream endpoint requires login, but this demo
/// has no auth system. We send the demo supervisor UUID as a Bearer token;
/// the server's authenticationHandler accepts the two demo UUIDs.
/// Sync always runs as supervisor; the supervisor/worker toggle only
/// filters the UI.
// TODO: replace with serverpod_auth before production use.
class _DemoAuthKeyProvider implements ClientAuthKeyProvider {
  @override
  Future<String?> get authHeaderValue async =>
      wrapAsBearerAuthHeaderValue(demoSupervisorId.toString());
}

Future<void> initializeClient() async {
  client = Client(await serverUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authKeyProvider = _DemoAuthKeyProvider();
}
