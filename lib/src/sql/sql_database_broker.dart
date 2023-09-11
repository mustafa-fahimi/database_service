import 'package:dartz/dartz.dart';
import 'package:database_broker/database_broker.dart';
import 'package:sqflite/sqflite.dart';

abstract class SqlDatabaseBroker {
  const SqlDatabaseBroker();

  Future<void> initializeSqliteDatabase();

  Future<String> getSqliteDatabaseFullPath();

  Future<Either<DatabaseFailure, Database>> openSqliteDatabase();

  Future<Either<DatabaseFailure, NoParam>> closeSqliteDatabase();
}
