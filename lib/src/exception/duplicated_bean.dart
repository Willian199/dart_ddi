/// Exception thrown when trying to register a bean that already exists in the DDI container.
///
/// This exception is thrown in the following scenarios:
/// - When calling `ddi.registerSingleton<Type>()` for a type that's already registered
/// - When calling `ddi.registerApplication<Type>()` for a type that's already registered
/// - When calling `ddi.registerDependent<Type>()` for a type that's already registered
/// - When registering with the same qualifier that's already in use
/// - When trying to register a factory for a type that already has a factory
///
/// Common causes:
/// - Registering the same service multiple times in different parts of the code
/// - Using the same qualifier for different services
/// - Registering services in multiple modules without proper coordination
/// - Forgetting to check if a service is already registered before registering it
///
/// To resolve this issue:
/// - Use `ddi.isRegistered<Type>()` to check if a bean exists before registering it
/// - Use different qualifiers for different instances of the same type
/// - Ensure that registration happens only once per application lifecycle
/// - Use conditional registration with `canRegister` parameter
///
/// Example:
/// ```dart
/// // This will throw DuplicatedBeanException
/// ddi.registerSingleton<MyService>(MyService.new);
/// ddi.registerSingleton<MyService>(MyService.new); // Duplicate!
///
/// // Use conditional registration to avoid duplicates
/// if (!ddi.isRegistered<MyService>()) {
///   ddi.registerSingleton<MyService>(MyService.new);
/// }
///
/// // Or use different qualifiers
/// ddi.registerSingleton<MyService>(MyService.new, qualifier: 'service1');
/// ddi.registerSingleton<MyService>(MyService.new, qualifier: 'service2');
/// ```
class DuplicatedBeanException implements Exception {
  const DuplicatedBeanException(this.type);
  final String type;

  @override
  String toString() {
    return 'Is already registered a instance with Type $type';
  }
}
