import 'dart:async';

import 'package:dart_ddi/src/data/event.dart';
import 'package:dart_ddi/src/enum/event_mode.dart';
import 'package:dart_ddi/src/exception/event_not_found.dart';
import 'package:dart_ddi/src/features/event_lock.dart';

part 'dart_ddi_event_impl.dart';

/// Shortcut for getting the shared instance of the [DDIEvent] class.
/// The [DDIEvent] class provides methods for subscribing and unsubscribing
DDIEvent ddiEvent = DDIEvent.instance;

/// This class provides methods for subscribing and unsubscribing to events
/// and for dispatching events with optional qualifiers.
///
abstract class DDIEvent {
  /// Creates the shared instance of the [DDIEvent] class.
  static final DDIEvent _instance = _DDIEventImpl();

  /// Gets the shared instance of the [DDIEvent] class.
  static DDIEvent get instance => _instance;

  /// Subscribes a callback function to an event.
  ///
  /// - `event`: The callback function to be executed when the event is fired.
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different events of the same type.
  ///
  /// - `registerIf`: A bool function that if returns true, allows the subscription to proceed.
  ///
  /// - `allowUnsubscribe`: Indicates if the event can be unsubscribe.
  ///
  /// - `priority`: Priority of the subscription relative to other subscriptions (lower values indicate higher priority).
  ///
  /// - `unsubscribeAfterFire`: If true, the subscription will be automatically removed after the first time the event is fired.
  ///
  /// - `lock`: Indicates if the event should be locked.
  ///
  /// - `onError`: The callback function to be executed when an error occurs.
  ///
  /// - `onComplete`: The callback function to be executed when the event is completed.
  ///
  Future<void> subscribe<EventTypeT extends Object>(
    FutureOr<void> Function(EventTypeT) event, {
    Object? qualifier,
    FutureOr<bool> Function()? registerIf,
    bool allowUnsubscribe = true,
    int priority = 0,
    bool unsubscribeAfterFire = false,
    bool lock = false,
    FutureOr<void> Function(Object?, StackTrace, EventTypeT)? onError,
    FutureOr<void> Function()? onComplete,
  });

  /// Subscribes an Async callback function to an event.
  ///
  /// - `event`: The callback function to be executed when the event is fired.
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different events of the same type.
  ///
  /// - `registerIf`: A bool function that if returns true, allows the subscription to proceed.
  ///
  /// - `allowUnsubscribe`: Indicates if the event can be unsubscribe.
  ///
  /// - `priority`: Priority of the subscription relative to other subscriptions (lower values indicate higher priority).
  ///
  /// - `unsubscribeAfterFire`: If true, the subscription will be automatically removed after the first time the event is fired.
  ///
  /// - `lock`: Indicates if the event should be locked.
  ///
  /// - `onError`: The callback function to be executed when an error occurs.
  ///
  /// - `onComplete`: The callback function to be executed when the event is completed.
  ///
  Future<void> subscribeAsync<EventTypeT extends Object>(
    FutureOr<void> Function(EventTypeT) event, {
    Object? qualifier,
    FutureOr<bool> Function()? registerIf,
    bool allowUnsubscribe = true,
    int priority = 0,
    bool unsubscribeAfterFire = false,
    bool lock = false,
    FutureOr<void> Function(Object?, StackTrace, EventTypeT)? onError,
    FutureOr<void> Function()? onComplete,
  });

  /// Subscribes an Isolate callback function to an event.
  ///
  /// - `event`: The callback function to be executed when the event is fired.
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different events of the same type.
  ///
  /// - `registerIf`: A bool function that if returns true, allows the subscription to proceed.
  ///
  /// - `allowUnsubscribe`: Indicates if the event can be unsubscribe.
  ///
  /// - `priority`: Priority of the subscription relative to other subscriptions (lower values indicate higher priority).
  ///
  /// - `unsubscribeAfterFire`: If true, the subscription will be automatically removed after the first time the event is fired.
  ///
  /// - `lock`: Indicates if the event should be locked.
  ///
  /// - `onError`: The callback function to be executed when an error occurs.
  ///
  /// - `onComplete`: The callback function to be executed when the event is completed.
  ///
  Future<void> subscribeIsolate<EventTypeT extends Object>(
    FutureOr<void> Function(EventTypeT) event, {
    Object? qualifier,
    FutureOr<bool> Function()? registerIf,
    bool allowUnsubscribe = true,
    int priority = 0,
    bool unsubscribeAfterFire = false,
    bool lock = false,
    FutureOr<void> Function(Object?, StackTrace, EventTypeT)? onError,
    FutureOr<void> Function()? onComplete,
  });

  /// Unsubscribes a callback function from an event.
  ///
  /// - `event`: The callback function to be unsubscribed.
  ///
  /// - `qualifier`: Optional qualifier name used to distinguish between different events of the same type.
  void unsubscribe<EventTypeT extends Object>(void Function(EventTypeT) event,
      {Object? qualifier});

  /// Fires an event with the specified value.
  ///
  /// - `value`: The value to be passed to the subscribed callback functions.
  ///
  /// - `qualifier`: Optional qualifier name used to distinguish between different events of the same type.
  void fire<EventTypeT extends Object>(EventTypeT value, {Object? qualifier});

  /// Fires an event with the specified value with the ability to await conclusion.
  ///
  /// - `value`: The value to be passed to the subscribed callback functions.
  ///
  /// - `qualifier`: Optional qualifier name used to distinguish between different events of the same type.
  Future<void> fireWait<EventTypeT extends Object>(EventTypeT value,
      {Object? qualifier});

  /// Verify if an event is already registered.
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  ///
  /// Returns `true` if the event is already registered.
  bool isRegistered<EventTypeT extends Object>({Object? qualifier});
}
