/// Exception thrown when trying to access a bean that exists but is not ready yet.
///
/// This exception is thrown in the following scenarios:
/// - When calling `ddi.get<Type>()` on a factory that's still being created
/// - When trying to access an async factory synchronously
/// - When the instance creation process is still in progress
/// - When there's a race condition during instance creation
///
/// Common causes:
/// - Trying to access an async factory with `get()` instead of `getAsync()`
/// - Accessing an instance before its creation process is complete
/// - Concurrent access to the same instance during creation
/// - Using a factory that requires parameters but none are provided
///
/// To resolve this issue:
/// - Use `ddi.getAsync<Type>()` for async factories
/// - Wait for the instance to be ready using `ddi.isReady<Type>()`
/// - Ensure proper parameter passing for parameterized constructors
/// - Avoid concurrent access during instance creation
///
/// Example:
/// ```dart
/// // This might throw BeanNotReadyException if the factory is async
/// final service = ddi.get<MyService>();
///
/// // Use getAsync for async factories
/// final service = await ddi.getAsync<MyService>();
///
/// // Or check if ready first
/// if (ddi.isReady<MyService>()) {
///   final service = ddi.get<MyService>();
/// }
/// ```
class BeanNotReadyException implements Exception {
  const BeanNotReadyException(this.cause);
  final String cause;

  @override
  String toString() {
    return 'Instance with Type $cause was found, but is not ready yet.';
  }
}
