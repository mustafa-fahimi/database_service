import 'package:database_service/src/sql/drift/drift_database.dart';
import 'package:database_service/src/sql/drift/drift_service.dart';
import 'package:drift/drift.dart';

class DriftServiceImpl implements DriftService {
  const DriftServiceImpl(this._database);

  final AppDatabase _database;

  @override
  Future<void> insert<T extends Table, D>(Insertable<D> entity) async {
    final table = _getTable<T, D>();
    await _database.into(table).insert(entity);
  }

  @override
  Future<List<D>> getAll<T extends Table, D>() async {
    final table = _getTable<T, D>();
    return _database.select(table).get();
  }

  @override
  Future<D?> getSingle<T extends Table, D>(
    Expression<bool> Function(T) filter,
  ) async {
    final table = _getTable<T, D>();
    return (_database.select(table)..where(filter)).getSingleOrNull();
  }

  @override
  Future<void> update<T extends Table, D>(Insertable<D> entity) async {
    final table = _getTable<T, D>();
    await _database.update(table).replace(entity);
  }

  @override
  Future<int> delete<T extends Table, D>(
    Expression<bool> Function(T) filter,
  ) async {
    final table = _getTable<T, D>();
    return (_database.delete(table)..where(filter)).go();
  }

  @override
  Future<void> closeDatabase() async {
    await _database.close();
  }

  TableInfo<T, D> _getTable<T extends Table, D>() {
    final table =
        _database.allTables.firstWhere((t) => t is T) as TableInfo<T, D>;
    return table;
  }
}
