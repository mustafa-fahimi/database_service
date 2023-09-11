import 'package:dartz/dartz.dart';
import 'package:database_broker/database_broker.dart';
import 'package:sqflite/sqflite.dart';

abstract class SqlDatabaseBroker {
  const SqlDatabaseBroker();

  Future<String> getSqliteDatabaseFullPath();

  Future<Either<DatabaseFailure, Database>> openSqliteDatabase({
    String? onCreateQuery,
  });

  Future<Either<DatabaseFailure, JustOk>> closeSqliteDatabase();

  Future<Either<DatabaseFailure, List<Map<String, Object?>>>> read(
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

  Future<Either<DatabaseFailure, Map<String, Object?>>> readFirst(
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

  Future<Either<DatabaseFailure, bool>> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  });

  Future<Either<DatabaseFailure, bool>> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  });

  Future<Either<DatabaseFailure, bool>> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  });

  Future<Either<DatabaseFailure, JustOk>> excuteRawQuery(
    String sql, [
    List<Object?>? arguments,
  ]);

  Future<Either<DatabaseFailure, int>> countRows(String table);
}
