/// [FactoryUnknowTypeException] is an exception that is thrown when the customFactory isn't explicit.
class FactoryUnknowTypeException implements Exception {
  const FactoryUnknowTypeException(this.type);
  final String type;

  @override
  String toString() {
    return 'You must specify the type of the customFactory. $type';
  }
}
