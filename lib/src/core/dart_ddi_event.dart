import 'dart:isolate';

import 'package:dart_ddi/src/data/event.dart';

part 'dart_ddi_event_impl.dart';

/// The abstract class for managing event emission.
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
  /// - `isAsync`: If true, the callback function will be executed asynchronously.
  ///
  /// - `unsubscribeAfterFire`: If true, the subscription will be automatically removed after the first time the event is fired.
  void subscribe<T extends Object>(
    void Function(T) event, {
    Object? qualifier,
    bool Function()? registerIf,
    bool allowUnsubscribe = true,
    int priority = 0,
    bool isAsync = false,
    bool unsubscribeAfterFire = false,
    bool runAsIsolate = false,
  });

  /// Unsubscribes a callback function from an event.
  ///
  /// - `event`: The callback function to be unsubscribed.
  ///
  /// - `qualifier`: Optional qualifier name used to distinguish between different events of the same type.
  void unsubscribe<T extends Object>(void Function(T) event, {Object? qualifier});

  /// Fires an event with the specified value.
  ///
  /// - `value`: The value to be passed to the subscribed callback functions.
  ///
  /// - `qualifier`: Optional qualifier name used to distinguish between different events of the same type.
  void fire<T extends Object>(T value, {Object? qualifier});
}
