import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/mixin/instance_factory_mixin.dart';

abstract class DDIBaseFactory<BeanT extends Object> with InstanceFactoryMixin {
  DDIBaseFactory({required FutureOr<bool> Function(Object)? selector})
      : _selector = selector;

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
}
