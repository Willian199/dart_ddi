/// Exception thrown when a scope receives a lifecycle mixin it cannot support.
class UnsupportedLifecycleException implements Exception {
  const UnsupportedLifecycleException({
    required this.scope,
    required this.lifecycle,
  });

  final String scope;
  final String lifecycle;

  @override
  String toString() {
    return '$scope instances do not support $lifecycle. Use Interceptors instead.';
  }
}
