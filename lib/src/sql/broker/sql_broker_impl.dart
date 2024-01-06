import 'package:database_broker/database_broker.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqlBrokerImpl implements SqlBroker {
  SqlBrokerImpl({
    required this.databaseFileName,
    this.defaultConflictAlgorithm = ConflictAlgorithm.ignore,
  }) : assert(
          databaseFileName.split('.').last == 'db',
          'File name format should be like this: Filename.db',
        );

  final String databaseFileName;
  final ConflictAlgorithm defaultConflictAlgorithm;
  Database? database;

  Future<String> _getSqliteDatabaseFullPath() async {
    try {
      final path = await getDatabasesPath();
      return join(path, databaseFileName);
    } catch (e) {
      throw DbException(error: e);
    }
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _executeMultupleQueriesWithTransaction(
    Database db,
    List<String> queries,
  ) async {
    await db.transaction<void>(
      (txn) async {
        for (final query in queries) {
          await txn.execute(query);
        }
      },
    );
  }

  Future<void> _onCreate(
    Database db,
    List<String>? queries,
  ) async {
    if (queries == null || queries.isEmpty) return;
    await _executeMultupleQueriesWithTransaction(db, queries);
  }

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
    List<String>? queries,
  ) async {
    if (queries == null || queries.isEmpty) return;
    if (newVersion > oldVersion) {
      await _executeMultupleQueriesWithTransaction(db, queries);
    }
  }

  @override
  Future<JobDone> openSqliteDatabase({
    int databaseVersion = 1,
    List<String>? onCreateQueries,
    List<String>? onUpgradeQueries,
  }) async {
    try {
      final databasePath = await _getSqliteDatabaseFullPath();
      database = await databaseFactory.openDatabase(
        databasePath,
        options: OpenDatabaseOptions(
          version: databaseVersion,
          onConfigure: _onConfigure,
          onCreate: (db, version) => _onCreate(db, onCreateQueries),
          onUpgrade: (db, oldVersion, newVersion) => _onUpgrade(
            db,
            oldVersion,
            newVersion,
            onUpgradeQueries,
          ),
        ),
      );
      return const JobDone();
    } catch (e) {
      throw DbException(error: e);
    }
  }

  @override
  Future<JobDone> closeSqliteDatabase() async {
    try {
      if (database == null) {
        throw const DbException(error: 'Database object was null');
      }
      await database!.close();
      return const JobDone();
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
