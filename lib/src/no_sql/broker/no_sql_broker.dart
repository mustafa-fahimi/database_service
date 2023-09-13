import 'package:dartz/dartz.dart';
import 'package:database_broker/src/common/database_failure.dart';
import 'package:database_broker/src/common/just_ok.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract interface class NoSqlBroker {
  const NoSqlBroker();

  Future<void> initialize();

  Future<Either<DatabaseFailure, JustOk>> closeDatabase();

  Future<Box<dynamic>> openBox(String boxName);

  Future<Either<DatabaseFailure, JustOk>> closeBox(String boxName);

  Future<Either<DatabaseFailure, JustOk>> write(
    String boxName,
    String key,
    dynamic value,
  );

  Future<Either<DatabaseFailure, JustOk>> writeMultiple(
    String boxName,
    Map<dynamic, dynamic> enteries,
  );

  Future<Either<DatabaseFailure, dynamic>> read(
    String boxName,
    String key, {
    dynamic defaultValue,
  });

  Future<Either<DatabaseFailure, JustOk>> update(
    String boxName,
    String key,
    dynamic value,
  );

  Future<Either<DatabaseFailure, JustOk>> addOrUpdate(
    String boxName,
    String key,
    dynamic value,
  );

  Future<Either<DatabaseFailure, JustOk>> delete(
    String boxName,
    String key,
  );

  Future<Either<DatabaseFailure, JustOk>> deleteMultiple(
    String boxName,
    Iterable<dynamic> keys,
  );

  Future<Either<DatabaseFailure, int>> clearBox(
    String boxName,
  );

  Future<Either<DatabaseFailure, JustOk>> deleteBoxFromDisk(
    String boxName,
  );

  Future<Either<DatabaseFailure, JustOk>> deleteDatabaseFromDisk();

  Future<Either<DatabaseFailure, bool>> hasProperty(
    String boxName,
    String key,
  );

  Future<Either<DatabaseFailure, JustOk>> registerAdapter<T>(
    TypeAdapter<T> adapter, {
    bool override = false,
  });
}
