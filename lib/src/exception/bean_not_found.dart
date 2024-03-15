/// [BeanNotFoundException] is an exception that is thrown when tried to access a bean that doesn't exist.
class BeanNotFoundException implements Exception {
  const BeanNotFoundException(this.cause);
  final String cause;

  @override
  String toString() {
    return 'No Instance found with Type $cause.';
  }
}
