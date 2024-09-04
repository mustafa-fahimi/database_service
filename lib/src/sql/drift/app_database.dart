import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [])
class AppDatabase extends _$AppDatabase {
  AppDatabase(String dbName) : super(_openConnection(dbName));

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection(String dbName) {
    return driftDatabase(name: dbName);
  }
}
