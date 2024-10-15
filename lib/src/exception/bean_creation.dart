/// [BeanCreationException] is thrown when an error occurs during the creation of a Bean.
class BeanCreationException implements Exception {
  const BeanCreationException(this.type);
  final String type;

  @override
  String toString() {
    return 'Failed to create Bean of type $type';
  }
}
