import 'package:database_broker/database_broker.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqlBrokerImpl implements SqlBroker {
  SqlBrokerImpl({
    required this.databaseFileName,
    this.databaseVersion = 1,
  }) : assert(
          databaseFileName.split('.').last == 'db',
          'File name format should be like this: Filename.db',
        );

  final String databaseFileName;
  final int databaseVersion;
  final defaultConflictAlgorithm = ConflictAlgorithm.ignore;
  Database? database;

  @override
  Future<JobDone> openSqliteDatabase({
    List<CreateTableWrapper>? createTableQueries,
  }) async {
    try {
      final databasePath = await getSqliteDatabaseFullPath();
      database = await databaseFactory.openDatabase(
        databasePath,
        options: OpenDatabaseOptions(
          version: databaseVersion,
          onOpen: createTableQueries != null && createTableQueries.isNotEmpty ? (db) => _onOpened(db, createTableQueries) : null,
        ),
      );
      return const JobDone();
    } catch (e) {
      throw DbException(error: e);
    }
  }

  Future<void> _onOpened(
    Database db,
    List<CreateTableWrapper> createTableQueries,
  ) async {
    final batch = db.batch();

    for (final element in createTableQueries) {
      if (!element.checkTableExist) {
        batch.execute(element.query);
        continue;
      }

      final queryResult = await db.rawQuery(
        '''SELECT name FROM sqlite_master WHERE type="table" AND name="${element.table}"''',
      );

      if (queryResult.isEmpty) {
        batch.execute(element.query);
      }
    }

    await batch.commit();
  }

  @override
  Future<JobDone> closeSqliteDatabase() async {
    if (database == null) {
      throw const DbException(error: 'Database object was null');
    }
    try {
      await database!.close();
      return const JobDone();
    } catch (e) {
      throw DbException(error: e);
    }
  }

  @override
  Future<String> getSqliteDatabaseFullPath() async {
    try {
      final path = await getDatabasesPath();
      return join(path, databaseFileName);
    } catch (e) {
      throw DbException(error: e);
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
      throw DbException(error: e);
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
      throw DbException(error: e);
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
      throw DbException(error: e);
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
      throw DbException(error: e);
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
      throw DbException(error: e);
    }
  }

  @override
  Future<JobDone> excuteRawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    try {
      await database!.execute(sql, arguments);
      return const JobDone();
    } catch (e) {
      throw DbException(error: e);
    }
  }

  @override
  Future<int> countRows(String table) async {
    try {
      final result = await database!.rawQuery('SELECT COUNT(*) FROM $table');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw DbException(error: e);
    }
  }
}
