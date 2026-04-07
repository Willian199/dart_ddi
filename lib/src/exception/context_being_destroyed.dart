final class ContextBeingDestroyedException implements Exception {
  const ContextBeingDestroyedException({
    required this.context,
    required this.operation,
  });

  final Object context;
  final String operation;

  @override
  String toString() =>
      'Context "$context" is being destroyed. Operation "$operation" is not allowed.';
}
