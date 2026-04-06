final class DuplicatedContextException implements Exception {
  const DuplicatedContextException(this.context);

  final String context;

  @override
  String toString() => 'Context "$context" is already registered.';
}
