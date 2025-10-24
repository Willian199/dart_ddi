import 'dart:async';

/// Mixin that provides lifecycle hooks for pre-destruction cleanup.
///
/// This mixin allows classes to define cleanup logic that will be executed
/// before the instance is destroyed and removed from the DDI container. This is
/// useful for releasing resources, closing connections, or performing any
/// cleanup that needs to happen before the instance is destroyed.
///
///
/// Example:
/// ```dart
/// class MyService with PreDestroy {
///   @override
///   FutureOr<void> onPreDestroy() {
///     print('Cleaning up before destruction');
///     // Close connections, save state, etc.
///   }
/// }
/// ```
mixin PreDestroy {
  /// Executes cleanup logic before the instance is destroyed.
  ///
  /// This method is called automatically by the DDI framework before the instance
  /// is destroyed and removed from the container. Override this method to implement
  /// your pre-destruction cleanup logic.
  FutureOr<void> onPreDestroy();
}
