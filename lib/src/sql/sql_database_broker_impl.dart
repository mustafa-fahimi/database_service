import 'package:dartz/dartz.dart';
import 'package:database_broker/database_broker.dart';
import 'package:database_broker/src/common/common_database_exception.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqlDatabaseBrokerImpl implements SqlDatabaseBroker {
  SqlDatabaseBrokerImpl({
    required this.databaseFileName,
    this.databaseVersion = 1,
  }) : assert(
          databaseFileName.split('.').last == 'db',
          'File name format should be like this: Filename.db',
        );

  final String databaseFileName;
  final int databaseVersion;

  Database? database;

  @override
  Future<void> initializeSqliteDatabase() async {}

  @override
  Future<Either<DatabaseFailure, Database>> openSqliteDatabase({
    String? onCreateQuery,
  }) async {
    final databasePath = await getSqliteDatabaseFullPath();
    return openDatabase(
      databasePath,
      version: databaseVersion,
      onCreate: onCreateQuery == null
          ? null
          : (db, version) => db.execute(onCreateQuery),
    )
        .then(
          (Database database) => right<DatabaseFailure, Database>(database),
        )
        .catchError(
          (dynamic e) => left<DatabaseFailure, Database>(
            DatabaseFailure(message: e.toString()),
          ),
        );
  }

  @override
  Future<Either<DatabaseFailure, JustOk>> closeSqliteDatabase() async {
    if (database != null) {
      try {
        await database!.close();
        return right(const JustOk());
      } catch (e) {
        return left(DatabaseFailure(message: e.toString()));
      }
    } else {
      return left(const DatabaseFailure(message: 'Database was null'));
    }
  }

  @override
  Future<String> getSqliteDatabaseFullPath() async {
    return getDatabasesPath()
        .then(
          (path) => join(path, databaseFileName),
        )
        .catchError(
          (dynamic e) => throw CommonDatabaseException(
            error: e.toString(),
          ),
        );
  }

  @override
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
  }) async =>
      database!
          .query(
            table,
            distinct: distinct,
            columns: columns,
            where: where,
            whereArgs: whereArgs,
            groupBy: groupBy,
            having: having,
            orderBy: orderBy,
            limit: limit,
            offset: offset,
          )
          .then(
            (queryResult) => right<DatabaseFailure, List<Map<String, Object?>>>(
              queryResult,
            ),
          )
          .catchError(
            (dynamic e) => left<DatabaseFailure, List<Map<String, Object?>>>(
              DatabaseFailure(message: e.toString()),
            ),
          );

  @override
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
  }) async =>
      database!
          .query(
            table,
            distinct: distinct,
            columns: columns,
            where: where,
            whereArgs: whereArgs,
            groupBy: groupBy,
            having: having,
            orderBy: orderBy,
            limit: limit,
            offset: offset,
          )
          .then(
            (queryResult) => right<DatabaseFailure, Map<String, Object?>>(
              queryResult.isNotEmpty ? queryResult.first : {},
            ),
          )
          .catchError(
            (dynamic e) => left<DatabaseFailure, Map<String, Object?>>(
              DatabaseFailure(message: e.toString()),
            ),
          );

  @override
  Future<Either<DatabaseFailure, bool>> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async =>
      database!
          .insert(
        table,
        values,
        nullColumnHack: nullColumnHack,
        conflictAlgorithm: conflictAlgorithm,
      )
          .then(
        (result) {
          if (result == 0) {
            return right<DatabaseFailure, bool>(false);
          }
          return right<DatabaseFailure, bool>(true);
        },
      ).catchError(
        (dynamic e) => left<DatabaseFailure, bool>(
          DatabaseFailure(message: e.toString()),
        ),
      );

  @override
  Future<Either<DatabaseFailure, bool>> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async =>
      database!
          .update(
        table,
        values,
        where: where,
        whereArgs: whereArgs,
        conflictAlgorithm: conflictAlgorithm,
      )
          .then(
        (result) {
          if (result == 0) {
            return right<DatabaseFailure, bool>(false);
          }
          return right<DatabaseFailure, bool>(true);
        },
      ).catchError(
        (dynamic e) => left<DatabaseFailure, bool>(
          DatabaseFailure(message: e.toString()),
        ),
      );

  @override
  Future<Either<DatabaseFailure, bool>> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async =>
      database!
          .delete(
        table,
        where: where,
        whereArgs: whereArgs,
      )
          .then(
        (result) {
          if (result == 0) {
            return right<DatabaseFailure, bool>(false);
          }
          return right<DatabaseFailure, bool>(true);
        },
      ).catchError(
        (dynamic e) => left<DatabaseFailure, bool>(
          DatabaseFailure(message: e.toString()),
        ),
      );

  @override
  Future<Either<DatabaseFailure, JustOk>> excuteRawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async =>
      database!
          .execute(sql, arguments)
          .then(
            (result) => right<DatabaseFailure, JustOk>(const JustOk()),
          )
          .catchError(
            (dynamic e) => left<DatabaseFailure, JustOk>(
              DatabaseFailure(message: e.toString()),
            ),
          );

  @override
  Future<Either<DatabaseFailure, int>> countRows(String table) async =>
      database!.rawQuery('SELECT COUNT(*) FROM $table').then(
        (queryResult) {
          final count = Sqflite.firstIntValue(queryResult);
          if (count == null) {
            return right<DatabaseFailure, int>(0);
          }
          return right<DatabaseFailure, int>(count);
        },
      ).catchError((dynamic e) {
        return left<DatabaseFailure, int>(
          DatabaseFailure(message: e.toString()),
        );
      });
}
