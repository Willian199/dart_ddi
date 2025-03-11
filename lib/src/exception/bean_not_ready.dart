/// [BeanNotReadyException] is an exception that is thrown when tried to access a bean that exist, but the instance is not ready.
class BeanNotReadyException implements Exception {
  const BeanNotReadyException(this.cause);
  final String cause;

  @override
  String toString() {
    return 'Instance with Type $cause was found, but is not ready yet.';
  }
}
