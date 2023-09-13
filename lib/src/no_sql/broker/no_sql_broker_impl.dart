import 'dart:io';

import 'package:database_broker/src/common/db_exception.dart';
import 'package:database_broker/src/common/job_done.dart';
import 'package:database_broker/src/no_sql/broker/no_sql_broker.dart';
import 'package:database_broker/src/no_sql/security/no_sql_database_security.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class NoSqlBrokerImpl implements NoSqlBroker {
  NoSqlBrokerImpl();
  final NoSqlDatabaseSecurity _databaseSecurity = NoSqlDatabaseSecurity();

  @override
  Future<JobDone> initializeDatabase() async {
    try {
      await _databaseSecurity.generateAndSaveSecureKeyIfNotExist();
      await Hive.initFlutter(
        kIsWeb ? null : (await _getDatabaseDirectory()).path,
      );
      return const JobDone();
    } catch (e) {
      throw DbException(error: e);
    }
  }

  Future<Directory> _getDatabaseDirectory() async {
    try {
      final appDocumentDirectory =
          await path_provider.getApplicationDocumentsDirectory();
      return Directory('${appDocumentDirectory.path}/clasor_database');
    } catch (e) {
      throw DbException(error: e);
    }
  }

  @override
  Future<Box<dynamic>> openBox(String boxName) async {
    try {
      final secureKey = await _databaseSecurity.readEncryptionCipher();
      final box = await Hive.openBox<dynamic>(
        boxName,
        encryptionCipher: secureKey,
      );
      return box;
    } catch (e) {
      throw DbException(error: e);
    }
  }

  @override
  Future<JobDone> closeDatabase() async {
    try {
      await Hive.close();
      return const JobDone();
    } catch (e) {
      throw DbException(error: e);
    }
  }

  @override
  Future<JobDone> closeBox(
    String boxName,
  ) async {
    try {
      final box = await openBox(boxName);
      await box.compact();
      await box.close();
      return const JobDone();
    } catch (e) {
      throw DbException(error: e);
    }
  }

  @override
  Future<JobDone> write(
    String boxName,
    String key,
    dynamic value,
  ) async {
    try {
      final box = await openBox(boxName);
      if (box.containsKey(key)) {
        throw const DbException(error: 'duplicate_key');
      }
      await box.put(key, value);
      return const JobDone();
    } catch (e) {
      throw DbException(error: e);
    }
  }

  @override
  Future<JobDone> writeMultiple(
    String boxName,
    Map<dynamic, dynamic> enteries,
  ) async {
    try {
      final box = await openBox(boxName);
      await box.putAll(enteries);
      return const JobDone();
    } catch (e) {
      throw DbException(error: e);
    }
  }

  @override
  Future<dynamic> read(
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
      return dbFetchResult;
    } catch (e) {
      throw DbException(error: e);
    }
  }

  @override
  Future<JobDone> update(
    String boxName,
    String key,
    dynamic value,
  ) async {
    try {
      final box = await openBox(boxName);
      if (!box.containsKey(boxName)) {
        throw const DbException(error: 'key_not_exist');
      }
      await box.put(key, value);
      return const JobDone();
    } catch (e) {
      throw DbException(error: e);
    }
  }

  @override
  Future<JobDone> addOrUpdate(
    String boxName,
    String key,
    dynamic value,
  ) async {
    try {
      final box = await openBox(boxName);
      await box.put(key, value);
      return const JobDone();
    } catch (e) {
      throw DbException(error: e);
    }
  }

  @override
  Future<JobDone> delete(
    String boxName,
    String key,
  ) async {
    try {
      final box = await openBox(boxName);
      await box.delete(key);
      return const JobDone();
    } catch (e) {
      throw DbException(error: e);
    }
  }

  @override
  Future<JobDone> deleteMultiple(
    String boxName,
    Iterable<dynamic> keys,
  ) async {
    try {
      final box = await openBox(boxName);
      await box.deleteAll(keys);
      return const JobDone();
    } catch (e) {
      throw DbException(error: e);
    }
  }

  @override
  Future<int> clearBox(
    String boxName,
  ) async {
    try {
      final box = await openBox(boxName);
      return await box.clear();
    } catch (e) {
      throw DbException(error: e);
    }
  }

  @override
  Future<JobDone> deleteBoxFromDisk(
    String boxName,
  ) async {
    try {
      final box = await openBox(boxName);
      await box.deleteFromDisk();
      return const JobDone();
    } catch (e) {
      throw DbException(error: e);
    }
  }

  @override
  Future<JobDone> deleteDatabaseFromDisk() async {
    try {
      final dbDirectory = await _getDatabaseDirectory();
      await dbDirectory.delete(recursive: true);
      await _databaseSecurity.deleteSecureKey();
      return const JobDone();
    } catch (e) {
      throw DbException(error: e);
    }
  }

  @override
  Future<bool> hasProperty(
    String boxName,
    String key,
  ) async {
    try {
      final box = await openBox(boxName);
      return box.containsKey(key);
    } catch (e) {
      throw DbException(error: e);
    }
  }

  @override
  Future<JobDone> registerAdapter<T>(
    TypeAdapter<T> adapter, {
    bool override = false,
  }) async {
    try {
      Hive.registerAdapter<T>(
        adapter,
        override: override,
      );
      return const JobDone();
    } catch (e) {
      throw DbException(error: e);
    }
  }
}
