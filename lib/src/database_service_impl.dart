import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:database_service/src/database_service.dart';
import 'package:database_service/src/errors/database_exceptions.dart';
import 'package:database_service/src/errors/database_failure.dart';
import 'package:database_service/src/no_param.dart';
import 'package:database_service/src/security/database_security.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class DatabaseServiceImpl extends DatabaseService {
  DatabaseServiceImpl();
  final DatabaseSecurity _databaseSecurity = DatabaseSecurity();

  /// Database initialization setup
  @override
  Future<void> initialize() async {
    try {
      await _databaseSecurity.generateAndSaveSecureKeyIfNotExist();

      /// Initialize the database with a path
      if (kIsWeb) {
        await Hive.initFlutter();
      } else {
        await Hive.initFlutter((await _getDatabaseDirectory()).path);
      }
    } on path_provider.MissingPlatformDirectoryException {
      await Hive.initFlutter();
    } on MissingPluginException {
      await Hive.initFlutter();
    } catch (e) {
      throw DatabaseException(message: e.toString());
    }
  }

  Future<Directory> _getDatabaseDirectory() async {
    if (Platform.isMacOS) {
      return path_provider
          .getLibraryDirectory()
          .then(
            (libraryPath) => Directory('${libraryPath.path}/clasor_database'),
          )
          .catchError(
            (dynamic e) => throw DatabaseException(message: e.toString()),
          );
    } else {
      return path_provider
          .getApplicationDocumentsDirectory()
          .then(
            (appDocumentDirectory) => Directory(
              '${appDocumentDirectory.path}/clasor_database',
            ),
          )
          .catchError(
            (dynamic e) => throw DatabaseException(message: e.toString()),
          );
    }
  }

  /// Opens a box only with encryption key. If there is no encryption key then
  /// throw `DatabaseError`
  @override
  Future<Box<dynamic>> openBox(String boxName) async =>
      _databaseSecurity.readEncryptionCipher().then(
        (secureKey) async {
          if (secureKey == null) {
            throw const ReadSecureKeyException();
          } else {
            return Hive.openBox<dynamic>(
              boxName,
              encryptionCipher: secureKey,
            ).then((box) => box).catchError(
                  (dynamic e) => throw DatabaseException(
                    message: e.toString(),
                  ),
                );
          }
        },
      ).catchError(
        (dynamic error) => throw DatabaseException(
          message: error.toString(),
        ),
      );

  /// Close all open boxes
  @override
  Future<Either<DatabaseFailure, NoParam>> closeDatabase() async => Hive.close()
      .then(
        (_) => right<DatabaseFailure, NoParam>(const NoParam()),
      )
      .catchError(
        (dynamic e) => left<DatabaseFailure, NoParam>(
          DatabaseFailure(message: e.toString()),
        ),
      );

  /// Close a single box of the database
  @override
  Future<Either<DatabaseFailure, NoParam>> closeBox(
    String boxName,
  ) async {
    try {
      final box = await openBox(boxName);
      await box.compact();
      await box.close();
      return const Right(NoParam());
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  /// Add a new entry to the database.
  /// If the key already exists then return [DatabaseFailure]
  @override
  Future<Either<DatabaseFailure, NoParam>> write(
    String boxName,
    String key,
    dynamic value,
  ) async {
    try {
      final box = await openBox(boxName);
      if (box.containsKey(key)) {
        return const Left(DatabaseFailure(message: 'duplicate_key'));
      } else {
        await box.put(key, value);
        return const Right(NoParam());
      }
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  /// Add a set of new entries to the database
  @override
  Future<Either<DatabaseFailure, NoParam>> writeMultiple(
    String boxName,
    Map<dynamic, dynamic> enteries,
  ) async {
    try {
      final box = await openBox(boxName);
      await box.putAll(enteries);
      return const Right(NoParam());
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  /// Retrieve a single value from the database
  @override
  Future<Either<DatabaseFailure, dynamic>> read(
    String boxName,
    String key, {
    dynamic defaultValue,
  }) async {
    try {
      final box = await openBox(boxName);
      final dbFetchResult = box.get(
        key,
        defaultValue: defaultValue,
      );
      return Right(dbFetchResult);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  /// If the provided [key] exist in the database then update it,
  /// otherwise return [DatabaseFailure]
  @override
  Future<Either<DatabaseFailure, NoParam>> update(
    String boxName,
    String key,
    dynamic value,
  ) async {
    try {
      final box = await openBox(boxName);
      if (box.containsKey(boxName)) {
        await box.put(key, value);
        return const Right(NoParam());
      } else {
        return const Left(DatabaseFailure(message: 'key_not_exist'));
      }
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  /// Add new data to database and if provided key already exists then update it
  @override
  Future<Either<DatabaseFailure, NoParam>> addOrUpdate(
    String boxName,
    String key,
    dynamic value,
  ) async {
    try {
      final box = await openBox(boxName);
      await box.put(key, value);
      return const Right(NoParam());
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  /// Delete a single entery from the database
  @override
  Future<Either<DatabaseFailure, NoParam>> delete(
    String boxName,
    String key,
  ) async {
    try {
      final box = await openBox(boxName);
      await box.delete(key);
      return const Right(NoParam());
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  /// Delete a set of enteries from the database
  @override
  Future<Either<DatabaseFailure, NoParam>> deleteMultiple(
    String boxName,
    Iterable<dynamic> keys,
  ) async {
    try {
      final box = await openBox(boxName);
      await box.deleteAll(keys);
      return const Right(NoParam());
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  /// Delete all enteries from the database
  @override
  Future<Either<DatabaseFailure, int>> clearBox(
    String boxName,
  ) async {
    try {
      final box = await openBox(boxName);
      final deletedRowsCount = await box.clear();
      return Right(deletedRowsCount);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  /// Detele box file from the device storage
  @override
  Future<Either<DatabaseFailure, NoParam>> deleteBoxFromDisk(
    String boxName,
  ) async {
    try {
      final box = await openBox(boxName);
      await box.deleteFromDisk();
      return const Right(NoParam());
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  /// Delete the database file and secure key from device storage.
  /// Make sure to call the [initialize] method if you want to
  /// use database after calling this method.
  @override
  Future<Either<DatabaseFailure, NoParam>> deleteDatabaseFromDisk() async {
    try {
      final dbDirectory = await _getDatabaseDirectory();
      await dbDirectory.delete(recursive: true);
      await _databaseSecurity.deleteSecureKey();
      return const Right(NoParam());
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  /// Check if provided property exists in the database
  @override
  Future<Either<DatabaseFailure, bool>> hasProperty(
    String boxName,
    String key,
  ) async {
    try {
      final box = await openBox(boxName);
      final hasProperty = box.containsKey(key);
      return Right(hasProperty);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  /// Registers a Hive adapter
  /// If another adapter with same typeId had been already registered,
  /// the adapter will be overridden if [override] set to `true`
  @override
  Future<Either<DatabaseFailure, NoParam>> registerAdapter<T>(
    TypeAdapter<T> adapter, {
    bool override = false,
  }) async {
    try {
      Hive.registerAdapter<T>(
        adapter,
        override: override,
      );
      return const Right(NoParam());
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
