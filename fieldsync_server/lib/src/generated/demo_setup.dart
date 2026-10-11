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
import 'package:serverpod/serverpod.dart' as _is;

abstract class DemoSetup
    implements _is.SerializableModel, _is.ProtocolSerialization {
  DemoSetup._({
    required this.supervisorId,
    required this.workerId,
    required this.teamSpaceId,
  });

  factory DemoSetup({
    required _is.UuidValue supervisorId,
    required _is.UuidValue workerId,
    required _is.UuidValue teamSpaceId,
  }) = _DemoSetupImpl;

  factory DemoSetup.fromJson(Map<String, dynamic> jsonSerialization) {
    return DemoSetup(
      supervisorId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['supervisorId'],
      ),
      workerId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['workerId'],
      ),
      teamSpaceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['teamSpaceId'],
      ),
    );
  }

  _is.UuidValue supervisorId;

  _is.UuidValue workerId;

  _is.UuidValue teamSpaceId;

  /// Returns a shallow copy of this [DemoSetup]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DemoSetup copyWith({
    _is.UuidValue? supervisorId,
    _is.UuidValue? workerId,
    _is.UuidValue? teamSpaceId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DemoSetup',
      'supervisorId': supervisorId.toJson(),
      'workerId': workerId.toJson(),
      'teamSpaceId': teamSpaceId.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DemoSetup',
      'supervisorId': supervisorId.toJson(),
      'workerId': workerId.toJson(),
      'teamSpaceId': teamSpaceId.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _DemoSetupImpl extends DemoSetup {
  _DemoSetupImpl({
    required _is.UuidValue supervisorId,
    required _is.UuidValue workerId,
    required _is.UuidValue teamSpaceId,
  }) : super._(
         supervisorId: supervisorId,
         workerId: workerId,
         teamSpaceId: teamSpaceId,
       );

  /// Returns a shallow copy of this [DemoSetup]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DemoSetup copyWith({
    _is.UuidValue? supervisorId,
    _is.UuidValue? workerId,
    _is.UuidValue? teamSpaceId,
  }) {
    return DemoSetup(
      supervisorId: supervisorId ?? this.supervisorId,
      workerId: workerId ?? this.workerId,
      teamSpaceId: teamSpaceId ?? this.teamSpaceId,
    );
  }
}
