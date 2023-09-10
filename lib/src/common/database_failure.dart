class DatabaseFailure {
  const DatabaseFailure({this.message});
  final String? message;

  @override
  String toString() {
    return 'DatabaseFailure: $message';
  }
}
