import 'dart:async';

/// A simple class to manage locking events, ensuring only one event is processed at a time.
class EventLock {
  /// Holds the last Future that is being executed or has completed.
  Future<void>? _lastEvent;

  /// Executes the given [event] only when there's no previous event in progress.
  ///
  /// This method locks the execution of events to ensure that only one event
  /// is processed at a time. It waits for the completion of the previous event
  /// before executing the new event.
  ///
  /// When called, it sets the new event as [_lastEvent], blocking subsequent
  /// events until the new event completes.
  ///
  /// After the event is executed, [_lastEvent] is set to null, indicating
  /// that no event is in progress, and the Completer is completed to allow
  /// future events to execute.
  Future<void> lock(Future<void> Function() event) async {
    final currentZone = Zone.current;
    final aux = _lastEvent;
    final completer = Completer<void>();

    _lastEvent = completer.future;

    // If there's an ongoing event, wait for it to complete.
    if (aux != null) {
      await aux;
    }

    try {
      // Execute the event passed as a parameter.
      await currentZone.run(event);
    } finally {
      // Clear the reference to the last Future, indicating the current event has ended.
      _lastEvent = null;
      // Complete the Completer, allowing future events to execute.
      completer.complete();
    }
  }
}
