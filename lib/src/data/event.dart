// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:dart_ddi/src/enum/event_mode.dart';
import 'package:dart_ddi/src/features/event_lock.dart';

class Event<EventTypeT> {
  final void Function(EventTypeT) event;
  final Type type;
  final bool allowUnsubscribe;
  final int priority;
  final EventMode mode;
  final bool unsubscribeAfterFire;
  final EventLock? lock;

  Event({
    required this.event,
    required this.type,
    required this.allowUnsubscribe,
    required this.priority,
    required this.mode,
    this.unsubscribeAfterFire = false,
    this.lock,
  });

  @override
  bool operator ==(covariant Event<EventTypeT> other) {
    if (identical(this, other)) return true;

    return other.event == event &&
        other.type == type &&
        other.allowUnsubscribe == allowUnsubscribe &&
        other.priority == priority &&
        other.mode == mode &&
        other.unsubscribeAfterFire == unsubscribeAfterFire &&
        other.lock == lock;
  }

  @override
  int get hashCode {
    return event.hashCode ^
        type.hashCode ^
        allowUnsubscribe.hashCode ^
        priority.hashCode ^
        mode.hashCode ^
        unsubscribeAfterFire.hashCode ^
        lock.hashCode;
  }
}
