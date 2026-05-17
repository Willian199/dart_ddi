final class ModuleContextChangedException implements Exception {
  const ModuleContextChangedException({
    required this.previousContext,
    required this.nextContext,
  });

  final Object previousContext;
  final Object? nextContext;

  @override
  String toString() =>
      'Module context changed from "$previousContext" to "$nextContext" '
      'after it had already been created.';
}
