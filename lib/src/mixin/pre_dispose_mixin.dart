import 'dart:async';

/// Mixin that provides lifecycle hooks for pre-disposal cleanup.
///
/// This mixin allows classes to define cleanup logic that will be executed
/// before the instance is disposed from the DDI container. This is
/// useful for releasing resources or performing any cleanup that needs
/// to happen before the instance is disposed.
///
///
/// Example:
/// ```dart
/// class MyService with PreDispose {
///   @override
///   FutureOr<void> onPreDispose() {
///     print('Cleaning up before disposal');
///     // Close connections, save state, etc.
///   }
/// }
/// ```
mixin PreDispose {
  /// Executes cleanup logic before the instance is disposed.
  ///
  /// This method is called automatically by the DDI framework before the instance
  /// is disposed from the container. Override this method to implement
  /// your pre-disposal cleanup logic.
  FutureOr<void> onPreDispose();
}
