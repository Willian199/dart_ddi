/// Exception thrown when trying to access a Future-based factory using synchronous methods.
///
/// This exception is thrown in the following scenarios:
/// - When calling `ddi.get<Type>()` on a factory that returns a `Future`
/// - When the factory's builder is configured as async but accessed with sync methods
/// - When there's a mismatch between sync and async access patterns
///
/// Common causes:
/// - Using `get()` instead of `getAsync()` for async factories
/// - Forgetting to await async factory creation
/// - Using the wrong access pattern for the factory type
///
/// To resolve this issue:
/// - Use `ddi.getAsync<Type>()` for async factories
/// - Ensure consistent async/await patterns throughout the codebase
/// - Check if a factory is async before accessing it
/// - Use proper async factory registration and access patterns
///
/// Example:
/// ```dart
/// // This will throw FutureNotAcceptException
/// ddi.register<MyService>(
///   factory: ApplicationFactory(
///     builder: () async => await MyService.create(),
///   ),
/// );
/// final service = ddi.get<MyService>(); // Wrong! Use getAsync
///
/// // Correct approach
/// final service = await ddi.getAsync<MyService>();
///
/// // Or check if it's a future factory
/// if (ddi.isFuture<MyService>()) {
///   final service = await ddi.getAsync<MyService>();
/// } else {
///   final service = ddi.get<MyService>();
/// }
/// ```
class FutureNotAcceptException implements Exception {
  const FutureNotAcceptException();

  @override
  String toString() {
    return 'The Future type is not supported. Use getAsync instead.';
  }
}
