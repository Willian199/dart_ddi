// ignore_for_file: public_member_api_docs, sort_constructors_first

class Event<T> {
  final void Function(T) event;
  final Type type;
  final bool allowUnsubscribe;
  final int priority;
  final bool isAsync;
  final bool unsubscribeAfterFire;
  final bool runAsIsolate;

  Event({
    required this.event,
    required this.type,
    required this.allowUnsubscribe,
    required this.priority,
    this.isAsync = false,
    this.unsubscribeAfterFire = false,
    this.runAsIsolate = false,
  });

  @override
  bool operator ==(covariant Event<T> other) {
    if (identical(this, other)) return true;

    return other.event == event &&
        other.type == type &&
        other.allowUnsubscribe == allowUnsubscribe &&
        other.priority == priority &&
        other.isAsync == isAsync &&
        other.unsubscribeAfterFire == unsubscribeAfterFire &&
        other.runAsIsolate == runAsIsolate;
  }

  @override
  int get hashCode {
    return event.hashCode ^
        type.hashCode ^
        allowUnsubscribe.hashCode ^
        priority.hashCode ^
        isAsync.hashCode ^
        unsubscribeAfterFire.hashCode ^
        runAsIsolate.hashCode;
  }
}
