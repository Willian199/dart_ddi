import 'package:dart_ddi/dart_ddi.dart';

/// Mixin that provides easy dependency injection for synchronous instances.
///
/// This mixin automatically injects a dependency of type [InjectType] when the class
/// is instantiated. The injected instance is available through the `instance` property.
///
///
/// Example:
/// ```dart
/// class MyController with DDIInject<MyService> {
///   void businessLogic() {
///     instance.runSomething();
///   }
/// }
/// ```
mixin DDIInject<InjectType extends Object> {
  /// The injected instance of [InjectType].
  late final InjectType instance = ddi.get<InjectType>();
}

/// Mixin that provides easy dependency injection for asynchronous instances.
///
/// This mixin automatically injects an asynchronous dependency of type [InjectType]
/// when the class is instantiated. The injected instance is available through the `instance` property.
///
/// Example:
/// ```dart
/// class MyController with DDIInjectAsync<MyService> {
///   Future<void> businessLogic() async {
///     final service = await instance;
///     service.runSomething();
///   }
/// }
/// ```
mixin DDIInjectAsync<InjectType extends Object> {
  /// The injected async instance of [InjectType].
  late final Future<InjectType> instance = ddi.getAsync<InjectType>();
}
