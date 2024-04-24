/// [BeanNotAllowedException] is an exception that is thrown when tried to access a bean that doesn't exist.
class BeanNotAllowedException implements Exception {
  const BeanNotAllowedException(this.cause);
  final String cause;

  @override
  String toString() {
    return 'The Instance with Type $cause. is not allowed.';
  }
}
