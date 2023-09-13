class DbException implements Exception {
  const DbException({this.error});

  final dynamic error;

  @override
  String toString() => 'DbException: $error';
}
