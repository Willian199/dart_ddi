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

  /// Getter for the DDI instance to use.
  ///
  /// By default, returns [DDI.instance]. Classes using this mixin can override
  /// this getter to use a different DDI container (e.g., [DDI.newInstance()]).
  ///
  /// Alternatively, the DDI instance can be set via the [ddiInstance] setter
  /// when the module is created by a factory.
  ///
  /// Example:
  /// ```dart
  /// class MyModule with DDIModule {
  ///   final DDI _customDdi = DDI.newInstance();
  ///
  ///   @override
  ///   DDI get ddi => _customDdi;
  ///
  ///   @override
  ///   void onPostConstruct() {
  ///     singleton<MyService>(MyService.new);
  ///   }
  /// }
  /// ```
  DDI get ddiContainer => DDI.instance;

  Set<Object> get children =>
      ddiContainer.getChildren(qualifier: moduleQualifier);

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
  /// Obs: If you want to capture the error during the registration, you must await for it.
  Future<void> singleton<BeanT extends Object>(
    BeanRegister<BeanT> clazzRegister, {
    Object? qualifier,
    ListDecorator<BeanT> decorators = const [],
    Set<Object> interceptors = const {},
    Set<Object> children = const {},
    FutureOrBoolCallback? canRegister,
    bool canDestroy = true,
    FutureOr<bool> Function(Object)? selector,
  }) async {
    final bean = ddiContainer.singleton<BeanT>(
      clazzRegister,
      qualifier: qualifier,
      decorators: decorators,
      interceptors: interceptors,
      canDestroy: canDestroy,
      canRegister: canRegister,
      children: children,
      selector: selector,
    );

    // Ensure the module is registered before adding children
    // Also throws the error if registration failed
    if (!ddiContainer.isRegistered(qualifier: moduleQualifier)) {
      await bean;
    }

    ddiContainer.addChildModules(
        child: qualifier ?? BeanT, qualifier: moduleQualifier);

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
  }) async {
    final bean = ddiContainer.application<BeanT>(
      clazzRegister,
      qualifier: qualifier,
      decorators: decorators,
      interceptors: interceptors,
      canDestroy: canDestroy,
      canRegister: canRegister,
      children: children,
      selector: selector,
    );

    // Ensure the module is registered before adding children
    // Also throws the error if registration failed
    if (!ddiContainer.isRegistered(qualifier: moduleQualifier)) {
      await bean;
    }

    ddiContainer.addChildModules(
        child: qualifier ?? BeanT, qualifier: moduleQualifier);

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
  }) async {
    final bean = ddiContainer.dependent<BeanT>(
      clazzRegister,
      qualifier: qualifier,
      decorators: decorators,
      interceptors: interceptors,
      canDestroy: canDestroy,
      canRegister: canRegister,
      children: children,
      selector: selector,
    );

    // Ensure the module is registered before adding children
    // Also throws the error if registration failed
    if (!ddiContainer.isRegistered(qualifier: moduleQualifier)) {
      await bean;
    }

    ddiContainer.addChildModules(
        child: qualifier ?? BeanT, qualifier: moduleQualifier);

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
  /// Obs: If you want to capture the error during the registration, you must await for it.
  Future<void> object<BeanT extends Object>(
    BeanT instance, {
    Object? qualifier,
    ListDecorator<BeanT> decorators = const [],
    Set<Object> interceptors = const {},
    Set<Object> children = const {},
    FutureOrBoolCallback? canRegister,
    bool canDestroy = true,
    FutureOr<bool> Function(Object)? selector,
  }) async {
    final bean = ddiContainer.object<BeanT>(
      instance,
      qualifier: qualifier,
      decorators: decorators,
      interceptors: interceptors,
      canDestroy: canDestroy,
      canRegister: canRegister,
      children: children,
      selector: selector,
    );

    // Ensure the module is registered before adding children
    // Also throws the error if registration failed
    if (!ddiContainer.isRegistered(qualifier: moduleQualifier)) {
      await bean;
    }

    ddiContainer.addChildModules(
        child: qualifier ?? BeanT, qualifier: moduleQualifier);

    return bean;
  }

  /// Registers a factory to create an instance of the class [BeanT].
  ///
  /// - `factory`: Factory to create the instance.
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `canRegister`: Optional function to conditionally register the instance.
  ///
  /// Obs: If you want to capture the error during the registration, you must await for it.
  Future<void> register<BeanT extends Object>({
    required DDIBaseFactory<BeanT> factory,
    Object? qualifier,
    FutureOrBoolCallback? canRegister,
  }) async {
    final bean = ddiContainer.register(
      factory: factory,
      qualifier: qualifier,
      canRegister: canRegister,
    );

    // Ensure the module is registered before adding children
    // Also throws the error if registration failed
    if (!ddiContainer.isRegistered(qualifier: moduleQualifier)) {
      await bean;
    }

    ddiContainer.addChildModules(
        child: qualifier ?? BeanT, qualifier: moduleQualifier);

    return bean;
  }
}
