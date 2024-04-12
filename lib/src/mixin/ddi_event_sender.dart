import 'package:dart_ddi/dart_ddi.dart';

/// Mixin used to send events.
/// [EventStateType] The type of the event.
///
/// Example:
/// ```dart
/// class MyEvent with DDIEventSender<String> {
///
///   void businessLogic() {
///     fire('Hello World');
///   }
/// }
/// ```
mixin DDIEventSender<EventStateType extends Object> {
  EventStateType? _state;

  /// @return The current state of the event.
  EventStateType? get state => _state;

  /// Sends an event to all listeners.
  /// @param state The value to be send.
  void fire(EventStateType stateValue) {
    _state = stateValue;
    ddiEvent.fire<EventStateType>(stateValue);
  }
}
