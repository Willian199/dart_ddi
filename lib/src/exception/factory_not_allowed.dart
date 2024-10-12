/// [FactoryNotAllowedException] is an exception that is thrown when the facotry isn't valid and must be correct.
class FactoryNotAllowedException implements Exception {
  const FactoryNotAllowedException(this.cause);
  final String cause;

  @override
  String toString() {
    return 'The Factory is not valid for Type $cause.';
  }
}
