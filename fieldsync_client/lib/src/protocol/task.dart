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
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'package:serverpod_database/serverpod_database.dart' as _isd;

abstract class Task
    implements _isd.TableRow<_isc.UuidValue?>, _isc.ProtocolSerialization {
  Task._({
    this.id,
    this.spaceId,
    required this.title,
    required this.status,
    this.assigneeId,
    this.notes,
    this.photoPath,
    required this.updatedAt,
  });

  factory Task({
    _isc.UuidValue? id,
    int? spaceId,
    required String title,
    required String status,
    _isc.UuidValue? assigneeId,
    String? notes,
    String? photoPath,
    required DateTime updatedAt,
  }) = _TaskImpl;

  factory Task.fromJson(Map<String, dynamic> jsonSerialization) {
    return Task(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      spaceId: jsonSerialization['spaceId'] as int?,
      title: jsonSerialization['title'] as String,
      status: jsonSerialization['status'] as String,
      assigneeId: jsonSerialization['assigneeId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['assigneeId'],
            ),
      notes: jsonSerialization['notes'] as String?,
      photoPath: jsonSerialization['photoPath'] as String?,
      updatedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = TaskTable();

  static const db = TaskRepository._();

  @override
  _isc.UuidValue? id;

  /// The space owning this row. Maintained by the sync engine.
  int? spaceId;

  String title;

  String status;

  _isc.UuidValue? assigneeId;

  String? notes;

  String? photoPath;

  DateTime updatedAt;

  @override
  _isd.Table<_isc.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Task]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Task copyWith({
    _isc.UuidValue? id,
    int? spaceId,
    String? title,
    String? status,
    _isc.UuidValue? assigneeId,
    String? notes,
    String? photoPath,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Task',
      if (id != null) 'id': id?.toJson(),
      if (spaceId != null) 'spaceId': spaceId,
      'title': title,
      'status': status,
      if (assigneeId != null) 'assigneeId': assigneeId?.toJson(),
      if (notes != null) 'notes': notes,
      if (photoPath != null) 'photoPath': photoPath,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Task',
      if (id != null) 'id': id?.toJson(),
      if (spaceId != null) 'spaceId': spaceId,
      'title': title,
      'status': status,
      if (assigneeId != null) 'assigneeId': assigneeId?.toJson(),
      if (notes != null) 'notes': notes,
      if (photoPath != null) 'photoPath': photoPath,
      'updatedAt': updatedAt.toJson(),
    };
  }

  static TaskInclude include() {
    return TaskInclude._();
  }

  static TaskIncludeList includeList({
    _isd.WhereExpressionBuilder<TaskTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<TaskTable>? orderBy,
    _isd.OrderByListBuilder<TaskTable>? orderByList,
    TaskInclude? include,
  }) {
    return TaskIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Task.t),
      orderByList: orderByList?.call(Task.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TaskImpl extends Task {
  _TaskImpl({
    _isc.UuidValue? id,
    int? spaceId,
    required String title,
    required String status,
    _isc.UuidValue? assigneeId,
    String? notes,
    String? photoPath,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         spaceId: spaceId,
         title: title,
         status: status,
         assigneeId: assigneeId,
         notes: notes,
         photoPath: photoPath,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Task]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Task copyWith({
    Object? id = _Undefined,
    Object? spaceId = _Undefined,
    String? title,
    String? status,
    Object? assigneeId = _Undefined,
    Object? notes = _Undefined,
    Object? photoPath = _Undefined,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id is _isc.UuidValue? ? id : this.id,
      spaceId: spaceId is int? ? spaceId : this.spaceId,
      title: title ?? this.title,
      status: status ?? this.status,
      assigneeId: assigneeId is _isc.UuidValue? ? assigneeId : this.assigneeId,
      notes: notes is String? ? notes : this.notes,
      photoPath: photoPath is String? ? photoPath : this.photoPath,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TaskUpdateTable extends _isd.UpdateTable<TaskTable> {
  TaskUpdateTable(super.table);

  _isd.ColumnValue<int, int> spaceId(int? value) => _isd.ColumnValue(
    table.spaceId,
    value,
  );

  _isd.ColumnValue<String, String> title(String value) => _isd.ColumnValue(
    table.title,
    value,
  );

  _isd.ColumnValue<String, String> status(String value) => _isd.ColumnValue(
    table.status,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> assigneeId(
    _isc.UuidValue? value,
  ) => _isd.ColumnValue(
    table.assigneeId,
    value,
  );

  _isd.ColumnValue<String, String> notes(String? value) => _isd.ColumnValue(
    table.notes,
    value,
  );

  _isd.ColumnValue<String, String> photoPath(String? value) => _isd.ColumnValue(
    table.photoPath,
    value,
  );

  _isd.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _isd.ColumnValue(
        table.updatedAt,
        value,
      );
}

class TaskTable extends _isd.Table<_isc.UuidValue?> {
  TaskTable({super.tableRelation}) : super(tableName: 'task') {
    updateTable = TaskUpdateTable(this);
    spaceId = _isd.ColumnInt(
      'spaceId',
      this,
    );
    title = _isd.ColumnString(
      'title',
      this,
    );
    status = _isd.ColumnString(
      'status',
      this,
    );
    assigneeId = _isd.ColumnUuid(
      'assigneeId',
      this,
    );
    notes = _isd.ColumnString(
      'notes',
      this,
    );
    photoPath = _isd.ColumnString(
      'photoPath',
      this,
    );
    updatedAt = _isd.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final TaskUpdateTable updateTable;

  /// The space owning this row. Maintained by the sync engine.
  late final _isd.ColumnInt spaceId;

  late final _isd.ColumnString title;

  late final _isd.ColumnString status;

  late final _isd.ColumnUuid assigneeId;

  late final _isd.ColumnString notes;

  late final _isd.ColumnString photoPath;

  late final _isd.ColumnDateTime updatedAt;

  @override
  List<_isd.Column> get columns => [
    id,
    spaceId,
    title,
    status,
    assigneeId,
    notes,
    photoPath,
    updatedAt,
  ];
}

class TaskInclude extends _isd.IncludeObject {
  TaskInclude._();

  @override
  Map<String, _isd.Include?> get includes => {};

  @override
  _isd.Table<_isc.UuidValue?> get table => Task.t;
}

class TaskIncludeList extends _isd.IncludeList {
  TaskIncludeList._({
    _isd.WhereExpressionBuilder<TaskTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Task.t);
  }

  @override
  Map<String, _isd.Include?> get includes => include?.includes ?? {};

  @override
  _isd.Table<_isc.UuidValue?> get table => Task.t;
}

class TaskRepository {
  const TaskRepository._();

  /// Returns a list of [Task]s matching the given query parameters.
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
  Future<List<Task>> find(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<TaskTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<TaskTable>? orderBy,
    _isd.OrderByListBuilder<TaskTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Task>(
      where: where?.call(Task.t),
      orderBy: orderBy?.call(Task.t),
      orderByList: orderByList?.call(Task.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Task] matching the given query parameters.
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
  Future<Task?> findFirstRow(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<TaskTable>? where,
    int? offset,
    _isd.OrderByBuilder<TaskTable>? orderBy,
    _isd.OrderByListBuilder<TaskTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Task>(
      where: where?.call(Task.t),
      orderBy: orderBy?.call(Task.t),
      orderByList: orderByList?.call(Task.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Task] by its [id] or null if no such row exists.
  Future<Task?> findById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Task>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Task]s in the list and returns the inserted rows.
  ///
  /// The returned [Task]s will have their `id` fields set.
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
  Future<List<Task>> insert(
    _isd.DatabaseSession session,
    List<Task> rows, {
    _isd.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Task>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Task] and returns the inserted row.
  ///
  /// The returned [Task] will have its `id` field set.
  Future<Task> insertRow(
    _isd.DatabaseSession session,
    Task row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.insertRow<Task>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Task]s in the list and returns the resulting rows.
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
  /// The returned [Task]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Task>> upsert(
    _isd.DatabaseSession session,
    List<Task> rows, {
    required _isd.ColumnSelections<TaskTable> conflictColumns,
    _isd.ColumnSelections<TaskTable>? updateColumns,
    _isd.WhereExpressionBuilder<TaskTable>? updateWhere,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Task>(
      rows,
      conflictColumns: conflictColumns(Task.t),
      updateColumns: updateColumns?.call(Task.t),
      updateWhere: updateWhere?.call(Task.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Task] and returns the resulting row.
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
  /// The returned [Task] will have its `id` field set.
  Future<Task?> upsertRow(
    _isd.DatabaseSession session,
    Task row, {
    required _isd.ColumnSelections<TaskTable> conflictColumns,
    _isd.ColumnSelections<TaskTable>? updateColumns,
    _isd.WhereExpressionBuilder<TaskTable>? updateWhere,
    _isd.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Task>(
      row,
      conflictColumns: conflictColumns(Task.t),
      updateColumns: updateColumns?.call(Task.t),
      updateWhere: updateWhere?.call(Task.t),
      transaction: transaction,
    );
  }

  /// Updates all [Task]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Task>> update(
    _isd.DatabaseSession session,
    List<Task> rows, {
    _isd.ColumnSelections<TaskTable>? columns,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Task>(
      rows,
      columns: columns?.call(Task.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Task]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Task> updateRow(
    _isd.DatabaseSession session,
    Task row, {
    _isd.ColumnSelections<TaskTable>? columns,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateRow<Task>(
      row,
      columns: columns?.call(Task.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Task] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Task?> updateById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    required _isd.ColumnValueListBuilder<TaskUpdateTable> columnValues,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateById<Task>(
      id,
      columnValues: columnValues(Task.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Task]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Task>> updateWhere(
    _isd.DatabaseSession session, {
    required _isd.ColumnValueListBuilder<TaskUpdateTable> columnValues,
    required _isd.WhereExpressionBuilder<TaskTable> where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<TaskTable>? orderBy,
    _isd.OrderByListBuilder<TaskTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Task>(
      columnValues: columnValues(Task.t.updateTable),
      where: where(Task.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Task.t),
      orderByList: orderByList?.call(Task.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Task]s in the list and returns the deleted rows.
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
  Future<List<Task>> delete(
    _isd.DatabaseSession session,
    List<Task> rows, {
    _isd.OrderByBuilder<TaskTable>? orderBy,
    _isd.OrderByListBuilder<TaskTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Task>(
      rows,
      orderBy: orderBy?.call(Task.t),
      orderByList: orderByList?.call(Task.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Task].
  Future<Task> deleteRow(
    _isd.DatabaseSession session,
    Task row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Task>(
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
  Future<List<Task>> deleteWhere(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<TaskTable> where,
    _isd.OrderByBuilder<TaskTable>? orderBy,
    _isd.OrderByListBuilder<TaskTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Task>(
      where: where(Task.t),
      orderBy: orderBy?.call(Task.t),
      orderByList: orderByList?.call(Task.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<TaskTable>? where,
    int? limit,
    _isd.Transaction? transaction,
  }) async {
    return session.db.count<Task>(
      where: where?.call(Task.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Task] rows matching the [where] expression.
  Future<void> lockRows(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<TaskTable> where,
    required _isd.LockMode lockMode,
    required _isd.Transaction transaction,
    _isd.LockBehavior lockBehavior = _isd.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Task>(
      where: where(Task.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
