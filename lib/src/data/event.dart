// ignore_for_file: public_member_api_docs, sort_constructors_first

class Events<T> {
  final void Function(T) event;
  final Type type;
  final bool destroyable;

  Events({
    required this.event,
    required this.type,
    required this.destroyable,
  });
}
