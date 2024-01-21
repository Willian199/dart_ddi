part of 'dart_ddi_event.dart';

class _DDIEventImpl implements DDIEvent {
  final Map<Object, List<Event>> _events = {};

  @override
  void subscribe<T extends Object>(
    void Function(T) event, {
    Object? qualifier,
    bool Function()? registerIf,
    bool allowUnsubscribe = true,
    int priority = 0,
    bool isAsync = false,
    bool unsubscribeAfterFire = false,
    bool runAsIsolate = false,
  }) {
    if (registerIf?.call() ?? true) {
      final Object effectiveQualifierName = qualifier ?? T;

      assert(allowUnsubscribe || (!allowUnsubscribe && !unsubscribeAfterFire),
          'Not possible to set allowUnsubscribe to false and unsubscribeAfterFire to true');

      _events.putIfAbsent(effectiveQualifierName, () => []);

      final existingEvents = _events[effectiveQualifierName]!.cast<Event<T>>();
      final isDuplicate = existingEvents
          .any((existingEvent) => existingEvent.hashCode == event.hashCode);

      if (!isDuplicate) {
        existingEvents.add(Event<T>(
            event: event,
            type: T,
            allowUnsubscribe: allowUnsubscribe,
            priority: priority,
            isAsync: isAsync,
            unsubscribeAfterFire: unsubscribeAfterFire,
            runAsIsolate: runAsIsolate));

        existingEvents.sort((a, b) => a.priority.compareTo(b.priority));
      }
    }
  }

  @override
  void unsubscribe<T extends Object>(
    void Function(T) event, {
    Object? qualifier,
  }) {
    final effectiveQualifierName = qualifier ?? T;

    //Without the cast, removeWhere fails beacause the type is Event<dynamic>
    final eventsList = _events[effectiveQualifierName]?.cast<Event<T>>();

    if (eventsList != null) {
      eventsList.removeWhere(
          (e) => e.allowUnsubscribe && e.event.hashCode == event.hashCode);
    }
  }

  @override
  void fire<T extends Object>(T value, {Object? qualifier}) {
    final effectiveQualifierName = qualifier ?? T;

    final eventsList = _events[effectiveQualifierName]?.cast<Event<T>>();

    if (eventsList != null) {
      final eventsToRemove = <Event<T>>[];

      for (final Event<T> event in eventsList) {
        switch (event) {
          case Event(runAsIsolate: true):
            Isolate.run(() => event.event(value));
            break;
          case Event(isAsync: false):
            event.event(value);
            break;
          case Event(isAsync: true):
            Future.microtask(() => event.event(value));
            break;
        }

        if (event.unsubscribeAfterFire) {
          eventsToRemove.add(event);
        }
      }

      for (final Event<T> event in eventsToRemove) {
        _events[effectiveQualifierName]?.remove(event);
      }
    }
  }
}
