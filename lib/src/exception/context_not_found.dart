final class ContextNotFoundException implements Exception {
  const ContextNotFoundException(this.context);

  final String context;

  @override
  String toString() => 'Context "$context" was not found.';
}
