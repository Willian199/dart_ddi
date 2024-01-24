class DuplicatedBean implements Exception {
  const DuplicatedBean(this.type);
  final String type;

  @override
  String toString() {
    return 'Is already registered a instance with Type $type';
  }
}
