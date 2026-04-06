final class ContextDestroyIncompleteException implements Exception {
  const ContextDestroyIncompleteException(this.context);

  final Object context;

  @override
  String toString() =>
      'Context "$context" still contains factories after destroy operation.';
}
