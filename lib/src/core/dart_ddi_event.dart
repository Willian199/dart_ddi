import 'package:dart_ddi/src/data/event.dart';

part 'dart_ddi_event_impl.dart';

abstract class DDIEvent {
  /// Creates the shared instance of the [DDIEvent] class.
  static final DDIEvent _instance = _DDIEventImpl();

  /// Gets the shared instance of the [DDIEvent] class.
  static DDIEvent get instance => _instance;

  void subscribe<T extends Object>(
    void Function(T) event, {
    Object? qualifier,
    bool Function()? registerIf,
    bool destroyable = true,
  });

  /// Removes the event registered class in [DDIEvent].
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different events of the same type.
  void destroy<T extends Object>({Object? qualifier});

  void fire<T extends Object>(T value, {Object? qualifier});
}
