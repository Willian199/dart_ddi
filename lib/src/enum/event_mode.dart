import 'dart:async';
import 'dart:isolate';

enum EventMode { runAsIsolate, asynchronous, normal }

extension EventModeExecution on EventMode {
  FutureOr<void> execute<EventTypeT extends Object>(
      void Function(EventTypeT) event, EventTypeT value) {
    return switch (this) {
      EventMode.runAsIsolate => Isolate.run(() => event(value)),
      EventMode.asynchronous => Future.sync(() => event(value)),
      EventMode.normal => event(value) as FutureOr<void>
    };
  }
}
