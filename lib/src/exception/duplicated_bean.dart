/// [DuplicatedBeanException] is an exception that is thrown when tried to register a bean that already exists.
class DuplicatedBeanException implements Exception {
  const DuplicatedBeanException(this.type);
  final String type;

  @override
  String toString() {
    return 'Is already registered a instance with Type $type';
  }
}
