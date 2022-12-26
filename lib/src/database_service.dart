import 'package:dartz/dartz.dart';
import 'package:database_service/src/errors/database_failure.dart';
import 'package:database_service/src/no_param.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class DatabaseService {
  const DatabaseService();

  Future<void> initialize();

  Future<Either<DatabaseFailure, NoParam>> closeDatabase();

  Future<Box<dynamic>> openBox(String boxName);

  Future<Either<DatabaseFailure, NoParam>> closeBox(
    String boxName,
  );

  Future<Either<DatabaseFailure, NoParam>> write(
    String boxName,
    String key,
    dynamic value,
  );

  Future<Either<DatabaseFailure, NoParam>> writeMultiple(
    String boxName,
    Map<dynamic, dynamic> enteries,
  );

  Future<Either<DatabaseFailure, dynamic>> read(
    String boxName,
    String key, {
    dynamic defaultValue,
  });

  Future<Either<DatabaseFailure, NoParam>> update(
    String boxName,
    String key,
    dynamic value,
  );

  Future<Either<DatabaseFailure, NoParam>> addOrUpdate(
    String boxName,
    String key,
    dynamic value,
  );

  Future<Either<DatabaseFailure, NoParam>> delete(
    String boxName,
    String key,
  );

  Future<Either<DatabaseFailure, NoParam>> deleteMultiple(
    String boxName,
    Iterable<dynamic> keys,
  );

  Future<Either<DatabaseFailure, int>> clearBox(
    String boxName,
  );

  Future<Either<DatabaseFailure, NoParam>> deleteBoxFromDisk(
    String boxName,
  );

  Future<Either<DatabaseFailure, NoParam>> deleteDatabaseFromDisk();

  Future<Either<DatabaseFailure, bool>> hasProperty(
    String boxName,
    String key,
  );

  Future<Either<DatabaseFailure, NoParam>> registerAdapter<T>(
    TypeAdapter<T> adapter, {
    bool override = false,
  });
}
