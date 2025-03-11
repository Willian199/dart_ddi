/// [FactoryAlreadyCreatedException] is an exception that is thrown when the facotry is already created. Blocking creating the factory again.
class FactoryAlreadyCreatedException implements Exception {
  const FactoryAlreadyCreatedException(this.cause);
  final String cause;

  @override
  String toString() {
    return 'The Factory is already created for Type $cause.';
  }
}
