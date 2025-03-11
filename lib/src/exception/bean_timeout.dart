/// [BeanTimeoutException] is an exception that is thrown when tried to access a bean that exist, but take too long.
class BeanTimeoutException implements Exception {
  const BeanTimeoutException(this.cause);
  final String cause;

  @override
  String toString() {
    return 'Instance with Type $cause was found, but the request took too long.';
  }
}
