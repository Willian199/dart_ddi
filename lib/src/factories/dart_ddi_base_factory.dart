import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/mixin/instance_factory_mixin.dart';
import 'package:dart_ddi/src/typedef/typedef.dart';

abstract class DDIBaseFactory<BeanT extends Object> with InstanceFactoryMixin {
  DDIBaseFactory({required FutureOr<bool> Function(Object)? selector}) : _selector = selector;

  final FutureOr<bool> Function(Object)? _selector;
  FutureOr<bool> Function(Object)? get selector => _selector;

  /// The type of the Bean.
  Type _type = BeanT;

  /// Returns the current Bean type.
  Type get type => _type;

  void setType<NewType extends Object>() => _type = NewType;

  BeanStateEnum state = BeanStateEnum.none;

  /// Register the instance in [DDI].
  /// When the instance is ready, must call apply function.
  Future<void> register({
    required Object qualifier,
    required void Function(DDIBaseFactory<BeanT>) apply,
  });

  /// Gets or creates this instance.
  ///
  /// - `qualifier`: Qualifier name to identify the object.
  /// - `parameter`: Optional parameter to pass during the instance creation.
  ///
  /// **Note:** The `parameter` will be ignored: If the instance is already created or the constructor doesn't match with the parameter type.
  BeanT getWith<ParameterT extends Object>({
    required Object qualifier,
    ParameterT? parameter,
  });

  /// Gets or create this instance as Future.
  ///
  /// - `qualifier`: Qualifier name to identify the object.
  /// - `parameter`: Optional parameter to pass during the instance creation.
  ///
  /// **Note:** The `parameter` will be ignored: If the instance is already created or the constructor doesn't match with the parameter type.
  Future<BeanT> getAsyncWith<ParameterT extends Object>({
    required Object qualifier,
    ParameterT? parameter,
  });

  /// Verify if this factory is a Future.
  bool get isFuture;

  /// Verify if this factory is ready.
  bool get isReady;

  /// Destroy this instance
  FutureOr<void> destroy(void Function() apply);

  /// Disposes this instance
  Future<void> dispose();

  /// Allows to dynamically add a Decorators.
  ///
  /// When using this method, consider the following:
  ///
  /// - **Order of Execution:** Decorators are applied in the order they are provided.
  /// - **Instaces Already Gets:** No changes any Instances that have been get.
  FutureOr<void> addDecorator(ListDecorator<BeanT> newDecorators);

  /// Allows to dynamically add a Interceptor.
  ///
  /// When using this method, consider the following:
  ///
  /// - **Order of Execution:** Interceptor are applied in the order they are provided.
  /// - **Instaces Already Gets:** No changes any Instances that have been get.
  void addInterceptor(Set<Object> newInterceptors); /* {
    interceptors = {...interceptors ?? {}, ...newInterceptors};
  }*/

  /// This function adds multiple child modules to a parent module.
  /// It takes a list of 'child' objects and an optional 'qualifier' for the parent module.
  void addChildrenModules(Set<Object> child); /* {
    children = {...children ?? {}, ...child};
  }
*/
  /// This function returns a set of child modules for a parent module.
  Set<Object> get children; // => super.children ?? {};
}
