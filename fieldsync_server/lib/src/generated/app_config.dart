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

abstract class AppConfig
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  AppConfig._({
    this.id,
    required this.key,
    required this.value,
  });

  factory AppConfig({
    int? id,
    required String key,
    required String value,
  }) = _AppConfigImpl;

  factory AppConfig.fromJson(Map<String, dynamic> jsonSerialization) {
    return AppConfig(
      id: jsonSerialization['id'] as int?,
      key: jsonSerialization['key'] as String,
      value: jsonSerialization['value'] as String,
    );
  }

  static final t = AppConfigTable();

  static const db = AppConfigRepository._();

  @override
  int? id;

  String key;

  String value;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [AppConfig]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AppConfig copyWith({
    int? id,
    String? key,
    String? value,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppConfig',
      if (id != null) 'id': id,
      'key': key,
      'value': value,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AppConfig',
      if (id != null) 'id': id,
      'key': key,
      'value': value,
    };
  }

  static AppConfigInclude include() {
    return AppConfigInclude._();
  }

  static AppConfigIncludeList includeList({
    _is.WhereExpressionBuilder<AppConfigTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AppConfigTable>? orderBy,
    _is.OrderByListBuilder<AppConfigTable>? orderByList,
    AppConfigInclude? include,
  }) {
    return AppConfigIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AppConfig.t),
      orderByList: orderByList?.call(AppConfig.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AppConfigImpl extends AppConfig {
  _AppConfigImpl({
    int? id,
    required String key,
    required String value,
  }) : super._(
         id: id,
         key: key,
         value: value,
       );

  /// Returns a shallow copy of this [AppConfig]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AppConfig copyWith({
    Object? id = _Undefined,
    String? key,
    String? value,
  }) {
    return AppConfig(
      id: id is int? ? id : this.id,
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }
}

class AppConfigUpdateTable extends _is.UpdateTable<AppConfigTable> {
  AppConfigUpdateTable(super.table);

  _is.ColumnValue<String, String> key(String value) => _is.ColumnValue(
    table.key,
    value,
  );

  _is.ColumnValue<String, String> value(String value) => _is.ColumnValue(
    table.value,
    value,
  );
}

class AppConfigTable extends _is.Table<int?> {
  AppConfigTable({super.tableRelation}) : super(tableName: 'app_config') {
    updateTable = AppConfigUpdateTable(this);
    key = _is.ColumnString(
      'key',
      this,
    );
    value = _is.ColumnString(
      'value',
      this,
    );
  }

  late final AppConfigUpdateTable updateTable;

  late final _is.ColumnString key;

  late final _is.ColumnString value;

  @override
  List<_is.Column> get columns => [
    id,
    key,
    value,
  ];
}

class AppConfigInclude extends _is.IncludeObject {
  AppConfigInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => AppConfig.t;
}

class AppConfigIncludeList extends _is.IncludeList {
  AppConfigIncludeList._({
    _is.WhereExpressionBuilder<AppConfigTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AppConfig.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => AppConfig.t;
}

class AppConfigRepository {
  const AppConfigRepository._();

  /// Returns a list of [AppConfig]s matching the given query parameters.
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
  Future<List<AppConfig>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AppConfigTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AppConfigTable>? orderBy,
    _is.OrderByListBuilder<AppConfigTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AppConfig>(
      where: where?.call(AppConfig.t),
      orderBy: orderBy?.call(AppConfig.t),
      orderByList: orderByList?.call(AppConfig.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AppConfig] matching the given query parameters.
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
  Future<AppConfig?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AppConfigTable>? where,
    int? offset,
    _is.OrderByBuilder<AppConfigTable>? orderBy,
    _is.OrderByListBuilder<AppConfigTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AppConfig>(
      where: where?.call(AppConfig.t),
      orderBy: orderBy?.call(AppConfig.t),
      orderByList: orderByList?.call(AppConfig.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AppConfig] by its [id] or null if no such row exists.
  Future<AppConfig?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AppConfig>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AppConfig]s in the list and returns the inserted rows.
  ///
  /// The returned [AppConfig]s will have their `id` fields set.
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
  Future<List<AppConfig>> insert(
    _is.DatabaseSession session,
    List<AppConfig> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AppConfig>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AppConfig] and returns the inserted row.
  ///
  /// The returned [AppConfig] will have its `id` field set.
  Future<AppConfig> insertRow(
    _is.DatabaseSession session,
    AppConfig row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AppConfig>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AppConfig]s in the list and returns the resulting rows.
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
  /// The returned [AppConfig]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AppConfig>> upsert(
    _is.DatabaseSession session,
    List<AppConfig> rows, {
    required _is.ColumnSelections<AppConfigTable> conflictColumns,
    _is.ColumnSelections<AppConfigTable>? updateColumns,
    _is.WhereExpressionBuilder<AppConfigTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AppConfig>(
      rows,
      conflictColumns: conflictColumns(AppConfig.t),
      updateColumns: updateColumns?.call(AppConfig.t),
      updateWhere: updateWhere?.call(AppConfig.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AppConfig] and returns the resulting row.
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
  /// The returned [AppConfig] will have its `id` field set.
  Future<AppConfig?> upsertRow(
    _is.DatabaseSession session,
    AppConfig row, {
    required _is.ColumnSelections<AppConfigTable> conflictColumns,
    _is.ColumnSelections<AppConfigTable>? updateColumns,
    _is.WhereExpressionBuilder<AppConfigTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AppConfig>(
      row,
      conflictColumns: conflictColumns(AppConfig.t),
      updateColumns: updateColumns?.call(AppConfig.t),
      updateWhere: updateWhere?.call(AppConfig.t),
      transaction: transaction,
    );
  }

  /// Updates all [AppConfig]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AppConfig>> update(
    _is.DatabaseSession session,
    List<AppConfig> rows, {
    _is.ColumnSelections<AppConfigTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AppConfig>(
      rows,
      columns: columns?.call(AppConfig.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AppConfig]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AppConfig> updateRow(
    _is.DatabaseSession session,
    AppConfig row, {
    _is.ColumnSelections<AppConfigTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AppConfig>(
      row,
      columns: columns?.call(AppConfig.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AppConfig] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AppConfig?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<AppConfigUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AppConfig>(
      id,
      columnValues: columnValues(AppConfig.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AppConfig]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AppConfig>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AppConfigUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<AppConfigTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AppConfigTable>? orderBy,
    _is.OrderByListBuilder<AppConfigTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AppConfig>(
      columnValues: columnValues(AppConfig.t.updateTable),
      where: where(AppConfig.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AppConfig.t),
      orderByList: orderByList?.call(AppConfig.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AppConfig]s in the list and returns the deleted rows.
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
  Future<List<AppConfig>> delete(
    _is.DatabaseSession session,
    List<AppConfig> rows, {
    _is.OrderByBuilder<AppConfigTable>? orderBy,
    _is.OrderByListBuilder<AppConfigTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AppConfig>(
      rows,
      orderBy: orderBy?.call(AppConfig.t),
      orderByList: orderByList?.call(AppConfig.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AppConfig].
  Future<AppConfig> deleteRow(
    _is.DatabaseSession session,
    AppConfig row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AppConfig>(
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
  Future<List<AppConfig>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AppConfigTable> where,
    _is.OrderByBuilder<AppConfigTable>? orderBy,
    _is.OrderByListBuilder<AppConfigTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AppConfig>(
      where: where(AppConfig.t),
      orderBy: orderBy?.call(AppConfig.t),
      orderByList: orderByList?.call(AppConfig.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AppConfigTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AppConfig>(
      where: where?.call(AppConfig.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AppConfig] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AppConfigTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AppConfig>(
      where: where(AppConfig.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
