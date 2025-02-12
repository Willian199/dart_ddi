import 'package:dart_ddi/dart_ddi.dart';

/// Helper to make easy to Inject one instance
///
/// Example:
/// ```dart
/// class MyController with DDIInject<MyService> {
///
///   void businessLogic() {
///     instance.runSomething();
///   }
/// }
/// ```
mixin DDIInject<InjectType extends Object> {
  late final InjectType instance = ddi.get<InjectType>();
}

/// Helper to make easy to Inject a Component instance
///
/// Example:
/// ```dart
/// class MyController with DDIComponentInject<MyComponent, MyModule> {
///
///   void businessLogic() {
///     instance.runSomething();
///   }
/// }
/// ```
mixin DDIComponentInject<ComponentT extends Object, ModuleT extends DDIModule> {
  late final ComponentT instance = ddi.getComponent<ComponentT>(module: ModuleT);
}

/// Helper to make easy to Inject one instance
mixin DDIInjectAsync<InjectType extends Object> {
  late final Future<InjectType> instance = ddi.getAsync<InjectType>();
}
