class BeanNotFound implements Exception {
  const BeanNotFound(this.cause);
  final String cause;
}
