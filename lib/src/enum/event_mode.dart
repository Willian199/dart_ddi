import 'dart:isolate';

enum EventMode { runAsIsolate, asynchronous, normal }

extension EventModeExecution on EventMode {
  void execute<EventTypeT extends Object>(void Function(EventTypeT) event, EventTypeT value) {
    switch (this) {
      case EventMode.runAsIsolate:
        Isolate.run(() => event(value));
        break;
      case EventMode.asynchronous:
        Future.microtask(() => event(value));
        break;
      case EventMode.normal:
        event(value);
        break;
    }
  }
}
