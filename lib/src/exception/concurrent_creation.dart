/// Exception thrown when multiple threads or async operations try to create the same instance simultaneously.
///
/// This exception is thrown in the following scenarios:
/// - When multiple async operations try to create the same instance at the same time
/// - When there's a race condition during instance creation
/// - When the same factory is accessed concurrently before the first creation completes
/// - When using async factories with concurrent access patterns
///
/// Common causes:
/// - Multiple parts of the code trying to get the same instance simultaneously
/// - Async factories being accessed before their creation process completes
/// - Circular dependencies that cause concurrent creation attempts
///
/// To resolve this issue:
/// - Ensure that instance creation is properly awaited
/// - Use `ddi.isReady<Type>()` to check if an instance is already created
/// - Avoid concurrent access to the same factory during creation
/// - Use proper async/await patterns when dealing with async factories
///
class ConcurrentCreationException implements Exception {
  const ConcurrentCreationException(this.cause);
  final String cause;

  @override
  String toString() {
    return "It seems that a Circular Dependency Injection has occurred for Instance Type $cause , or you're attempting to call [getAsync] for the same object in multiple places simultaneously.";
  }
}
