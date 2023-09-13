import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:database_broker/src/common/common_database_exception.dart';
import 'package:database_broker/src/common/database_failure.dart';
import 'package:database_broker/src/common/just_ok.dart';
import 'package:database_broker/src/no_sql/broker/no_sql_broker.dart';
import 'package:database_broker/src/no_sql/security/no_sql_database_security.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class NoSqlBrokerImpl implements NoSqlBroker {
  NoSqlBrokerImpl();
  final NoSqlDatabaseSecurity _databaseSecurity = NoSqlDatabaseSecurity();

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
      throw CommonDatabaseException(error: e.toString());
    }
  }

  Future<Directory> _getDatabaseDirectory() async {
    return path_provider
        .getApplicationDocumentsDirectory()
        .then(
          (appDocumentDirectory) => Directory(
            '${appDocumentDirectory.path}/clasor_database',
          ),
        )
        .catchError(
          (dynamic e) => throw CommonDatabaseException(error: e.toString()),
        );
  }

  /// Opens a box only with encryption key. If there is no encryption key then
  /// throw `DatabaseFailure`
  @override
  Future<Box<dynamic>> openBox(String boxName) async {
    final secureKey = await _databaseSecurity.readEncryptionCipher();
    return Hive.openBox<dynamic>(
      boxName,
      encryptionCipher: secureKey,
    ).then((box) => box).catchError(
          (dynamic e) => throw CommonDatabaseException(error: e.toString()),
        );
  }

  /// Close all open boxes
  @override
  Future<Either<DatabaseFailure, JustOk>> closeDatabase() async => Hive.close()
      .then(
        (_) => right<DatabaseFailure, JustOk>(
          const JustOk(),
        ),
      )
      .catchError(
        (dynamic e) => left<DatabaseFailure, JustOk>(
          DatabaseFailure.unknown(e.toString()),
        ),
      );

  /// Close a single box of the database
  @override
  Future<Either<DatabaseFailure, JustOk>> closeBox(
    String boxName,
  ) async {
    try {
      final box = await openBox(boxName);
      await box.compact();
      await box.close();
      return right(const JustOk());
    } catch (e) {
      return left(DatabaseFailure.unknown(e.toString()));
    }
  }

  /// Add a new entry to the database.
  /// If the key already exists then return [DatabaseFailure]
  @override
  Future<Either<DatabaseFailure, JustOk>> write(
    String boxName,
    String key,
    dynamic value,
  ) async {
    try {
      final box = await openBox(boxName);
      if (box.containsKey(key)) {
        return const Left(DatabaseFailure.unknown('duplicate key'));
      } else {
        await box.put(key, value);
        return right(const JustOk());
      }
    } catch (e) {
      return left(DatabaseFailure.unknown(e.toString()));
    }
  }

  /// Add a set of new entries to the database
  @override
  Future<Either<DatabaseFailure, JustOk>> writeMultiple(
    String boxName,
    Map<dynamic, dynamic> enteries,
  ) async {
    try {
      final box = await openBox(boxName);
      await box.putAll(enteries);
      return right(const JustOk());
    } catch (e) {
      return left(DatabaseFailure.unknown(e.toString()));
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
      return right(dbFetchResult);
    } catch (e) {
      return left(DatabaseFailure.unknown(e.toString()));
    }
  }

  /// If the provided [key] exist in the database then update it,
  /// otherwise return [DatabaseFailure]
  @override
  Future<Either<DatabaseFailure, JustOk>> update(
    String boxName,
    String key,
    dynamic value,
  ) async {
    try {
      final box = await openBox(boxName);
      if (box.containsKey(boxName)) {
        await box.put(key, value);
        return right(const JustOk());
      } else {
        return left(const DatabaseFailure.unknown('key_not_exist'));
      }
    } catch (e) {
      return left(DatabaseFailure.unknown(e.toString()));
    }
  }

  /// Add new data to database and if provided key already exists then update it
  @override
  Future<Either<DatabaseFailure, JustOk>> addOrUpdate(
    String boxName,
    String key,
    dynamic value,
  ) async {
    try {
      final box = await openBox(boxName);
      await box.put(key, value);
      return right(const JustOk());
    } catch (e) {
      return left(DatabaseFailure.unknown(e.toString()));
    }
  }

  /// Delete a single entery from the database
  @override
  Future<Either<DatabaseFailure, JustOk>> delete(
    String boxName,
    String key,
  ) async {
    try {
      final box = await openBox(boxName);
      await box.delete(key);
      return right(const JustOk());
    } catch (e) {
      return left(DatabaseFailure.unknown(e.toString()));
    }
  }

  /// Delete a set of enteries from the database
  @override
  Future<Either<DatabaseFailure, JustOk>> deleteMultiple(
    String boxName,
    Iterable<dynamic> keys,
  ) async {
    try {
      final box = await openBox(boxName);
      await box.deleteAll(keys);
      return right(const JustOk());
    } catch (e) {
      return left(DatabaseFailure.unknown(e.toString()));
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
      return right(deletedRowsCount);
    } catch (e) {
      return left(DatabaseFailure.unknown(e.toString()));
    }
  }

  /// Detele box file from the device storage
  @override
  Future<Either<DatabaseFailure, JustOk>> deleteBoxFromDisk(
    String boxName,
  ) async {
    try {
      final box = await openBox(boxName);
      await box.deleteFromDisk();
      return right(const JustOk());
    } catch (e) {
      return left(DatabaseFailure.unknown(e.toString()));
    }
  }

  /// Delete the database file and secure key from device storage.
  /// Make sure to call the [initialize] method if you want to
  /// use database after calling this method.
  @override
  Future<Either<DatabaseFailure, JustOk>> deleteDatabaseFromDisk() async {
    try {
      final dbDirectory = await _getDatabaseDirectory();
      await dbDirectory.delete(recursive: true);
      await _databaseSecurity.deleteSecureKey();
      return right(const JustOk());
    } catch (e) {
      return left(DatabaseFailure.unknown(e.toString()));
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
      return right(hasProperty);
    } catch (e) {
      return left(DatabaseFailure.unknown(e.toString()));
    }
  }

  /// Registers a Hive adapter
  /// If another adapter with same typeId had been already registered,
  /// the adapter will be overridden if [override] set to `true`
  @override
  Future<Either<DatabaseFailure, JustOk>> registerAdapter<T>(
    TypeAdapter<T> adapter, {
    bool override = false,
  }) async {
    try {
      Hive.registerAdapter<T>(
        adapter,
        override: override,
      );
      return right(const JustOk());
    } catch (e) {
      return left(DatabaseFailure.unknown(e.toString()));
    }
  }
}
