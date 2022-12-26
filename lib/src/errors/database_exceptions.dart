class DatabaseException implements Exception {
  const DatabaseException({this.message});
  final String? message;

  @override
  String toString() {
    return 'DBServiceException: $message';
  }
}

class ReadSecureKeyException implements DatabaseException {
  const ReadSecureKeyException();

  @override
  String? get message => 'Unable to read secure_key';

  @override
  String toString() {
    return 'ReadSecureKeyException: $message';
  }
}
