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
  Future<Either<DatabaseFailure, Database>> openSqliteDatabase() async {
    final databasePath = await getSqliteDatabaseFullPath();
    return openDatabase(
      databasePath,
      version: databaseVersion,
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
  Future<Either<DatabaseFailure, NoParam>> closeSqliteDatabase() async {
    if (database != null) {
      try {
        await database!.close();
        return right(const NoParam());
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
}
