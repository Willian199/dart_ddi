part of 'dart_ddi_event.dart';

class _DDIEventImpl implements DDIEvent {
  final Map<Object, List<Event>> _events = {};

  @override
  void subscribe<EventTypeT extends Object>(
    void Function(EventTypeT) event, {
    Object? qualifier,
    bool Function()? registerIf,
    bool allowUnsubscribe = true,
    int priority = 0,
    bool unsubscribeAfterFire = false,
  }) {
    _subscribe(
      event: event,
      qualifier: qualifier,
      registerIf: registerIf,
      allowUnsubscribe: allowUnsubscribe,
      priority: priority,
      unsubscribeAfterFire: unsubscribeAfterFire,
      mode: EventMode.normal,
    );
  }

  @override
  void subscribeAsync<EventTypeT extends Object>(
    void Function(EventTypeT) event, {
    Object? qualifier,
    bool Function()? registerIf,
    bool allowUnsubscribe = true,
    int priority = 0,
    bool unsubscribeAfterFire = false,
  }) {
    _subscribe(
      event: event,
      qualifier: qualifier,
      registerIf: registerIf,
      allowUnsubscribe: allowUnsubscribe,
      priority: priority,
      unsubscribeAfterFire: unsubscribeAfterFire,
      mode: EventMode.asynchronous,
    );
  }

  @override
  void subscribeIsolate<EventTypeT extends Object>(
    void Function(EventTypeT) event, {
    Object? qualifier,
    bool Function()? registerIf,
    bool allowUnsubscribe = true,
    int priority = 0,
    bool unsubscribeAfterFire = false,
  }) {
    _subscribe(
      event: event,
      qualifier: qualifier,
      registerIf: registerIf,
      allowUnsubscribe: allowUnsubscribe,
      priority: priority,
      unsubscribeAfterFire: unsubscribeAfterFire,
      mode: EventMode.runAsIsolate,
    );
  }

  void _subscribe<EventTypeT extends Object>({
    required void Function(EventTypeT) event,
    required EventMode mode,
    Object? qualifier,
    bool Function()? registerIf,
    bool allowUnsubscribe = true,
    int priority = 0,
    bool unsubscribeAfterFire = false,
  }) {
    if (registerIf?.call() ?? true) {
      final Object effectiveQualifierName = qualifier ?? EventTypeT;

      assert(allowUnsubscribe || (!allowUnsubscribe && !unsubscribeAfterFire),
          'Not possible to set allowUnsubscribe to false and unsubscribeAfterFire to true');

      _events.putIfAbsent(effectiveQualifierName, () => []);

      final existingEvents =
          _events[effectiveQualifierName]!.cast<Event<EventTypeT>>();
      final isDuplicate = existingEvents.any(
          (existingEvent) => existingEvent.event.hashCode == event.hashCode);

      if (!isDuplicate) {
        existingEvents.add(Event<EventTypeT>(
          event: event,
          type: EventTypeT,
          allowUnsubscribe: allowUnsubscribe,
          priority: priority,
          mode: mode,
          unsubscribeAfterFire: unsubscribeAfterFire,
        ));

        existingEvents.sort((a, b) => a.priority.compareTo(b.priority));
      }
    }
  }

  @override
  void unsubscribe<EventTypeT extends Object>(
    void Function(EventTypeT) event, {
    Object? qualifier,
  }) {
    final effectiveQualifierName = qualifier ?? EventTypeT;

    if (_events[effectiveQualifierName] case final eventsList? when eventsList.isNotEmpty) {
      eventsList.cast<Event<EventTypeT>>().removeWhere(
          (e) => e.allowUnsubscribe && e.event.hashCode == event.hashCode);
    }
  }

  @override
  void fire<EventTypeT extends Object>(EventTypeT value, {Object? qualifier}) {
    final effectiveQualifierName = qualifier ?? EventTypeT;

    if (_events[effectiveQualifierName] case final eventsList? when eventsList.isNotEmpty) {
      final eventsToRemove = <Event<EventTypeT>>[];

      for (final Event<EventTypeT> event
          in eventsList.cast<Event<EventTypeT>>()) {
        event.mode.execute<EventTypeT>(event.event, value);

        if (event.unsubscribeAfterFire) {
          eventsToRemove.add(event);
        }
      }

      for (final Event<EventTypeT> event in eventsToRemove) {
        _events[effectiveQualifierName]?.remove(event);
      }
    } else {
      throw EventNotFound(effectiveQualifierName.toString());
    }
  }
}
