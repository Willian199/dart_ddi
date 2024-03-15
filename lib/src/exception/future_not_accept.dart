/// [FutureNotAcceptException] is an exception that is thrown when the future type is not supported.
class FutureNotAcceptException implements Exception {
  const FutureNotAcceptException();

  @override
  String toString() {
    return 'The Future type is not supported. Use getAsync instead.';
  }
}
