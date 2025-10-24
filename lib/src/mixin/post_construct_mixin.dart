import 'dart:async';

/// Mixin that provides lifecycle hooks for post-construction initialization.
///
/// This mixin allows classes to define initialization logic that will be executed
/// after the instance is constructed and registered in the DDI container. This is
/// useful for setting up resources, establishing connections, or performing any
/// initialization that requires the instance to be fully constructed.
///
///
/// Example:
/// ```dart
/// class MyService with PostConstruct {
///   @override
///   FutureOr<void> onPostConstruct() {
///     print('Initializing service after construction');
///     // Setup connections, listeners, etc.
///   }
/// }
/// ```
mixin PostConstruct {
  /// Executes initialization logic after the instance is constructed.
  ///
  /// This method is called automatically by the DDI framework after the instance
  /// has been created and registered. Override this method to implement your
  /// post-construction initialization logic.
  FutureOr<void> onPostConstruct();
}
