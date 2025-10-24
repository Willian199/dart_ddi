import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/mixin/instance_factory_mixin.dart';

/// Abstract base class for all DDI factory implementations.
///
/// This class provides the common interface and functionality for creating
/// and managing bean instances with different scopes and lifecycle behaviors.
abstract class DDIBaseFactory<BeanT extends Object> with InstanceFactoryMixin {
  /// Creates a new [DDIBaseFactory] with an optional selector function.
  ///
  /// The selector function allows for conditional bean selection based on
  /// runtime criteria when multiple beans of the same type are registered.
  DDIBaseFactory({required FutureOr<bool> Function(Object)? selector})
      : _selector = selector;

  final FutureOr<bool> Function(Object)? _selector;

  /// Gets the selector function for conditional bean selection.
  ///
  /// Returns the selector function that determines which bean instance
  /// should be selected when multiple beans of the same type exist.
  FutureOr<bool> Function(Object)? get selector => _selector;

  /// The type of the Bean.
  Type _type = BeanT;

  /// Returns the current Bean type.
  ///
  /// This represents the actual type that this factory will create instances for.
  Type get type => _type;

  /// Sets the type for this factory to a new type.
  ///
  /// This is used internally to fix type inference issues with FutureOr and interfaces.
  void setType<NewType extends Object>() => _type = NewType;

  /// The current state of this factory in its lifecycle.
  BeanStateEnum state = BeanStateEnum.none;

  /// Registers this factory instance in the DDI container.
  ///
  /// This method is called during the registration process to set up the factory
  /// in the DDI container. The [apply] function is called when the instance is ready.
  ///
  /// - `qualifier`: The qualifier name used to identify this factory in the container.
  /// - `apply`: Function to call when the factory is ready to be registered.
  Future<void> register({
    required Object qualifier,
    required void Function(DDIBaseFactory<BeanT>) apply,
  });

  /// Gets or creates an instance of the registered bean.
  ///
  /// This method retrieves an existing instance or creates a new one if needed.
  /// The behavior depends on the specific factory implementation and scope.
  ///
  /// - `qualifier`: Qualifier name to identify the specific bean instance.
  /// - `parameter`: Optional parameter to pass during instance creation.
  ///
  /// **Note:** The `parameter` can be ignored if the instance is already created
  /// or the constructor doesn't match the parameter type.
  BeanT getWith<ParameterT extends Object>({
    required Object qualifier,
    ParameterT? parameter,
  });

  /// Gets or creates an instance of the registered bean asynchronously.
  ///
  /// This method retrieves an existing instance or creates a new one asynchronously.
  /// Useful for beans that require asynchronous initialization or creation.
  ///
  /// - `qualifier`: Qualifier name to identify the specific bean instance.
  /// - `parameter`: Optional parameter to pass during instance creation.
  ///
  /// **Note:** The `parameter` can be ignored if the instance is already created
  /// or the constructor doesn't match the parameter type.
  Future<BeanT> getAsyncWith<ParameterT extends Object>({
    required Object qualifier,
    ParameterT? parameter,
  });

  /// Verifies if this factory creates Future instances.
  ///
  /// Returns `true` if this factory creates asynchronous instances,
  /// `false` for synchronous instances.
  bool get isFuture;

  /// Verifies if this factory is ready to create instances.
  ///
  /// Returns `true` if the factory is properly initialized and ready
  /// to create instances, `false` otherwise.
  bool get isReady;

  /// Destroys this factory instance and cleans up resources.
  ///
  /// The [apply] function is called after successful destruction to
  /// perform any necessary cleanup operations.
  ///
  /// - `apply`: Function to call after successful destruction.
  FutureOr<void> destroy(void Function() apply);

  /// Disposes of this factory instance and its resources.
  ///
  /// This method performs cleanup operations and releases any resources
  /// held by this factory instance.
  Future<void> dispose();
}
