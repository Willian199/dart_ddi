part of 'dart_ddi_event.dart';

class _DDIEventImpl implements DDIEvent {
  final Map<Object, List<Event>> _events = {};

  @override
  void subscribe<T extends Object>(
    void Function(T) event, {
    Object? qualifier,
    bool Function()? registerIf,
    bool destroyable = true,
    int priority = 0,
    bool isAsync = false,
    bool unsubscribeAfterFire = false,
  }) {
    if (registerIf?.call() ?? true) {
      final Object effectiveQualifierName = qualifier ?? T;

      assert(destroyable || (!destroyable && !unsubscribeAfterFire), 'Not possible to set destroyable to false and unsubscribeAfterFire to true');

      _events.putIfAbsent(effectiveQualifierName, () => []);

      final existingEvents = _events[effectiveQualifierName]!.cast<Event<T>>();
      final isDuplicate = existingEvents.any((existingEvent) => identical(existingEvent.event, event));

      if (!isDuplicate) {
        existingEvents.add(Event<T>(
          event: event,
          type: T,
          destroyable: destroyable,
          priority: priority,
          isAsync: isAsync,
          unsubscribeAfterFire: unsubscribeAfterFire,
        ));

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
      eventsList.removeWhere((e) => e.destroyable && identical(e.event, event));
    }
  }

  @override
  void fire<T extends Object>(T value, {Object? qualifier}) {
    final effectiveQualifierName = qualifier ?? T;

    final eventsList = _events[effectiveQualifierName]?.cast<Event<T>>();

    if (eventsList != null) {
      final eventsToRemove = <Event<T>>[];

      for (final Event<T> event in eventsList) {
        if (event.isAsync) {
          Future.microtask(() => event.event(value));
        } else {
          event.event(value);
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
