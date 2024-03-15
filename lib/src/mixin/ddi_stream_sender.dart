import 'package:dart_ddi/dart_ddi.dart';

/// Mixin used to send stream events.
/// [StreamStateType] The type of the stream.
/// 
/// Example:
/// ```dart
/// class MyEvent with DDIStreamSender<String> {
///
///   void businessLogic() {
///     fire('Hello World');
///   }
/// }
/// ```
mixin DDIStreamSender<StreamStateType extends Object> {
  /// Sends a value to the stream.
  /// @param state The value to be send.
  void fire(StreamStateType state) {
    ddiStream.fire<StreamStateType>(value: state);
  }
}
