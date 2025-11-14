/// Exception thrown when required dependencies (qualifiers or types) are not available in the DDI container.
///
/// This exception is thrown when a factory has declared required dependencies via `required`
/// and one or more of those dependencies are not registered in the DDI container.
///
///
/// To resolve this issue:
/// - Ensure all required dependencies are registered before the factory tries to create an instance
/// - Check that qualifier names match exactly (case-sensitive)
///
class MissingDependenciesException implements Exception {
  const MissingDependenciesException(this.message);

  /// The error message describing the missing dependencies.
  final String message;

  @override
  String toString() {
    return 'MissingDependenciesException: $message.';
  }
}
