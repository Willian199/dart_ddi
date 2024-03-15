import 'dart:async';
import 'dart:isolate';

import 'package:dart_ddi/src/data/event.dart';

/// [EventMode] is an enum that represents the event execution mode
enum EventMode { runAsIsolate, asynchronous, normal }

/// Defines an extension method for [EventMode] that executes the event in the specified mode
extension EventModeExecution on EventMode {
  FutureOr<void> execute<EventTypeT extends Object>(
      Event<EventTypeT> clazz, EventTypeT value) {
    return switch (this) {
      EventMode.runAsIsolate => _runIsolate(clazz, value),
      EventMode.asynchronous => _runAsynchronous<EventTypeT>(clazz, value),
      EventMode.normal => _runNormal(clazz, value)
    };
  }

  Future<void> _runAsynchronous<EventTypeT>(
      Event<EventTypeT> clazz, EventTypeT value) async {
    if (clazz.event case final Future<void> Function(EventTypeT) event) {
      return event(value)
          .onError((error, stackTrace) =>
              clazz.onError?.call(error, stackTrace, value))
          .whenComplete(() => clazz.onComplete?.call());
    }

    return Future.sync(() => clazz.event(value))
        .onError((error, stackTrace) =>
            clazz.onError?.call(error, stackTrace, value))
        .whenComplete(() => clazz.onComplete?.call());
  }

  FutureOr<void> _runNormal<EventTypeT>(
      Event<EventTypeT> clazz, EventTypeT value) {
    try {
      return clazz.event(value);
    } catch (error, stackTrace) {
      clazz.onError?.call(error, stackTrace, value);
    } finally {
      clazz.onComplete?.call();
    }
  }

  FutureOr<void> _runIsolate<EventTypeT>(
      Event<EventTypeT> clazz, EventTypeT value) {
    final Future<void> run = Isolate.run(() => clazz.event(value));

    return run
        .onError((error, stackTrace) =>
            clazz.onError?.call(error, stackTrace, value))
        .whenComplete(() => clazz.onComplete?.call());
  }
}
