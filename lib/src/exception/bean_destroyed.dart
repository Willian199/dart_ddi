class BeanDestroyed implements Exception {
  const BeanDestroyed(this.type);
  final String type;

  @override
  String toString() {
    return 'The Singleton Type $type is destroyed';
  }
}
