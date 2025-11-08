import 'dart:async';

/// Represents a programmatic way to access beans, similar to CDI's `Instance&lt;T&gt;`.
///
/// This class provides a wrapper around a DDI factory that allows you to:
/// - Check if a bean is resolvable
/// - Get bean instances (sync and async)
/// - Destroy bean instances
/// - Access beans with optional qualifiers
///
/// Example:
/// ```dart
/// final instance = ddi.getInstance<MyService>();
/// if (instance.isResolvable()) {
///   final service = instance.get();
///   service.doSomething();
/// }
/// ```
abstract class Instance<BeanT extends Object> {
  /// Checks if this instance is resolvable (i.e., the bean is registered).
  ///
  /// Returns `true` if the bean is registered and can be retrieved,
  /// `false` otherwise.
  bool isResolvable();

  /// Gets the bean instance synchronously.
  ///
  /// - `parameter`: Optional parameter to pass during instance creation.
  ///
  /// Returns the bean instance, or throws [BeanNotFoundException] if not registered.
  BeanT get<ParameterT extends Object>({ParameterT? parameter});

  /// Gets the bean instance asynchronously.
  ///
  /// - `parameter`: Optional parameter to pass during instance creation.
  ///
  /// Returns a [Future] that completes with the bean instance,
  /// or throws [BeanNotFoundException] if not registered.
  Future<BeanT> getAsync<ParameterT extends Object>({ParameterT? parameter});

  /// Destroys the bean instance if it exists and can be destroyed.
  ///
  /// This method calls the factory's destroy method, which will:
  /// - Call interceptors' onDestroy
  /// - Call PreDestroy mixin if applicable
  /// - Destroy child modules if applicable
  /// - Remove the instance from the container
  FutureOr<void> destroy();

  /// Disposes of the bean instance if it exists.
  ///
  /// This method calls the factory's dispose method, which will:
  /// - Call interceptors' onDispose
  /// - Call PreDispose mixin if applicable
  /// - Dispose child modules if applicable
  Future<void> dispose();
}
