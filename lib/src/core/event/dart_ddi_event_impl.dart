part of 'dart_ddi_event.dart';

class _DDIEventImpl implements DDIEvent {
  final Map<Object, List<Event<Object>>> _events = {};
  final Map<Object, History> _valueHistory = {};

  @override
  Future<void> subscribe<EventTypeT extends Object>(
    FutureOr<void> Function(EventTypeT) event, {
    Object? qualifier,
    FutureOrBoolCallback? canRegister,
    bool canUnsubscribe = true,
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
    FutureOr<bool> Function(EventTypeT)? filter,
  }) {
    return _subscribe(
      event: event,
      qualifier: qualifier,
      canRegister: canRegister,
      canUnsubscribe: canUnsubscribe,
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
      filter: filter,
    );
  }

  @override
  Future<void> subscribeAsync<EventTypeT extends Object>(
    FutureOr<void> Function(EventTypeT) event, {
    Object? qualifier,
    FutureOrBoolCallback? canRegister,
    bool canUnsubscribe = true,
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
    FutureOr<bool> Function(EventTypeT)? filter,
  }) {
    return _subscribe(
      event: event,
      qualifier: qualifier,
      canRegister: canRegister,
      canUnsubscribe: canUnsubscribe,
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
      filter: filter,
    );
  }

  @override
  Future<void> subscribeIsolate<EventTypeT extends Object>(
    FutureOr<void> Function(EventTypeT) event, {
    Object? qualifier,
    FutureOrBoolCallback? canRegister,
    bool canUnsubscribe = true,
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
    FutureOr<bool> Function(EventTypeT)? filter,
  }) {
    return _subscribe(
      event: event,
      qualifier: qualifier,
      canRegister: canRegister,
      canUnsubscribe: canUnsubscribe,
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
      filter: filter,
    );
  }

  Future<void> _subscribe<EventTypeT extends Object>({
    required FutureOr<void> Function(EventTypeT) event,
    required EventMode mode,
    Object? qualifier,
    FutureOrBoolCallback? canRegister,
    bool canUnsubscribe = true,
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
    FutureOr<bool> Function(EventTypeT)? filter,
  }) async {
    assert(
        (!autoRun && defaultValue == null) || (autoRun && defaultValue != null),
        'You should provide a default value when using autoRun.');

    assert(maxRetry >= 0, 'maxRetry should be greater or equal to 0');

    assert(priority >= 0, 'Priority cannot be negative.');

    assert(retryInterval == null || retryInterval > Duration.zero,
        'retryInterval should be greater than Duration.zero.');

    assert((lock && !autoRun) || (!lock),
        'Not able to use lock and autoRun at the same time.');

    bool shouldRegister = true;

    if (canRegister != null) {
      if (canRegister is bool Function()) {
        shouldRegister = canRegister();
      } else {
        shouldRegister = await canRegister();
      }
    }

    if (shouldRegister) {
      final Object effectiveQualifierName = qualifier ?? EventTypeT;

      assert(canUnsubscribe || (!canUnsubscribe && !unsubscribeAfterFire),
          'Not possible to set canUnsubscribe to false and unsubscribeAfterFire to true.');

      _events.putIfAbsent(effectiveQualifierName, () => []);

      final existingEvents =
          _events[effectiveQualifierName]!.cast<Event<EventTypeT>>();

      if (existingEvents.isNotEmpty && autoRun) {
        throw EventNotAllowedException(
            'Not allowed to register multiple events with the same qualifier ($effectiveQualifierName) where using autoRun.');
      }

      final isDuplicate =
          existingEvents.any((existingEvent) => existingEvent.event == event);

      if (!isDuplicate) {
        existingEvents.add(
          Event<EventTypeT>(
            event: event,
            type: EventTypeT,
            canUnsubscribe: canUnsubscribe,
            priority: priority,
            mode: mode,
            unsubscribeAfterFire: unsubscribeAfterFire,
            lock: lock ? EventLock() : null,
            onComplete: onComplete,
            onError: onError,
            retryInterval: autoRun ? null : retryInterval,
            maxRetry: autoRun ? 0 : maxRetry,
            filter: filter,
          ),
        );

        existingEvents.sort((a, b) => a.priority.compareTo(b.priority));

        if (expirationDuration != null) {
          Future.delayed(expirationDuration, () {
            _removeEvents<EventTypeT>(event, effectiveQualifierName);
          });
        }

        if (autoRun && defaultValue != null) {
          if (retryInterval != null && retryInterval > Duration.zero) {
            final bool isFinite = maxRetry > 0;

            Timer.periodic(retryInterval, (timer) async {
              if (!isRegistered<EventTypeT>(
                  qualifier: effectiveQualifierName)) {
                timer.cancel();
                return;
              }

              await fireWait<EventTypeT>(defaultValue,
                  qualifier: effectiveQualifierName, canReplay: false);

              if (isFinite) {
                if (maxRetry <= 1) {
                  timer.cancel();
                  _removeEvents<EventTypeT>(event, effectiveQualifierName);
                } else {
                  maxRetry--;
                }
              }
            });
          } else {
            await fireWait<EventTypeT>(defaultValue,
                qualifier: effectiveQualifierName);
          }
        }
      }
    }

    return;
  }

  void _removeEvents<EventTypeT extends Object>(
      void Function(EventTypeT) event, Object effectiveQualifierName) {
    if (_events[effectiveQualifierName] case final eventsList?) {
      if (eventsList.isNotEmpty) {
        eventsList
            .cast<Event<EventTypeT>>()
            .removeWhere((e) => e.canUnsubscribe && e.event == event);
      }

      if (eventsList.isEmpty) {
        _events.remove(effectiveQualifierName);
        _valueHistory.remove(effectiveQualifierName);
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
        eventsList
            .cast<Event<EventTypeT>>()
            .removeWhere((e) => e.canUnsubscribe && e.event == event);
      }

      if (eventsList.isEmpty) {
        _events.remove(effectiveQualifierName);
        _valueHistory.remove(effectiveQualifierName);
      }
    } else {
      throw EventNotFoundException(effectiveQualifierName.toString());
    }
  }

  @override
  void fire<EventTypeT extends Object>(
    EventTypeT value, {
    Object? qualifier,
    bool canReplay = true,
  }) {
    final effectiveQualifierName = qualifier ?? EventTypeT;

    final eventsList = _events[effectiveQualifierName];

    if ((eventsList?.isEmpty ?? true) && !canReplay) {
      throw EventNotFoundException(effectiveQualifierName.toString());
    }

    _validateHistory<EventTypeT>(value, effectiveQualifierName, canReplay);

    if (eventsList != null && eventsList.isNotEmpty) {
      final eventsToRemove = <Event<EventTypeT>>[];

      for (final Event<EventTypeT> event
          in eventsList.cast<Event<EventTypeT>>()) {
        _validateFilter(event, value);

        if (event.unsubscribeAfterFire) {
          eventsToRemove.add(event);
        }
      }

      if (eventsToRemove.isNotEmpty) {
        for (final Event<EventTypeT> event in eventsToRemove) {
          _events[effectiveQualifierName]?.remove(event);
        }

        if (_events[effectiveQualifierName]?.isEmpty ?? true) {
          _events.remove(effectiveQualifierName);
          _valueHistory.remove(effectiveQualifierName);
        }
      }
    }
  }

  void _validateHistory<EventTypeT extends Object>(
      EventTypeT value, Object effectiveQualifierName, bool canReplay) {
    if (canReplay) {
      _valueHistory.putIfAbsent(
          effectiveQualifierName, () => History<EventTypeT>());
      final history = _valueHistory[effectiveQualifierName]!;

      // Add the value to the undo stack
      history.undoStack.add(value);
      if (history.undoStack.length > 5) {
        history.undoStack.removeFirst(); // Limits the size of the undo stack
      }

      // Clear the redo stack
      history.redoStack.clear();
    }
  }

  FutureOr<void> _execFire<EventTypeT extends Object>(
      Event<EventTypeT> event, EventTypeT value) {
    if (event.lock case final EventLock eventLock?) {
      return eventLock.lock(
        () async => event.mode.execute<EventTypeT>(event, value),
      );
    }

    return event.mode.execute<EventTypeT>(event, value);
  }

  FutureOr<void> _validateFilter<EventTypeT extends Object>(
      Event<EventTypeT> event, EventTypeT value) async {
    return switch (event.filter) {
      final bool Function(EventTypeT) filter => {
          if (filter(value)) _execFire(event, value),
        },
      final Future<bool> Function(EventTypeT) filter
          when event.mode == EventMode.normal =>
        filter(value).then((result) {
          if (result) {
            _execFire(event, value);
          }
        }),
      final Future<bool> Function(EventTypeT) filter
          when event.mode != EventMode.normal =>
        {
          if (await filter(value)) await _execFire(event, value),
        },
      _ => _execFire(event, value),
    };
  }

  @override
  Future<void> fireWait<EventTypeT extends Object>(
    EventTypeT value, {
    Object? qualifier,
    bool canReplay = true,
  }) async {
    final effectiveQualifierName = qualifier ?? EventTypeT;

    final eventsList = List.from(_events[effectiveQualifierName] ?? []);

    if (eventsList.isEmpty && !canReplay) {
      throw EventNotFoundException(effectiveQualifierName.toString());
    }

    _validateHistory<EventTypeT>(value, effectiveQualifierName, canReplay);

    if (eventsList.isNotEmpty) {
      final eventsToRemove = <Event<EventTypeT>>[];

      for (final event in eventsList.cast<Event<EventTypeT>>()) {
        await _validateFilter<EventTypeT>(event, value);

        if (event.unsubscribeAfterFire) {
          eventsToRemove.add(event);
        }
      }

      if (eventsToRemove.isNotEmpty) {
        for (final Event<EventTypeT> event in eventsToRemove) {
          _events[effectiveQualifierName]?.remove(event);
        }

        if (_events[effectiveQualifierName]?.isEmpty ?? true) {
          _events.remove(effectiveQualifierName);
          _valueHistory.remove(effectiveQualifierName);
        }
      }
    }
  }

  @override
  bool isRegistered<EventTypeT extends Object>({Object? qualifier}) {
    return _events.containsKey(qualifier ?? EventTypeT);
  }

  @override
  Future<void> undo<EventTypeT extends Object>({Object? qualifier}) async {
    final effectiveQualifierName = qualifier ?? EventTypeT;

    if (_valueHistory[effectiveQualifierName] case final history?
        when history.undoStack.isNotEmpty) {
      // Move the last value to the redo stack
      final lastValue = history.undoStack.removeLast();

      history.redoStack.add(lastValue);

      if (!isRegistered<EventTypeT>(qualifier: effectiveQualifierName)) {
        return;
      }

      // Get the previous value
      final previousValue = history.undoStack.last as EventTypeT;

      return fireWait<EventTypeT>(
        previousValue,
        qualifier: effectiveQualifierName,
        canReplay: false,
      );
    }
  }

  @override
  Future<void> redo<EventTypeT extends Object>({Object? qualifier}) async {
    final effectiveQualifierName = qualifier ?? EventTypeT;

    if (_valueHistory[effectiveQualifierName] case final history?
        when history.redoStack.isNotEmpty) {
      // Remove the last value from the redo stack
      final redoValue = history.redoStack.removeLast();

      // Push the value to the undo stack
      history.undoStack.add(redoValue);

      if (!isRegistered<EventTypeT>(qualifier: effectiveQualifierName)) {
        return;
      }

      return fireWait<EventTypeT>(
        redoValue as EventTypeT,
        qualifier: effectiveQualifierName,
        canReplay: false,
      );
    }
  }

  @override
  EventTypeT? getValue<EventTypeT extends Object>({Object? qualifier}) {
    final history = _valueHistory[qualifier ?? EventTypeT]?.undoStack;
    if (history?.isNotEmpty ?? false) {
      return history!.last as EventTypeT?;
    }
    return null;
  }

  @override
  void clearHistory<EventTypeT extends Object>({Object? qualifier}) {
    final effectiveQualifierName = qualifier ?? EventTypeT;

    if (_valueHistory.containsKey(effectiveQualifierName)) {
      _valueHistory.remove(effectiveQualifierName);
    }
  }
}
