import 'dart:async';
import 'dart:io';

import 'package:database_service/database_service.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

typedef OnCreate = FutureOr<void> Function(Database, int)?;
typedef OnUpgrade = FutureOr<void> Function(Database, int, int)?;
typedef OnDowngrade = FutureOr<void> Function(Database, int, int)?;
typedef SqfliteBatch = Batch;

class SqfliteServiceImpl implements SqfliteService {
  SqfliteServiceImpl({
    required this.databaseFileName,
    this.defaultConflictAlgorithm = ConflictAlgorithm.ignore,
  }) : assert(
         databaseFileName.split('.').last == 'db',
         'File name format should be like this: Filename.db',
       ) {
    // Initialize FFI for Windows/macOS and Web
    if (Platform.isWindows || Platform.isMacOS) {
      // This will override the global databaseFactory
      databaseFactory = databaseFactoryFfi;
    } else if (kIsWeb) {
      // Use web factory for web platform
      databaseFactory = databaseFactoryFfiWeb;
    }
  }

  final String databaseFileName;
  final ConflictAlgorithm defaultConflictAlgorithm;
  Database? database;

  Future<String> _getSqliteDatabaseFullPath() async {
    try {
      if (kIsWeb) {
        // For web, just return the database name (stored in IndexedDB)
        return databaseFileName;
      } else {
        final path = await getDatabasesPath();
        return join(path, databaseFileName);
      }
    } catch (e) {
      throw DatabaseServiceException(error: e);
    }
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  @override
  Future<JobDone> openSqliteDatabase({
    int databaseVersion = 1,
    OnCreate onCreate,
    OnUpgrade onUpgrade,
    OnDowngrade onDowngrade,
    bool readOnly = false,
  }) async {
    try {
      final databasePath = await _getSqliteDatabaseFullPath();
      database = await databaseFactory.openDatabase(
        databasePath,
        options: OpenDatabaseOptions(
          version: databaseVersion,
          readOnly: readOnly,
          onConfigure: _onConfigure,
          onCreate: (db, version) => onCreate?.call(db, version),
          onUpgrade: (db, oldVersion, newVersion) =>
              onUpgrade?.call(db, oldVersion, newVersion),
          onDowngrade: (db, oldVersion, newVersion) =>
              onDowngrade?.call(db, oldVersion, newVersion),
        ),
      );
      return const JobDone();
    } catch (e) {
      throw DatabaseServiceException(error: e);
    }
  }

  @override
  Future<JobDone> closeSqliteDatabase() async {
    try {
      if (database == null) {
        throw const DatabaseServiceException(error: 'Database object was null');
      }
      await database!.close();
      return const JobDone();
    } catch (e) {
      throw DatabaseServiceException(error: e);
    }
  }

  @override
  Future<JobDone> deleteSqliteDatabase() async {
    try {
      final databasePath = await _getSqliteDatabaseFullPath();
      await databaseFactory.deleteDatabase(databasePath);
      return const JobDone();
    } catch (e) {
      throw DatabaseServiceException(error: e);
    }
  }

  @override
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
  }) async {
    try {
      final queryResult = await database!.query(
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
      );
      return queryResult;
    } catch (e) {
      throw DatabaseServiceException(error: e);
    }
  }

  @override
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
  }) async {
    try {
      final queryResult = await database!.query(
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
      );
      return queryResult.isNotEmpty ? queryResult.first : <String, Object?>{};
    } catch (e) {
      throw DatabaseServiceException(error: e);
    }
  }

  @override
  Future<bool> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    try {
      final result = await database!.insert(
        table,
        values,
        nullColumnHack: nullColumnHack,
        conflictAlgorithm: conflictAlgorithm ?? defaultConflictAlgorithm,
      );
      if (result == 1) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw DatabaseServiceException(error: e);
    }
  }

  @override
  Future<bool> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    try {
      final result = await database!.update(
        table,
        values,
        where: where,
        whereArgs: whereArgs,
        conflictAlgorithm: conflictAlgorithm ?? defaultConflictAlgorithm,
      );
      if (result == 1) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw DatabaseServiceException(error: e);
    }
  }

  @override
  Future<bool> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    try {
      final result = await database!.delete(
        table,
        where: where,
        whereArgs: whereArgs,
      );
      if (result == 1) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw DatabaseServiceException(error: e);
    }
  }

  @override
  Future<JobDone> excuteRawQuery(String sql, [List<Object?>? arguments]) async {
    try {
      await database!.execute(sql, arguments);
      return const JobDone();
    } catch (e) {
      throw DatabaseServiceException(error: e);
    }
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    try {
      return await database!.rawQuery(sql, arguments);
    } catch (e) {
      throw DatabaseServiceException(error: e);
    }
  }

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) async {
    try {
      return await database!.rawInsert(sql, arguments);
    } catch (e) {
      throw DatabaseServiceException(error: e);
    }
  }

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) async {
    try {
      return await database!.rawUpdate(sql, arguments);
    } catch (e) {
      throw DatabaseServiceException(error: e);
    }
  }

  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) async {
    try {
      return await database!.rawDelete(sql, arguments);
    } catch (e) {
      throw DatabaseServiceException(error: e);
    }
  }

  @override
  Future<int> countRows(String table) async {
    try {
      final result = await database!.rawQuery('SELECT COUNT(*) FROM $table');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw DatabaseServiceException(error: e);
    }
  }

  @override
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    try {
      return await database!.transaction(action);
    } catch (e) {
      throw DatabaseServiceException(error: e);
    }
  }

  @override
  Future<List<Object?>> executeBatch(
    void Function(SqfliteBatch batch) operations, {
    bool? exclusive,
    bool? noResult,
    bool? continueOnError,
  }) async {
    try {
      if (database == null) {
        throw const DatabaseServiceException(
          error: 'Database is not initialized',
        );
      }
      final batch = database!.batch();
      operations(batch);
      return await batch.commit(
        exclusive: exclusive,
        noResult: noResult,
        continueOnError: continueOnError,
      );
    } catch (e) {
      throw DatabaseServiceException(error: e);
    }
  }
}
