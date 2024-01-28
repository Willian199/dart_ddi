class BeanNotFound implements Exception {
  const BeanNotFound(this.cause);
  final String cause;

  @override
  String toString() {
    return 'No Instance found with Type $cause.';
  }
}
