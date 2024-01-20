part of 'dart_ddi_event.dart';

class _DDIEventImpl implements DDIEvent {
  final Map<Object, List<Events>> _events = {};

  @override
  void subscribe<T extends Object>(
    void Function(T) event, {
    Object? qualifier,
    bool Function()? registerIf,
    bool destroyable = true,
  }) {
    if (registerIf?.call() ?? true) {
      final Object effectiveQualifierName = qualifier ?? T;

      _events.putIfAbsent(effectiveQualifierName, () => []);

      _events[effectiveQualifierName]!.add(Events<T>(
        event: event,
        type: T,
        destroyable: destroyable,
      ));
    }
  }

  @override
  void destroy<T extends Object>({Object? qualifier, Events<T>? specificEvent}) {
    final Object effectiveQualifierName = qualifier ?? T;

    final List<Events<T>>? eventsList = _events[effectiveQualifierName] as List<Events<T>>?;

    if (eventsList != null) {
      if (specificEvent != null) {
        eventsList.remove(specificEvent);
      } else {
        _events.remove(effectiveQualifierName);
      }
    }
  }

  @override
  void fire<T extends Object>(T value, {Object? qualifier}) {
    final Object effectiveQualifierName = qualifier ?? T;

    final List<Events<T>>? eventsList = _events[effectiveQualifierName] as List<Events<T>>?;

    if (eventsList != null) {
      for (final Events<T> event in eventsList) {
        event.event(value);
      }
    }
  }
}
