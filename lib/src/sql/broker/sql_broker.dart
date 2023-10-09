import 'package:database_broker/database_broker.dart';
import 'package:sqflite/sqflite.dart';

abstract interface class SqlBroker {
  const SqlBroker();

  /// Returns the full path of the SQLite database.
  Future<String> getSqliteDatabaseFullPath();

  /// Opens a SQLite database and returns a [Future] that completes
  /// with a [JobDone] object.
  ///
  /// The optional [createTableQueries] parameter is a list
  /// of [CreateTableWrapper] that will be executed
  /// after the database is opened. If no queries are provided, the database
  ///  will be opened without creating any tables.
  Future<JobDone> openSqliteDatabase({
    List<CreateTableWrapper>? createTableQueries,
  });

  /// Closes the SQLite database connection.
  Future<JobDone> closeSqliteDatabase();

  /// Reads data from the specified [table] in the database.
  ///
  /// Returns a [Future] that completes with a list of maps, where each map
  /// corresponds to a row in the table. The keys in the map are column names,
  /// and the values are the corresponding values in the row.
  ///
  /// Optional parameters:
  /// - [distinct]: Whether to return only distinct rows.
  /// - [columns]: A list of column names to return. If null, returns
  /// all columns.
  /// - [where]: A filter declaring which rows to return.
  /// - [whereArgs]: List of arguments to replace placeholders in
  /// the [where] filter.
  /// - [groupBy]: A filter declaring how to group rows.
  /// - [having]: A filter declare which groups to include in the result.
  /// - [orderBy]: How to order the rows.
  /// - [limit]: Maximum number of rows to return.
  /// - [offset]: Offset the start of the returned rows.
  Future<List<Map<String, Object?>>> read(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  });

  /// Reads the first row from the specified [table] in the database and
  /// returns it as a [Map] of column names to values.
  ///
  /// Optional parameters:
  /// * [distinct]: Whether to return only distinct rows.
  /// * [columns]: The list of columns to return. Pass null to return
  /// all columns.
  /// * [where]: The selection criteria for rows. Pass null to return all rows.
  /// * [whereArgs]: The values to replace the placeholders in [where].
  /// * [groupBy]: A string specifying how to group rows into groups.
  /// * [having]: The selection criteria for groups.
  /// * [orderBy]: A string specifying how to sort rows.
  /// * [limit]: The maximum number of rows to return.
  /// * [offset]: The offset from the beginning of the result set at which
  /// to start returning rows.
  ///
  /// Returns a [Future] that completes with a [Map] of column names to
  /// values for the first row, or null if the table is empty.
  Future<Map<String, Object?>> readFirst(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  });

  /// Inserts a row into the specified table using the provided [values].
  ///
  /// If the [nullColumnHack] parameter is provided, it specifies the name of a
  /// nullable column in the table that can be used to insert a NULL value into
  /// the database in the case where the [values] map is empty.
  ///
  /// The [conflictAlgorithm] parameter specifies how conflicts with existing
  /// rows should be handled. If it is not provided, the default conflict
  /// algorithm is [ConflictAlgorithm.abort].
  ///
  /// Returns `true` if the insert was successful, `false` otherwise.
  Future<bool> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm conflictAlgorithm,
  });

  /// Updates a row(s) in the specified [table] with the given [values].
  ///
  /// If [where] is specified, only rows matching the given condition
  ///  will be updated.
  ///
  /// If [whereArgs] is specified, it provides values for placeholders
  ///  in the [where] clause.
  ///
  /// If [conflictAlgorithm] is specified, it determines how conflicts
  ///  with existing rows are handled.
  ///
  /// Returns `true` if one or more rows were updated, `false` otherwise.
  Future<bool> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  });

  /// Deletes rows from the specified table based on the given conditions.
  ///
  /// Returns `true` if one or more rows were deleted, `false` otherwise.
  ///
  /// The `table` parameter specifies the name of the table to delete from.
  ///
  /// The `where` parameter specifies the optional WHERE clause to
  ///  apply when deleting.
  ///
  /// The `whereArgs` parameter specifies the optional list of arguments
  ///  to replace placeholders in the `where` clause.
  Future<bool> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  });

  /// Executes a raw SQL query with optional arguments and returns
  /// a [Future] that completes with a [JobDone] object.
  ///
  /// The [sql] parameter is the raw SQL query to execute.
  ///
  /// The [arguments] parameter is an optional list of arguments
  ///  to replace placeholders in the [sql] query.
  ///
  /// Example usage:
  /// ```dart
  /// final result = await excuteRawQuery(
  ///   'SELECT * FROM users WHERE age > ?', [18],
  /// );
  /// ```
  Future<JobDone> excuteRawQuery(String sql, [List<Object?>? arguments]);

  /// Returns the number of rows in the specified [table].
  Future<int> countRows(String table);
}
