// ignore_for_file: public_member_api_docs, sort_constructors_first

class Event<T> {
  final void Function(T) event;
  final Type type;
  final bool destroyable;

  Event({
    required this.event,
    required this.type,
    required this.destroyable,
  });

  @override
  bool operator ==(covariant Event<T> other) {
    if (identical(this, other)) return true;

    return other.event == event && other.type == type && other.destroyable == destroyable;
  }

  @override
  int get hashCode => event.hashCode ^ type.hashCode ^ destroyable.hashCode;
}
