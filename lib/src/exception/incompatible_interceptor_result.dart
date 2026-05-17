/// Exception thrown when an interceptor returns a value that is incompatible
/// with the type exposed by the target factory.
class IncompatibleInterceptorResultException implements Exception {
  const IncompatibleInterceptorResultException({
    required this.interceptor,
    required this.lifecycle,
    required this.expectedType,
    required this.actualType,
  });

  final Object interceptor;
  final String lifecycle;
  final Type expectedType;
  final String actualType;

  @override
  String toString() {
    return 'Interceptor "$interceptor" returned $actualType during '
        '$lifecycle, which is not compatible with bean type $expectedType.';
  }
}
