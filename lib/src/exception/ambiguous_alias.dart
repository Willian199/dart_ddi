final class AmbiguousAliasException implements Exception {
  const AmbiguousAliasException({
    required this.alias,
    required this.context,
    required this.qualifiers,
  });

  final Object alias;
  final Object context;
  final Set<Object> qualifiers;

  @override
  String toString() {
    final found = qualifiers.map((q) => q.toString()).toList()..sort();
    return 'Alias "$alias" is ambiguous in context "$context". '
        'Found qualifiers: ${found.join(', ')}';
  }
}
