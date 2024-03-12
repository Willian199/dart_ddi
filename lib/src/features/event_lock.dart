import 'dart:async';

class EventLock {
  Future<void>? _lastEvent;

  Future<void> lock(FutureOr<void> Function() event) async {
    final aux = _lastEvent;
    final completer = Completer<void>();

    _lastEvent = completer.future;

    if (aux != null) {
      await aux;
    }

    try {
      if (event is Future<void> Function()) {
        await event();
      } else {
        event();
      }
    } finally {
      _lastEvent = null;
      completer.complete();
    }
  }
}
