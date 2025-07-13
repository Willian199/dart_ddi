/// Exception thrown when trying to create a factory that has already been created and registered.
///
/// This exception is thrown in the following scenarios:
/// - When attempting to modify a factory that has already been initialized
/// - When there's an attempt to re-create a factory that's already in the container
///
/// Common causes:
/// - Trying to modify factory configuration after it's been used
/// - Race conditions where the same factory is created simultaneously
///
/// To resolve this issue:
/// - Use proper initialization patterns to avoid duplicate registrations
/// - Handle factory registration in a controlled manner
///
class FactoryAlreadyCreatedException implements Exception {
  const FactoryAlreadyCreatedException(this.cause);
  final String cause;

  @override
  String toString() {
    return 'The Factory is already created for Type $cause.';
  }
}
