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
    Duration? expirationDuration,
    bool autoRun = false,
    Duration? retryInterval,
    EventTypeT? defaultValue,
    int maxRetry = 0,
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
      expirationDuration: expirationDuration,
      retryInterval: retryInterval,
      defaultValue: defaultValue,
      maxRetry: maxRetry,
      autoRun: autoRun,
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
    Duration? expirationDuration,
    bool autoRun = false,
    Duration? retryInterval,
    EventTypeT? defaultValue,
    int maxRetry = 0,
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
      expirationDuration: expirationDuration,
      retryInterval: retryInterval,
      defaultValue: defaultValue,
      maxRetry: maxRetry,
      autoRun: autoRun,
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
    Duration? expirationDuration,
    bool autoRun = false,
    Duration? retryInterval,
    EventTypeT? defaultValue,
    int maxRetry = 0,
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
      expirationDuration: expirationDuration,
      retryInterval: retryInterval,
      defaultValue: defaultValue,
      maxRetry: maxRetry,
      autoRun: autoRun,
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
    Duration? expirationDuration,
    bool autoRun = false,
    Duration? retryInterval,
    EventTypeT? defaultValue,
    int maxRetry = 0,
  }) async {
    assert((!autoRun && defaultValue == null) || (autoRun && defaultValue != null), 'You should provide a default value when using autoRun');

    assert(maxRetry >= 0, 'maxRetry should be greater or equal to 0');

    assert(retryInterval == null || retryInterval > Duration.zero, 'retryInterval should be greater than Duration.zero');

    assert((lock && !autoRun) || (!lock), 'Not able to use lock and autoRun at the same time');

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

      final existingEvents = _events[effectiveQualifierName]!.cast<Event<EventTypeT>>();

      if (existingEvents.isNotEmpty && retryInterval != null) {
        throw EventNotAllowedException('Not allowed to register multiple events with the same $effectiveQualifierName where using retryInterval');
      }

      final isDuplicate = existingEvents.any((existingEvent) => existingEvent.event.hashCode == event.hashCode);

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
            retryInterval: autoRun ? null : retryInterval,
            maxRetry: autoRun ? 0 : maxRetry,
          ),
        );

        existingEvents.sort((a, b) => a.priority.compareTo(b.priority));

        if (expirationDuration != null) {
          Future.delayed(expirationDuration, () {
            _removeEvents(event, effectiveQualifierName);
          });
        }

        if (autoRun && defaultValue != null) {
          if (retryInterval != null && retryInterval > Duration.zero) {
            Timer.periodic(retryInterval, (timer) async {
              if (!isRegistered<EventTypeT>(qualifier: effectiveQualifierName)) {
                timer.cancel();
                return;
              }

              await fireWait<EventTypeT>(defaultValue, qualifier: effectiveQualifierName);

              if (maxRetry <= 1) {
                timer.cancel();
                _removeEvents<EventTypeT>(event, effectiveQualifierName);
              } else {
                maxRetry--;
              }
            });
          } else {
            await fireWait<EventTypeT>(defaultValue, qualifier: effectiveQualifierName);
          }
        }
      }
    }

    return;
  }

  void _removeEvents<EventTypeT extends Object>(void Function(EventTypeT) event, Object effectiveQualifierName) {
    if (_events[effectiveQualifierName] case final eventsList?) {
      if (eventsList.isNotEmpty) {
        eventsList.cast<Event<EventTypeT>>().removeWhere((e) => e.allowUnsubscribe && e.event.hashCode == event.hashCode);
      }

      if (eventsList.isEmpty) {
        _events.remove(effectiveQualifierName);
      }
    }
  }

  @override
  void unsubscribe<EventTypeT extends Object>(
    void Function(EventTypeT) event, {
    Object? qualifier,
  }) {
    final effectiveQualifierName = qualifier ?? EventTypeT;

    if (_events[effectiveQualifierName] case final eventsList?) {
      if (eventsList.isNotEmpty) {
        eventsList.cast<Event<EventTypeT>>().removeWhere((e) => e.allowUnsubscribe && e.event.hashCode == event.hashCode);
      }

      if (eventsList.isEmpty) {
        _events.remove(effectiveQualifierName);
      }
    } else {
      throw EventNotFoundException(effectiveQualifierName.toString());
    }
  }

  @override
  void fire<EventTypeT extends Object>(EventTypeT value, {Object? qualifier}) {
    final effectiveQualifierName = qualifier ?? EventTypeT;

    if (_events[effectiveQualifierName] case final eventsList? when eventsList.isNotEmpty) {
      final eventsToRemove = <Event<EventTypeT>>[];

      for (final Event<EventTypeT> event in eventsList.cast<Event<EventTypeT>>()) {
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
      throw EventNotFoundException(effectiveQualifierName.toString());
    }
  }

  @override
  Future<void> fireWait<EventTypeT extends Object>(EventTypeT value, {Object? qualifier}) async {
    final effectiveQualifierName = qualifier ?? EventTypeT;

    if (_events[effectiveQualifierName] case final eventsList? when eventsList.isNotEmpty) {
      final eventsToRemove = <Event<EventTypeT>>[];

      for (final Event<EventTypeT> event in eventsList.cast<Event<EventTypeT>>()) {
        if (event.lock case final EventLock eventLock?) {
          await eventLock.lock(
            () async => await event.mode.execute<EventTypeT>(event, value),
          );
        } else {
          await event.mode.execute<EventTypeT>(event, value);
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
      throw EventNotFoundException(effectiveQualifierName.toString());
    }
  }

  @override
  bool isRegistered<EventTypeT extends Object>({Object? qualifier}) {
    return _events.containsKey(qualifier ?? EventTypeT);
  }
}
