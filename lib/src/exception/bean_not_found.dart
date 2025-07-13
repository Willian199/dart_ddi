/// Exception thrown when trying to access a bean that doesn't exist in the DDI container.
///
/// This exception is thrown in the following scenarios:
/// - When calling `ddi.get<Type>()` for a type that hasn't been registered
/// - When calling `ddi.get<Type>(qualifier: 'qualifier')` for a qualifier that doesn't exist
/// - When trying to retrieve an instance that was already destroyed
/// - When using auto-injection and a required dependency is not registered
///
/// Common causes:
/// - Forgetting to register a service before using it
/// - Using the wrong qualifier name
/// - Registering with one qualifier but retrieving with another
/// - Trying to access a destroyed instance
///
/// To resolve this issue:
/// - Ensure the bean is registered before trying to retrieve it
/// - Check that the qualifier name matches exactly (case-sensitive)
/// - Verify that the registration was successful
/// - Use `ddi.isRegistered<Type>()` to check if a bean exists before retrieving it
///
/// Example:
/// ```dart
/// // This will throw BeanNotFoundException
/// final service = ddi.get<MyService>();
///
/// // First register the service
/// ddi.registerSingleton<MyService>(MyService.new);
/// final service = ddi.get<MyService>(); // Now it works
/// ```
class BeanNotFoundException implements Exception {
  const BeanNotFoundException(this.cause);
  final String cause;

  @override
  String toString() {
    return 'No Instance found with Type $cause.';
  }
}
