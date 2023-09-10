class DatabaseException implements Exception {
  const DatabaseException({this.error = ''});

  final String error;

  @override
  String toString() => 'DatabaseException: $error';
}
