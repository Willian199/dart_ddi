import 'dart:async';

import 'package:dart_ddi/src/data/event.dart';
import 'package:dart_ddi/src/enum/event_mode.dart';
import 'package:dart_ddi/src/exception/event_not_allowed.dart';
import 'package:dart_ddi/src/exception/event_not_found.dart';
import 'package:dart_ddi/src/features/event_lock.dart';

part 'dart_ddi_event_impl.dart';

/// Shortcut for getting the shared instance of the [DDIEvent] class.
/// The [DDIEvent] class provides methods for subscribing and unsubscribing to events.
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
  /// - `allowUnsubscribe:` Indicates if the event can be unsubscribe. Ignored if `autoRun` is used.
  ///
  /// - `priority:` Priority of the subscription relative to other subscriptions (lower values indicate higher priority). Ignored if `autoRun` is used.
  ///
  /// - `unsubscribeAfterFire:` If true, the subscription will be automatically removed after the first time the event is fired. Ignored if `autoRun` is used.
  ///
  /// - `lock`: Indicates if the event should be locked. Running only one event simultaneously. Cannot be used in combination with `autoRun`.
  ///
  /// - `onError`: The callback function to be executed when an error occurs.
  ///
  /// - `onComplete`: The callback function to be executed when the event is completed.
  ///
  /// - `expirationDuration`: The duration after which the subscription will be automatically removed.
  ///
  /// - `retryInterval`: Adds the ability to automatically run the event multiple times. It is not recommended to fire the event manually.
  ///
  /// - `defaultValue`: The default value to be used when the event is fired. Required if `autoRun` is used.
  ///
  /// - `maxRetry`: The maximum number of times the subscription will be automatically fired if `autoRun` is used.
  ///   * If maxRetry is 0, will run forever.
  ///   * If maxRetry is greater than 0, the subscription will be removed when the maximum number of retries is reached.
  ///   * If `expirationDuration` is used, the subscription will be removed when the first rule is met, either when the expiration duration is reached or when the maximum number of retries is reached.
  ///
  /// - `autoRun`: If true, the event will be automatically run when the subscription is created.
  ///   * Only one event is allowed.
  ///   * `allowUnsubscribe` is ignored.
  ///   * `unsubscribeAfterFire` is ignored.
  ///   * `priority` is ignored.
  ///   * Cannot be used in combination with `lock`.
  ///   * Requires the `defaultValue` parameter.
  ///   * If maxRetry is 0, will run forever.
  ///
  /// - `filter`: Allows you to filter events based on their value. Only events when the filter returns true will be fired.
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
    Duration? expirationDuration,
    bool autoRun = false,
    Duration? retryInterval,
    EventTypeT? defaultValue,
    int maxRetry = 0,
    FutureOr<bool> Function(EventTypeT)? filter,
  });

  /// Subscribes an Async callback function to an event.
  ///
  /// - `event`: The callback function to be executed when the event is fired.
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different events of the same type.
  ///
  /// - `registerIf`: A bool function that if returns true, allows the subscription to proceed.
  ///
  /// - `allowUnsubscribe:` Indicates if the event can be unsubscribe. Ignored if `autoRun` is used.
  ///
  /// - `priority:` Priority of the subscription relative to other subscriptions (lower values indicate higher priority). Ignored if `autoRun` is used.
  ///
  /// - `unsubscribeAfterFire:` If true, the subscription will be automatically removed after the first time the event is fired. Ignored if `autoRun` is used.
  ///
  /// - `lock`: Indicates if the event should be locked. Running only one event simultaneously. Cannot be used in combination with `autoRun`.
  ///
  /// - `onError`: The callback function to be executed when an error occurs.
  ///
  /// - `onComplete`: The callback function to be executed when the event is completed.
  ///
  /// - `expirationDuration`: The duration after which the subscription will be automatically removed.
  ///
  /// - `retryInterval`: Adds the ability to automatically retry the event after the interval specified. Can be used in combination with `autoRun` and `onError`.
  ///
  /// - `defaultValue`: The default value to be used when the event is fired. Required if `autoRun` is used.
  ///
  /// - `maxRetry`: The maximum number of times the subscription will be automatically fired if `autoRun` is used.
  ///   * Can be used in combination with `autoRun` and `onError`.
  ///   * If `maxRetry` is 0 and `autoRun` is true, will run forever.
  ///   * If `maxRetry` is greater than 0 and `autoRun` is true, the subscription will be removed when the maximum number of retries is reached.
  ///   * If `maxRetry` is greater than 0, `autoRun` is false and `onError` is used, the subscription will stop retrying when the maximum number is reached.
  ///   * If `expirationDuration` is used, the subscription will be removed when the first rule is met, either when the expiration duration is reached or when the maximum number of retries is reached.
  ///
  /// - `autoRun`: If true, the event will be automatically run when the subscription is created.
  ///   * Only one event is allowed.
  ///   * `allowUnsubscribe` is ignored.
  ///   * `unsubscribeAfterFire` is ignored.
  ///   * `priority` is ignored.
  ///   * Cannot be used in combination with `lock`.
  ///   * Requires the `defaultValue` parameter.
  ///   * If `maxRetry` is 0, will run forever.
  ///
  /// - `filter`: Allows you to filter events based on their value. Only events when the filter returns true will be fired.
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
    Duration? expirationDuration,
    bool autoRun = false,
    Duration? retryInterval,
    EventTypeT? defaultValue,
    int maxRetry = 0,
    FutureOr<bool> Function(EventTypeT)? filter,
  });

  /// Subscribes an Isolate callback function to an event.
  ///
  /// - `event`: The callback function to be executed when the event is fired.
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different events of the same type.
  ///
  /// - `registerIf`: A bool function that if returns true, allows the subscription to proceed.
  ///
  /// - `allowUnsubscribe:` Indicates if the event can be unsubscribe. Ignored if `autoRun` is used.
  ///
  /// - `priority:` Priority of the subscription relative to other subscriptions (lower values indicate higher priority). Ignored if `autoRun` is used.
  ///
  /// - `unsubscribeAfterFire:` If true, the subscription will be automatically removed after the first time the event is fired. Ignored if `autoRun` is used.
  ///
  /// - `lock`: Indicates if the event should be locked. Running only one event simultaneously. Cannot be used in combination with `autoRun`.
  ///
  /// - `onError`: The callback function to be executed when an error occurs.
  ///
  /// - `onComplete`: The callback function to be executed when the event is completed.
  ///
  /// - `expirationDuration`: The duration after which the subscription will be automatically removed.
  ///
  /// - `retryInterval`: Adds the ability to automatically run the event multiple times. It is not recommended to fire the event manually.
  ///
  /// - `defaultValue`: The default value to be used when the event is fired. Required if `autoRun` is used.
  ///
  /// - `maxRetry`: The maximum number of times the subscription will be automatically fired if `autoRun` is used.
  ///   * If maxRetry is 0, will run forever.
  ///   * If maxRetry is greater than 0, the subscription will be removed when the maximum number of retries is reached.
  ///   * If `expirationDuration` is used, the subscription will be removed when the first rule is met, either when the expiration duration is reached or when the maximum number of retries is reached.
  ///
  /// - `autoRun`: If true, the event will be automatically run when the subscription is created.
  ///   * Only one event is allowed.
  ///   * `allowUnsubscribe` is ignored.
  ///   * `unsubscribeAfterFire` is ignored.
  ///   * `priority` is ignored.
  ///   * Cannot be used in combination with `lock`.
  ///   * Requires the `defaultValue` parameter.
  ///   * If maxRetry is 0, will run forever.
  ///
  /// - `filter`: Allows you to filter events based on their value. Only events when the filter returns true will be fired.
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
    Duration? expirationDuration,
    Duration? retryInterval,
    bool autoRun = false,
    EventTypeT? defaultValue,
    int maxRetry = 0,
    FutureOr<bool> Function(EventTypeT)? filter,
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
