import 'package:database_broker/database_broker.dart';
import 'package:sqflite/sqflite.dart';

abstract interface class SqlBroker {
  const SqlBroker();

  Future<JobDone> openSqliteDatabase({
    List<String>? onCreateQueries,
    List<String>? onUpgradeQueries,
  });

  Future<JobDone> closeSqliteDatabase();

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

  Future<bool> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm conflictAlgorithm,
  });

  Future<bool> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  });

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

  Future<int> countRows(String table);
}
