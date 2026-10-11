/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _idt;
import 'package:fieldsync_server/src/generated/future_calls.dart' as _iq5lo2h0;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_offline_sync_server/serverpod_offline_sync_server.dart'
    as _izehhkf5;
import '../endpoints/setup_endpoint.dart' as _i5xhv8r1;
import '../endpoints/task_endpoint.dart' as _idmllfay;
import '../greetings/greeting_endpoint.dart' as _il624ik7;
export 'future_calls.dart' show ServerpodFutureCallsGetter;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'setup': _i5xhv8r1.SetupEndpoint()
        ..initialize(
          server,
          'setup',
          null,
        ),
      'task': _idmllfay.TaskEndpoint()
        ..initialize(
          server,
          'task',
          null,
        ),
      'greeting': _il624ik7.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
    };
    connectors['setup'] = _is.EndpointConnector(
      name: 'setup',
      endpoint: endpoints['setup']!,
      methodConnectors: {
        'getOrCreateDemoTeam': _is.MethodConnector(
          name: 'getOrCreateDemoTeam',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['setup'] as _i5xhv8r1.SetupEndpoint)
                  .getOrCreateDemoTeam(session),
        ),
      },
    );
    connectors['task'] = _is.EndpointConnector(
      name: 'task',
      endpoint: endpoints['task']!,
      methodConnectors: {
        'createTask': _is.MethodConnector(
          name: 'createTask',
          params: {
            'title': _is.ParameterDescription(
              name: 'title',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'assigneeId': _is.ParameterDescription(
              name: 'assigneeId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'notes': _is.ParameterDescription(
              name: 'notes',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'teamSpaceId': _is.ParameterDescription(
              name: 'teamSpaceId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'actorId': _is.ParameterDescription(
              name: 'actorId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'escalationAfterMinutes': _is.ParameterDescription(
              name: 'escalationAfterMinutes',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['task'] as _idmllfay.TaskEndpoint).createTask(
                    session,
                    title: params['title'],
                    assigneeId: params['assigneeId'],
                    notes: params['notes'],
                    teamSpaceId: params['teamSpaceId'],
                    actorId: params['actorId'],
                    escalationAfterMinutes: params['escalationAfterMinutes'],
                  ),
        ),
        'uploadEvidencePhoto': _is.MethodConnector(
          name: 'uploadEvidencePhoto',
          params: {
            'data': _is.ParameterDescription(
              name: 'data',
              type: _is.getType<_idt.ByteData>(),
              nullable: false,
            ),
            'fileName': _is.ParameterDescription(
              name: 'fileName',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['task'] as _idmllfay.TaskEndpoint)
                  .uploadEvidencePhoto(
                    session,
                    params['data'],
                    params['fileName'],
                  ),
        ),
      },
    );
    connectors['greeting'] = _is.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _is.MethodConnector(
          name: 'hello',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['greeting'] as _il624ik7.GreetingEndpoint).hello(
                    session,
                    params['name'],
                  ),
        ),
      },
    );
    modules['serverpod_offline_sync'] = _izehhkf5.Endpoints()
      ..initializeEndpoints(server);
  }

  @override
  _is.FutureCallDispatch? get futureCalls {
    return _iq5lo2h0.FutureCalls();
  }
}
