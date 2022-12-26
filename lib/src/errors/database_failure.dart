class DatabaseFailure {
  const DatabaseFailure({this.message});
  final String? message;

  @override
  String toString() {
    return 'DBServiceFailure: $message';
  }
}
