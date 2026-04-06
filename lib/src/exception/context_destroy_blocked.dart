final class ContextDestroyBlockedException implements Exception {
  const ContextDestroyBlockedException(this.context);

  final Object context;

  @override
  String toString() =>
      'Context "$context" contains non-destroyable factories.';
}
