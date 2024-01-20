part of 'dart_ddi_event.dart';

class _DDIEventImpl implements DDIEvent {
  final Map<Object, Set<Event>> _events = {};

  @override
  void subscribe<T extends Object>(
    void Function(T) event, {
    Object? qualifier,
    bool Function()? registerIf,
    bool destroyable = true,
  }) {
    if (registerIf?.call() ?? true) {
      final Object effectiveQualifierName = qualifier ?? T;

      _events.putIfAbsent(effectiveQualifierName, () => {});

      _events[effectiveQualifierName]!.add(Event<T>(
        event: event,
        type: T,
        destroyable: destroyable,
      ));
    }
  }

  @override
  void unsubscribe<T extends Object>(void Function(T) event, {Object? qualifier}) {
    final effectiveQualifierName = qualifier ?? T;

    final eventsSet = _events[effectiveQualifierName];

    if (eventsSet != null) {
      eventsSet.removeWhere(
        (e) => e.destroyable && identical(e.event, event),
      );
    }
  }

  @override
  void fire<T extends Object>(T value, {Object? qualifier}) {
    final effectiveQualifierName = qualifier ?? T;

    final eventsSet = _events[effectiveQualifierName] as Set<Event<T>>?;

    if (eventsSet != null) {
      for (final Event<T> event in eventsSet) {
        event.event(value);
      }
    }
  }
}
