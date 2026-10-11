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

abstract class EscalationCheck
    implements _is.SerializableModel, _is.ProtocolSerialization {
  EscalationCheck._({
    required this.taskId,
    required this.teamSpaceId,
    required this.actorId,
  });

  factory EscalationCheck({
    required _is.UuidValue taskId,
    required _is.UuidValue teamSpaceId,
    required _is.UuidValue actorId,
  }) = _EscalationCheckImpl;

  factory EscalationCheck.fromJson(Map<String, dynamic> jsonSerialization) {
    return EscalationCheck(
      taskId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['taskId']),
      teamSpaceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['teamSpaceId'],
      ),
      actorId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['actorId'],
      ),
    );
  }

  _is.UuidValue taskId;

  _is.UuidValue teamSpaceId;

  _is.UuidValue actorId;

  /// Returns a shallow copy of this [EscalationCheck]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  EscalationCheck copyWith({
    _is.UuidValue? taskId,
    _is.UuidValue? teamSpaceId,
    _is.UuidValue? actorId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EscalationCheck',
      'taskId': taskId.toJson(),
      'teamSpaceId': teamSpaceId.toJson(),
      'actorId': actorId.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'EscalationCheck',
      'taskId': taskId.toJson(),
      'teamSpaceId': teamSpaceId.toJson(),
      'actorId': actorId.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _EscalationCheckImpl extends EscalationCheck {
  _EscalationCheckImpl({
    required _is.UuidValue taskId,
    required _is.UuidValue teamSpaceId,
    required _is.UuidValue actorId,
  }) : super._(
         taskId: taskId,
         teamSpaceId: teamSpaceId,
         actorId: actorId,
       );

  /// Returns a shallow copy of this [EscalationCheck]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  EscalationCheck copyWith({
    _is.UuidValue? taskId,
    _is.UuidValue? teamSpaceId,
    _is.UuidValue? actorId,
  }) {
    return EscalationCheck(
      taskId: taskId ?? this.taskId,
      teamSpaceId: teamSpaceId ?? this.teamSpaceId,
      actorId: actorId ?? this.actorId,
    );
  }
}
