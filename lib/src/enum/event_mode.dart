import 'dart:async';
import 'dart:isolate';

import 'package:dart_ddi/src/data/event.dart';

/// [EventMode] is an enum that represents the event execution mode
enum EventMode { runAsIsolate, asynchronous, normal }

/// Defines an extension method for [EventMode] that executes the event in the specified mode
extension EventModeExecution on EventMode {
  FutureOr<void> execute<EventTypeT extends Object>(Event<EventTypeT> clazz, EventTypeT value, {int currentTry = 1}) {
    return switch (this) {
      EventMode.runAsIsolate => _runIsolate(clazz, value, currentTry: currentTry),
      EventMode.asynchronous => _runAsynchronous<EventTypeT>(clazz, value, currentTry: currentTry),
      EventMode.normal => _runNormal(clazz, value, currentTry: currentTry)
    };
  }

  Future<void> _runAsynchronous<EventTypeT extends Object>(Event<EventTypeT> clazz, EventTypeT value, {int currentTry = 1}) async {
    if (clazz.event case final Future<void> Function(EventTypeT) event) {
      return event(value)
          .onError((error, stackTrace) => _onError(clazz, value, error, stackTrace, currentTry))
          .whenComplete(() => clazz.onComplete?.call());
    }

    return Future.sync(() => clazz.event(value))
        .onError((error, stackTrace) => _onError(clazz, value, error, stackTrace, currentTry))
        .whenComplete(() => clazz.onComplete?.call());
  }

  FutureOr<void> _runNormal<EventTypeT extends Object>(Event<EventTypeT> clazz, EventTypeT value, {int currentTry = 1}) {
    try {
      return clazz.event(value);
    } catch (error, stackTrace) {
      _onError(clazz, value, error, stackTrace, currentTry);
    } finally {
      clazz.onComplete?.call();
    }
  }

  FutureOr<void> _runIsolate<EventTypeT extends Object>(Event<EventTypeT> clazz, EventTypeT value, {int currentTry = 1}) {
    final Future<void> run = Isolate.run(() => clazz.event(value));

    return run.onError((error, stackTrace) => _onError(clazz, value, error, stackTrace, currentTry)).whenComplete(() => clazz.onComplete?.call());
  }

  FutureOr<void> _onError<EventTypeT extends Object>(
      Event<EventTypeT> clazz, EventTypeT value, Object? error, StackTrace stackTrace, int currentTry) async {
    if (clazz.maxRetry > 0 && currentTry < clazz.maxRetry) {
      if (clazz.retryInterval case final Duration retryInterval? when retryInterval > Duration.zero) {
        await Future.delayed(retryInterval, () => execute<EventTypeT>(clazz, value, currentTry: ++currentTry));
      } else {
        await execute<EventTypeT>(clazz, value, currentTry: ++currentTry);
      }
    } else {
      clazz.onError?.call(error, stackTrace, value);
    }
  }
}
