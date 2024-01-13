class DatabaseBrokerException implements Exception {
  const DatabaseBrokerException({this.error});

  final dynamic error;

  @override
  String toString() => 'DatabaseBrokerException: $error';
}
