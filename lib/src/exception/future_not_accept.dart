class FutureNotAccept implements Exception {
  const FutureNotAccept();

  @override
  String toString() {
    return 'The Future type is not supported. Use getAsync instead.';
  }
}
