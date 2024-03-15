// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:async';

import 'package:dart_ddi/src/enum/event_mode.dart';
import 'package:dart_ddi/src/features/event_lock.dart';

/// [Event] is a class that represents an event.
class Event<EventTypeT> {
  /// The event to be executed
  final FutureOr<void> Function(EventTypeT) event;

  /// The type of the event
  final Type type;

  /// Whether the event can be unsubscribed
  final bool allowUnsubscribe;

  /// The priority of the event. Less priority events will be executed first
  final int priority;

  /// The mode of the event, can be [EventMode.runAsIsolate], [EventMode.asynchronous] or [EventMode.normal]
  final EventMode mode;

  /// Whether the event should be unsubscribed after being fired
  final bool unsubscribeAfterFire;

  /// The lock instance associated with the event. Can be used to lock the execution of the event
  final EventLock? lock;

  /// The error handler for the event
  final FutureOr<void> Function(Object?, StackTrace, EventTypeT)? onError;

  /// The completion handler for the event
  final FutureOr<void> Function()? onComplete;

  Event({
    required this.event,
    required this.type,
    required this.allowUnsubscribe,
    required this.priority,
    required this.mode,
    this.unsubscribeAfterFire = false,
    this.lock,
    this.onError,
    this.onComplete,
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
        other.lock == lock &&
        other.onError == onError &&
        other.onComplete == onComplete;
  }

  @override
  int get hashCode {
    return event.hashCode ^
        type.hashCode ^
        allowUnsubscribe.hashCode ^
        priority.hashCode ^
        mode.hashCode ^
        unsubscribeAfterFire.hashCode ^
        lock.hashCode ^
        onError.hashCode ^
        onComplete.hashCode;
  }
}
