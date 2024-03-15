part of 'dart_ddi_event.dart';

class _DDIEventImpl implements DDIEvent {
  final Map<Object, List<Event>> _events = {};

  @override
  Future<void> subscribe<EventTypeT extends Object>(
    FutureOr<void> Function(EventTypeT) event, {
    Object? qualifier,
    FutureOr<bool> Function()? registerIf,
    bool allowUnsubscribe = true,
    int priority = 0,
    bool unsubscribeAfterFire = false,
    bool lock = false,
    FutureOr<void> Function(Object?, StackTrace, EventTypeT)? onError,
    FutureOr<void> Function()? onComplete,
  }) {
    return _subscribe(
      event: event,
      qualifier: qualifier,
      registerIf: registerIf,
      allowUnsubscribe: allowUnsubscribe,
      priority: priority,
      unsubscribeAfterFire: unsubscribeAfterFire,
      mode: EventMode.normal,
      lock: lock,
      onComplete: onComplete,
      onError: onError,
    );
  }

  @override
  Future<void> subscribeAsync<EventTypeT extends Object>(
    FutureOr<void> Function(EventTypeT) event, {
    Object? qualifier,
    FutureOr<bool> Function()? registerIf,
    bool allowUnsubscribe = true,
    int priority = 0,
    bool unsubscribeAfterFire = false,
    bool lock = false,
    FutureOr<void> Function(Object?, StackTrace, EventTypeT)? onError,
    FutureOr<void> Function()? onComplete,
  }) {
    return _subscribe(
      event: event,
      qualifier: qualifier,
      registerIf: registerIf,
      allowUnsubscribe: allowUnsubscribe,
      priority: priority,
      unsubscribeAfterFire: unsubscribeAfterFire,
      mode: EventMode.asynchronous,
      lock: lock,
      onComplete: onComplete,
      onError: onError,
    );
  }

  @override
  Future<void> subscribeIsolate<EventTypeT extends Object>(
    FutureOr<void> Function(EventTypeT) event, {
    Object? qualifier,
    FutureOr<bool> Function()? registerIf,
    bool allowUnsubscribe = true,
    int priority = 0,
    bool unsubscribeAfterFire = false,
    bool lock = false,
    FutureOr<void> Function(Object?, StackTrace, EventTypeT)? onError,
    FutureOr<void> Function()? onComplete,
  }) {
    return _subscribe(
      event: event,
      qualifier: qualifier,
      registerIf: registerIf,
      allowUnsubscribe: allowUnsubscribe,
      priority: priority,
      unsubscribeAfterFire: unsubscribeAfterFire,
      mode: EventMode.runAsIsolate,
      lock: lock,
      onComplete: onComplete,
      onError: onError,
    );
  }

  Future<void> _subscribe<EventTypeT extends Object>({
    required FutureOr<void> Function(EventTypeT) event,
    required EventMode mode,
    Object? qualifier,
    FutureOr<bool> Function()? registerIf,
    bool allowUnsubscribe = true,
    int priority = 0,
    bool unsubscribeAfterFire = false,
    bool lock = false,
    FutureOr<void> Function(Object?, StackTrace, EventTypeT)? onError,
    FutureOr<void> Function()? onComplete,
  }) async {
    bool shouldRegister = true;

    if (registerIf != null) {
      if (registerIf is bool Function()) {
        shouldRegister = registerIf();
      } else {
        shouldRegister = await registerIf();
      }
    }

    if (shouldRegister) {
      final Object effectiveQualifierName = qualifier ?? EventTypeT;

      assert(allowUnsubscribe || (!allowUnsubscribe && !unsubscribeAfterFire),
          'Not possible to set allowUnsubscribe to false and unsubscribeAfterFire to true');

      _events.putIfAbsent(effectiveQualifierName, () => []);

      final existingEvents =
          _events[effectiveQualifierName]!.cast<Event<EventTypeT>>();
      final isDuplicate = existingEvents.any(
          (existingEvent) => existingEvent.event.hashCode == event.hashCode);

      if (!isDuplicate) {
        existingEvents.add(
          Event<EventTypeT>(
            event: event,
            type: EventTypeT,
            allowUnsubscribe: allowUnsubscribe,
            priority: priority,
            mode: mode,
            unsubscribeAfterFire: unsubscribeAfterFire,
            lock: lock ? EventLock() : null,
            onComplete: onComplete,
            onError: onError,
          ),
        );

        existingEvents.sort((a, b) => a.priority.compareTo(b.priority));
      }
    }

    return;
  }

  @override
  void unsubscribe<EventTypeT extends Object>(
    void Function(EventTypeT) event, {
    Object? qualifier,
  }) {
    final effectiveQualifierName = qualifier ?? EventTypeT;

    if (_events[effectiveQualifierName] case final eventsList?) {
      if (eventsList.isNotEmpty) {
        eventsList.cast<Event<EventTypeT>>().removeWhere(
            (e) => e.allowUnsubscribe && e.event.hashCode == event.hashCode);
      }

      if (eventsList.isEmpty) {
        _events.remove(effectiveQualifierName);
      }
    } else {
      throw EventNotFound(effectiveQualifierName.toString());
    }
  }

  @override
  void fire<EventTypeT extends Object>(EventTypeT value, {Object? qualifier}) {
    final effectiveQualifierName = qualifier ?? EventTypeT;

    if (_events[effectiveQualifierName] case final eventsList?
        when eventsList.isNotEmpty) {
      final eventsToRemove = <Event<EventTypeT>>[];

      for (final Event<EventTypeT> event
          in eventsList.cast<Event<EventTypeT>>()) {
        if (event.lock case final EventLock eventLock?) {
          eventLock.lock(
            () async => event.mode.execute<EventTypeT>(event, value),
          );
        } else {
          event.mode.execute<EventTypeT>(event, value);
        }

        if (event.unsubscribeAfterFire) {
          eventsToRemove.add(event);
        }
      }

      if (eventsToRemove.isNotEmpty) {
        for (final Event<EventTypeT> event in eventsToRemove) {
          _events[effectiveQualifierName]?.remove(event);
        }

        if (eventsList.isEmpty) {
          _events.remove(effectiveQualifierName);
        }
      }
    } else {
      throw EventNotFound(effectiveQualifierName.toString());
    }
  }

  @override
  bool isRegistered<EventTypeT extends Object>({Object? qualifier}) {
    return _events.containsKey(qualifier ?? EventTypeT);
  }
}
