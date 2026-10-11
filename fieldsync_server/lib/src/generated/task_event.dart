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

abstract class TaskEvent
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  TaskEvent._({
    this.id,
    this.spaceId,
    required this.taskId,
    required this.kind,
    required this.message,
    required this.createdAt,
  });

  factory TaskEvent({
    _is.UuidValue? id,
    int? spaceId,
    required _is.UuidValue taskId,
    required String kind,
    required String message,
    required DateTime createdAt,
  }) = _TaskEventImpl;

  factory TaskEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return TaskEvent(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      spaceId: jsonSerialization['spaceId'] as int?,
      taskId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['taskId']),
      kind: jsonSerialization['kind'] as String,
      message: jsonSerialization['message'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = TaskEventTable();

  static const db = TaskEventRepository._();

  @override
  _is.UuidValue? id;

  /// The space owning this row. Maintained by the sync engine.
  int? spaceId;

  _is.UuidValue taskId;

  String kind;

  String message;

  DateTime createdAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [TaskEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TaskEvent copyWith({
    _is.UuidValue? id,
    int? spaceId,
    _is.UuidValue? taskId,
    String? kind,
    String? message,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TaskEvent',
      if (id != null) 'id': id?.toJson(),
      if (spaceId != null) 'spaceId': spaceId,
      'taskId': taskId.toJson(),
      'kind': kind,
      'message': message,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TaskEvent',
      if (id != null) 'id': id?.toJson(),
      if (spaceId != null) 'spaceId': spaceId,
      'taskId': taskId.toJson(),
      'kind': kind,
      'message': message,
      'createdAt': createdAt.toJson(),
    };
  }

  static TaskEventInclude include() {
    return TaskEventInclude._();
  }

  static TaskEventIncludeList includeList({
    _is.WhereExpressionBuilder<TaskEventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TaskEventTable>? orderBy,
    _is.OrderByListBuilder<TaskEventTable>? orderByList,
    TaskEventInclude? include,
  }) {
    return TaskEventIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TaskEvent.t),
      orderByList: orderByList?.call(TaskEvent.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TaskEventImpl extends TaskEvent {
  _TaskEventImpl({
    _is.UuidValue? id,
    int? spaceId,
    required _is.UuidValue taskId,
    required String kind,
    required String message,
    required DateTime createdAt,
  }) : super._(
         id: id,
         spaceId: spaceId,
         taskId: taskId,
         kind: kind,
         message: message,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [TaskEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TaskEvent copyWith({
    Object? id = _Undefined,
    Object? spaceId = _Undefined,
    _is.UuidValue? taskId,
    String? kind,
    String? message,
    DateTime? createdAt,
  }) {
    return TaskEvent(
      id: id is _is.UuidValue? ? id : this.id,
      spaceId: spaceId is int? ? spaceId : this.spaceId,
      taskId: taskId ?? this.taskId,
      kind: kind ?? this.kind,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class TaskEventUpdateTable extends _is.UpdateTable<TaskEventTable> {
  TaskEventUpdateTable(super.table);

  _is.ColumnValue<int, int> spaceId(int? value) => _is.ColumnValue(
    table.spaceId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> taskId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.taskId,
        value,
      );

  _is.ColumnValue<String, String> kind(String value) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<String, String> message(String value) => _is.ColumnValue(
    table.message,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class TaskEventTable extends _is.Table<_is.UuidValue?> {
  TaskEventTable({super.tableRelation}) : super(tableName: 'task_event') {
    updateTable = TaskEventUpdateTable(this);
    spaceId = _is.ColumnInt(
      'spaceId',
      this,
    );
    taskId = _is.ColumnUuid(
      'taskId',
      this,
    );
    kind = _is.ColumnString(
      'kind',
      this,
    );
    message = _is.ColumnString(
      'message',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final TaskEventUpdateTable updateTable;

  /// The space owning this row. Maintained by the sync engine.
  late final _is.ColumnInt spaceId;

  late final _is.ColumnUuid taskId;

  late final _is.ColumnString kind;

  late final _is.ColumnString message;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    spaceId,
    taskId,
    kind,
    message,
    createdAt,
  ];
}

class TaskEventInclude extends _is.IncludeObject {
  TaskEventInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => TaskEvent.t;
}

class TaskEventIncludeList extends _is.IncludeList {
  TaskEventIncludeList._({
    _is.WhereExpressionBuilder<TaskEventTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(TaskEvent.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => TaskEvent.t;
}

class TaskEventRepository {
  const TaskEventRepository._();

  /// Returns a list of [TaskEvent]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<TaskEvent>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TaskEventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TaskEventTable>? orderBy,
    _is.OrderByListBuilder<TaskEventTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<TaskEvent>(
      where: where?.call(TaskEvent.t),
      orderBy: orderBy?.call(TaskEvent.t),
      orderByList: orderByList?.call(TaskEvent.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [TaskEvent] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<TaskEvent?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TaskEventTable>? where,
    int? offset,
    _is.OrderByBuilder<TaskEventTable>? orderBy,
    _is.OrderByListBuilder<TaskEventTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<TaskEvent>(
      where: where?.call(TaskEvent.t),
      orderBy: orderBy?.call(TaskEvent.t),
      orderByList: orderByList?.call(TaskEvent.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [TaskEvent] by its [id] or null if no such row exists.
  Future<TaskEvent?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<TaskEvent>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [TaskEvent]s in the list and returns the inserted rows.
  ///
  /// The returned [TaskEvent]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TaskEvent>> insert(
    _is.DatabaseSession session,
    List<TaskEvent> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<TaskEvent>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [TaskEvent] and returns the inserted row.
  ///
  /// The returned [TaskEvent] will have its `id` field set.
  Future<TaskEvent> insertRow(
    _is.DatabaseSession session,
    TaskEvent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<TaskEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [TaskEvent]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [TaskEvent]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TaskEvent>> upsert(
    _is.DatabaseSession session,
    List<TaskEvent> rows, {
    required _is.ColumnSelections<TaskEventTable> conflictColumns,
    _is.ColumnSelections<TaskEventTable>? updateColumns,
    _is.WhereExpressionBuilder<TaskEventTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<TaskEvent>(
      rows,
      conflictColumns: conflictColumns(TaskEvent.t),
      updateColumns: updateColumns?.call(TaskEvent.t),
      updateWhere: updateWhere?.call(TaskEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [TaskEvent] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [TaskEvent] will have its `id` field set.
  Future<TaskEvent?> upsertRow(
    _is.DatabaseSession session,
    TaskEvent row, {
    required _is.ColumnSelections<TaskEventTable> conflictColumns,
    _is.ColumnSelections<TaskEventTable>? updateColumns,
    _is.WhereExpressionBuilder<TaskEventTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<TaskEvent>(
      row,
      conflictColumns: conflictColumns(TaskEvent.t),
      updateColumns: updateColumns?.call(TaskEvent.t),
      updateWhere: updateWhere?.call(TaskEvent.t),
      transaction: transaction,
    );
  }

  /// Updates all [TaskEvent]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TaskEvent>> update(
    _is.DatabaseSession session,
    List<TaskEvent> rows, {
    _is.ColumnSelections<TaskEventTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<TaskEvent>(
      rows,
      columns: columns?.call(TaskEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [TaskEvent]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<TaskEvent> updateRow(
    _is.DatabaseSession session,
    TaskEvent row, {
    _is.ColumnSelections<TaskEventTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<TaskEvent>(
      row,
      columns: columns?.call(TaskEvent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TaskEvent] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<TaskEvent?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<TaskEventUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<TaskEvent>(
      id,
      columnValues: columnValues(TaskEvent.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [TaskEvent]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TaskEvent>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<TaskEventUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<TaskEventTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TaskEventTable>? orderBy,
    _is.OrderByListBuilder<TaskEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<TaskEvent>(
      columnValues: columnValues(TaskEvent.t.updateTable),
      where: where(TaskEvent.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TaskEvent.t),
      orderByList: orderByList?.call(TaskEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [TaskEvent]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TaskEvent>> delete(
    _is.DatabaseSession session,
    List<TaskEvent> rows, {
    _is.OrderByBuilder<TaskEventTable>? orderBy,
    _is.OrderByListBuilder<TaskEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<TaskEvent>(
      rows,
      orderBy: orderBy?.call(TaskEvent.t),
      orderByList: orderByList?.call(TaskEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [TaskEvent].
  Future<TaskEvent> deleteRow(
    _is.DatabaseSession session,
    TaskEvent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<TaskEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TaskEvent>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TaskEventTable> where,
    _is.OrderByBuilder<TaskEventTable>? orderBy,
    _is.OrderByListBuilder<TaskEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<TaskEvent>(
      where: where(TaskEvent.t),
      orderBy: orderBy?.call(TaskEvent.t),
      orderByList: orderByList?.call(TaskEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TaskEventTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<TaskEvent>(
      where: where?.call(TaskEvent.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [TaskEvent] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TaskEventTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<TaskEvent>(
      where: where(TaskEvent.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
