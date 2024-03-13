import 'dart:async';

class EventLock {
  Future<void>? _lastEvent;

  Future<void> lock(Future<void> Function() event) async {
    final aux = _lastEvent;
    final completer = Completer<void>();

    _lastEvent = completer.future;

    if (aux != null) {
      await aux;
    }

    try {
      await event();
    } finally {
      _lastEvent = null;
      completer.complete();
    }
  }
}
