class CommonDatabaseException implements Exception {
  const CommonDatabaseException({this.error = ''});

  final String error;

  @override
  String toString() => 'DatabaseException: $error';
}
