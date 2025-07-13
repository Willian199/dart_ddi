/// Exception thrown when trying to register a factory that is not valid for the specified type.
///
/// This exception is thrown in the following scenarios:
/// - When trying to register a factory for the generic `Object` type
/// - When the factory type doesn't match the expected bean type
///
/// Common causes:
/// - Using `Object` as the generic type parameter instead of a specific type
/// - Mismatch between the factory's return type and the expected bean type
///
/// To resolve this issue:
/// - Use specific types instead of `Object` when registering factories
/// - Ensure the factory's return type matches the expected bean type
///
/// Example:
/// ```dart
/// // This will throw FactoryNotAllowedException
/// ddi.register<Object>(factory: myFactory); // Object is not allowed
///
/// // Use a specific type instead
/// ddi.register<MyService>(factory: myFactory);
///
/// // Or ensure the factory type matches
/// ddi.register<MyService>(
///   factory: ApplicationFactory<MyService>(
///     builder: MyService.new.builder,
///   ),
/// );
/// ```
class FactoryNotAllowedException implements Exception {
  const FactoryNotAllowedException(this.cause);
  final String cause;

  @override
  String toString() {
    return 'The Factory is not valid for Type $cause.';
  }
}
