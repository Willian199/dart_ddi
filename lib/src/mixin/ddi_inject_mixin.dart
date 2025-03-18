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

/// Helper to make easy to Inject one instance
mixin DDIInjectAsync<InjectType extends Object> {
  late final Future<InjectType> instance = ddi.getAsync<InjectType>();
}
