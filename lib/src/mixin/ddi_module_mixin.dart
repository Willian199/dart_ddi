import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/typedef/typedef.dart';

/// Mixin to make it easy to create modules
///
/// Example:
/// ```dart
/// class MyModule with DDIModule {
///   @override
///   FutureOr<void> onPostConstruct(){
///     print('do something after construct or register the children beans');
///
///     application<MyService>(MyService.new);
///     singleton<MyRepository>(MyRepository.new);
///     dependent<MyCase>(MyCase.new);
///   }
/// }
/// ```

mixin DDIModule implements PostConstruct {
  Object? _internalQualifier;

  Object get moduleQualifier => _internalQualifier ?? runtimeType;

  set moduleQualifier(Object value) {
    _internalQualifier = value;
  }

  Set<Object> get children => ddi.getChildren(qualifier: moduleQualifier);

  /// Registers an instance as a Singleton.
  ///
  /// - `clazzRegister`: Factory function to create the instance.
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `decorators`: List of decoration functions to apply to the instance.
  /// - `interceptor`: Optional interceptor to customize the creation, get, dispose or remove behavior.
  /// - `canRegister`: Optional function to conditionally register the instance.
  /// - `canDestroy`: Optional parameter to make the instance indestructible.
  /// - `children`: Optional parameter, designed to receive types or qualifiers. This parameter allows you to link multiple classes under a single parent module.
  /// - `selector`: Optional function that allows conditional selection of instances based on specific criteria. Useful for dynamically choosing an instance at runtime based on application context.
  ///
  Future<void> singleton<BeanT extends Object>(
    BeanRegister<BeanT> clazzRegister, {
    Object? qualifier,
    ListDecorator<BeanT> decorators = const [],
    Set<Object> interceptors = const {},
    Set<Object> children = const {},
    FutureOrBoolCallback? canRegister,
    bool canDestroy = true,
    FutureOr<bool> Function(Object)? selector,
  }) {
    final bean = ddi.singleton<BeanT>(
      clazzRegister,
      qualifier: qualifier,
      decorators: decorators,
      interceptors: interceptors,
      canDestroy: canDestroy,
      canRegister: canRegister,
      children: children,
      selector: selector,
    );

    ddi.addChildModules(child: qualifier ?? BeanT, qualifier: moduleQualifier);

    return bean;
  }

  /// Registers an instance as an Application.
  ///
  /// - `clazzRegister`: Factory function to create the instance.
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `decorators`: List of decoration functions to apply to the instance.
  /// - `interceptor`: Optional interceptor to customize the creation, get, dispose or remove behavior.
  /// - `canRegister`: Optional function to conditionally register the instance.
  /// - `canDestroy`: Optional parameter to make the instance indestructible.
  /// - `children`: Optional parameter, designed to receive types or qualifiers. This parameter allows you to link multiple classes under a single parent module.
  /// - `selector`: Optional function that allows conditional selection of instances based on specific criteria. Useful for dynamically choosing an instance at runtime based on application context.
  ///
  Future<void> application<BeanT extends Object>(
    BeanRegister<BeanT> clazzRegister, {
    Object? qualifier,
    ListDecorator<BeanT> decorators = const [],
    Set<Object> interceptors = const {},
    Set<Object> children = const {},
    FutureOrBoolCallback? canRegister,
    bool canDestroy = true,
    FutureOr<bool> Function(Object)? selector,
  }) {
    final bean = ddi.application<BeanT>(
      clazzRegister,
      qualifier: qualifier,
      decorators: decorators,
      interceptors: interceptors,
      canDestroy: canDestroy,
      canRegister: canRegister,
      children: children,
      selector: selector,
    );

    ddi.addChildModules(child: qualifier ?? BeanT, qualifier: moduleQualifier);

    return bean;
  }

  /// Registers an instance as a Dependent.
  ///
  /// - `clazzRegister`: Factory function to create the instance.
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `decorators`: List of decoration functions to apply to the instance.
  /// - `interceptor`: Optional interceptor to customize the creation, get, dispose or remove behavior.
  /// - `canRegister`: Optional function to conditionally register the instance.
  /// - `canDestroy`: Optional parameter to make the instance indestructible.
  /// - `children`: Optional parameter, designed to receive types or qualifiers. This parameter allows you to link multiple classes under a single parent module.
  /// - `selector`: Optional function that allows conditional selection of instances based on specific criteria. Useful for dynamically choosing an instance at runtime based on application context.
  ///
  Future<void> dependent<BeanT extends Object>(
    BeanRegister<BeanT> clazzRegister, {
    Object? qualifier,
    FutureOrBoolCallback? canRegister,
    bool canDestroy = true,
    ListDecorator<BeanT> decorators = const [],
    Set<Object> interceptors = const {},
    Set<Object> children = const {},
    FutureOr<bool> Function(Object)? selector,
  }) {
    final bean = ddi.dependent<BeanT>(
      clazzRegister,
      qualifier: qualifier,
      decorators: decorators,
      interceptors: interceptors,
      canDestroy: canDestroy,
      canRegister: canRegister,
      children: children,
      selector: selector,
    );

    ddi.addChildModules(child: qualifier ?? BeanT, qualifier: moduleQualifier);

    return bean;
  }

  /// Registers an instance as an Object Scope.
  ///
  /// - `instance`: The instance to register.
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `decorators`: List of decoration functions to apply to the instance.
  /// - `interceptor`: Optional interceptor to customize the creation, get, dispose or remove behavior.
  /// - `canRegister`: Optional function to conditionally register the instance.
  /// - `canDestroy`: Optional parameter to make the instance indestructible.
  /// - `children`: Optional parameter, designed to receive types or qualifiers. This parameter allows you to link multiple classes under a single parent module.
  /// - `selector`: Optional function that allows conditional selection of instances based on specific criteria. Useful for dynamically choosing an instance at runtime based on application context.
  ///
  Future<void> object<BeanT extends Object>(
    BeanT instance, {
    Object? qualifier,
    ListDecorator<BeanT> decorators = const [],
    Set<Object> interceptors = const {},
    Set<Object> children = const {},
    FutureOrBoolCallback? canRegister,
    bool canDestroy = true,
    FutureOr<bool> Function(Object)? selector,
  }) {
    final bean = ddi.object<BeanT>(
      instance,
      qualifier: qualifier,
      decorators: decorators,
      interceptors: interceptors,
      canDestroy: canDestroy,
      canRegister: canRegister,
      children: children,
      selector: selector,
    );

    ddi.addChildModules(child: qualifier ?? BeanT, qualifier: moduleQualifier);

    return bean;
  }

  /// Registers a factory to create an instance of the class [BeanT].
  ///
  /// - `factory`: Factory to create the instance.
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `canRegister`: Optional function to conditionally register the instance.
  ///
  Future<void> register<BeanT extends Object>({
    required DDIBaseFactory<BeanT> factory,
    Object? qualifier,
    FutureOrBoolCallback? canRegister,
  }) {
    final bean = ddi.register(
      factory: factory,
      qualifier: qualifier,
      canRegister: canRegister,
    );

    ddi.addChildModules(child: qualifier ?? BeanT, qualifier: moduleQualifier);

    return bean;
  }
}
