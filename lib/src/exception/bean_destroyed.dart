/// [BeanDestroyedException] is an exception that is thrown when tried to access a bean destroyed.
class BeanDestroyedException implements Exception {
  const BeanDestroyedException(this.type);
  final String type;

  @override
  String toString() {
    return 'The Singleton Type $type is destroyed';
  }
}
