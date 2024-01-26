class BeanNotFound implements Exception {
  const BeanNotFound(this.cause);
  final String cause;

  @override
  String toString() {
    return 'No Instance with Type $cause is found.';
  }
}
