import 'package:dart_ddi/dart_ddi.dart';

/// Helper to make to easy to Inject one instance
///
/// Example:
/// ```dart
/// class MyController with DDIInject {
///
///   void businessLogic() {
///     controller.runSomething();
///   }
/// }
/// ```
mixin DDIInject<InjectType extends Object> {
  final InjectType controller = ddi.get<InjectType>();
}

/// Helper to make to easy to Inject one instance
mixin DDIInjectAsync<InjectType extends Object> {
  final Future<InjectType> controller = ddi.getAsync<InjectType>();
}
