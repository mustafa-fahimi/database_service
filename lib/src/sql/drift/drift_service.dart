import 'package:drift/drift.dart';

abstract interface class DriftService {
  const DriftService();

  Future<void> insert<T extends Table, D>(Insertable<D> entity);
  Future<List<D>> getAll<T extends Table, D>();
  Future<D?> getSingle<T extends Table, D>(Expression<bool> Function(T) filter);
  Future<void> update<T extends Table, D>(Insertable<D> entity);
  Future<int> delete<T extends Table, D>(Expression<bool> Function(T) filter);
  Future<void> closeDatabase();
}
