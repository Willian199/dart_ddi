/// [StreamNotFoundException] is an exception that is thrown when tried to access a stream that doesn't exist.
class StreamNotFoundException implements Exception {
  const StreamNotFoundException(this.cause);
  final String cause;

  @override
  String toString() {
    return 'No Stream found with Type $cause.';
  }
}
