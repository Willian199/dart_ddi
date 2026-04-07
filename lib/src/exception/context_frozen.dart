final class ContextFrozenException implements Exception {
  const ContextFrozenException({
    required this.context,
    required this.operation,
  });

  final Object context;
  final String operation;

  @override
  String toString() =>
      'Context "$context" is frozen. Operation "$operation" is not allowed.';
}
