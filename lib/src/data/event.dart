// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:async';

import 'package:dart_ddi/src/enum/event_mode.dart';
import 'package:dart_ddi/src/features/event_lock.dart';

/// [Event] is a class that represents an event.
final class Event<EventTypeT> {
  /// The event to be executed
  final FutureOr<void> Function(EventTypeT) event;

  /// The type of the event
  final Type type;

  /// Whether the event can be unsubscribed
  final bool canUnsubscribe;

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

  /// The retry interval for the event
  final Duration? retryInterval;

  /// Maximum number of retries for the event
  final int maxRetry;

  /// The filter for the event
  final FutureOr<bool> Function(EventTypeT)? filter;

  Event({
    required this.event,
    required this.type,
    required this.canUnsubscribe,
    required this.priority,
    required this.mode,
    this.unsubscribeAfterFire = false,
    this.lock,
    this.onError,
    this.onComplete,
    this.retryInterval,
    this.maxRetry = 0,
    this.filter,
  });

  @override
  bool operator ==(covariant Event<EventTypeT> other) {
    if (identical(this, other)) return true;

    return other.event == event &&
        other.type == type &&
        other.canUnsubscribe == canUnsubscribe &&
        other.priority == priority &&
        other.mode == mode &&
        other.unsubscribeAfterFire == unsubscribeAfterFire &&
        other.lock == lock &&
        other.onError == onError &&
        other.onComplete == onComplete &&
        other.retryInterval == retryInterval &&
        other.maxRetry == maxRetry &&
        other.filter == filter;
  }

  @override
  int get hashCode {
    return event.hashCode ^
        type.hashCode ^
        canUnsubscribe.hashCode ^
        priority.hashCode ^
        mode.hashCode ^
        unsubscribeAfterFire.hashCode ^
        lock.hashCode ^
        onError.hashCode ^
        onComplete.hashCode ^
        retryInterval.hashCode ^
        maxRetry.hashCode ^
        filter.hashCode;
  }
}
