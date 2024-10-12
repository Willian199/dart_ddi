/// [FactoryNullException] is an exception that is thrown when simpleFactory and customFactory is null.
class FactoryNullException implements Exception {
  const FactoryNullException(this.type);
  final String type;

  @override
  String toString() {
    return 'Either simpleFactory or customFactory must be provided';
  }
}
