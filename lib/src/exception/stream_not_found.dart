class StreamNotFound implements Exception {
  const StreamNotFound(this.cause);
  final String cause;

  @override
  String toString() {
    return 'No Stream found with Type $cause.';
  }
}
