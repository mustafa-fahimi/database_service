import 'package:database_broker/src/common/common_database_exception.dart';

enum SecureKeyActions {
  read,
  write,
  delete,
}

class SecureKeyException implements CommonDatabaseException {
  const SecureKeyException({
    required this.action,
    this.error = '',
  });

  final SecureKeyActions action;

  @override
  final String error;

  @override
  String toString() => 'SecureKeyException($action): $error';
}
