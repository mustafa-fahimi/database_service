class DatabaseFailure {
  const DatabaseFailure({this.message = 'Something gone wrong!'});
  final String? message;

  @override
  String toString() {
    return 'DatabaseFailure: $message';
  }
}
