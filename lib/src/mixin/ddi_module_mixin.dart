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
///     print('do something after construct or register the childrens beans');
///
///     registerApplication<MyEvent>(() => MyEvent());
///     registerSingleton<OtherEvent>(() => OtherEvent());
///     registerDependent<SimpleEvent>(() => SimpleEvent());
///   }
/// }
/// ```

mixin DDIModule implements PostConstruct {
  Object? _internalQualifier;

  Object get moduleQualifier => _internalQualifier ?? runtimeType;

  set moduleQualifier(Object value) {
    _internalQualifier = value;
  }

  List<Object> get children => ddi.getChildren(qualifier: moduleQualifier);

  /// Registers an instance as a Singleton.
  ///
  /// - `clazzRegister`: Factory function to create the instance.
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `postConstruct`: Optional function to be executed after the instance is constructed.
  /// - `decorators`: List of decoration functions to apply to the instance.
  /// - `interceptor`: Optional interceptor to customize the creation, get, dispose or remove behavior.
  /// - `registerIf`: Optional function to conditionally register the instance.
  /// - `destroyable`: Optional parameter to make the instance indestructible.
  Future<void> registerSingleton<BeanT extends Object>(
    BeanRegister<BeanT> clazzRegister, {
    Object? qualifier,
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    ListDDIInterceptor<BeanT>? interceptors,
    FutureOrBoolCallback? registerIf,
    bool destroyable = true,
    List<Object>? children,
  }) {
    ddi.addChildModules(child: qualifier ?? BeanT, qualifier: moduleQualifier);

    return ddi.registerSingleton<BeanT>(
      clazzRegister,
      qualifier: qualifier,
      postConstruct: postConstruct,
      decorators: decorators,
      interceptors: interceptors,
      destroyable: destroyable,
      registerIf: registerIf,
      children: children,
    );
  }

  /// Registers an instance as an Application.
  ///
  /// - `clazzRegister`: Factory function to create the instance.
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `postConstruct`: Optional function to be executed after the instance is constructed.
  /// - `decorators`: List of decoration functions to apply to the instance.
  /// - `interceptor`: Optional interceptor to customize the creation, get, dispose or remove behavior.
  /// - `registerIf`: Optional function to conditionally register the instance.
  /// - `destroyable`: Optional parameter to make the instance indestructible.
  /// - `children`: Optional parameter, designed to receive types or qualifiers. This parameter allows you to register multiple classes under a single parent module.
  Future<void> registerApplication<BeanT extends Object>(
    BeanRegister<BeanT> clazzRegister, {
    Object? qualifier,
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    ListDDIInterceptor<BeanT>? interceptors,
    FutureOrBoolCallback? registerIf,
    bool destroyable = true,
    List<Object>? children,
  }) {
    ddi.addChildModules(child: qualifier ?? BeanT, qualifier: moduleQualifier);

    return ddi.registerApplication<BeanT>(
      clazzRegister,
      qualifier: qualifier,
      postConstruct: postConstruct,
      decorators: decorators,
      interceptors: interceptors,
      destroyable: destroyable,
      registerIf: registerIf,
      children: children,
    );
  }

  /// Registers an instance as a Session.
  ///
  /// - `clazzRegister`: Factory function to create the instance.
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `postConstruct`: Optional function to be executed after the instance is constructed.
  /// - `decorators`: List of decoration functions to apply to the instance.
  /// - `interceptor`: Optional interceptor to customize the creation, get, dispose or remove behavior.
  /// - `registerIf`: Optional function to conditionally register the instance.
  /// - `destroyable`: Optional parameter to make the instance indestructible.
  /// - `children`: Optional parameter, designed to receive types or qualifiers. This parameter allows you to register multiple classes under a single parent module.
  Future<void> registerSession<BeanT extends Object>(
    BeanRegister<BeanT> clazzRegister, {
    Object? qualifier,
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    ListDDIInterceptor<BeanT>? interceptors,
    FutureOrBoolCallback? registerIf,
    bool destroyable = true,
    List<Object>? children,
  }) {
    ddi.addChildModules(child: qualifier ?? BeanT, qualifier: moduleQualifier);

    return ddi.registerSession<BeanT>(
      clazzRegister,
      qualifier: qualifier,
      postConstruct: postConstruct,
      decorators: decorators,
      interceptors: interceptors,
      destroyable: destroyable,
      registerIf: registerIf,
      children: children,
    );
  }

  /// Registers an instance as a Dependent.
  ///
  /// - `clazzRegister`: Factory function to create the instance.
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `postConstruct`: Optional function to be executed after the instance is constructed.
  /// - `decorators`: List of decoration functions to apply to the instance.
  /// - `interceptor`: Optional interceptor to customize the creation, get, dispose or remove behavior.
  /// - `registerIf`: Optional function to conditionally register the instance.
  /// - `destroyable`: Optional parameter to make the instance indestructible.
  /// - `children`: Optional parameter, designed to receive types or qualifiers. This parameter allows you to register multiple classes under a single parent module.
  Future<void> registerDependent<BeanT extends Object>(
    BeanRegister<BeanT> clazzRegister, {
    Object? qualifier,
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    ListDDIInterceptor<BeanT>? interceptors,
    FutureOrBoolCallback? registerIf,
    bool destroyable = true,
    List<Object>? children,
  }) {
    ddi.addChildModules(child: qualifier ?? BeanT, qualifier: moduleQualifier);

    return ddi.registerDependent<BeanT>(
      clazzRegister,
      qualifier: qualifier,
      postConstruct: postConstruct,
      decorators: decorators,
      interceptors: interceptors,
      destroyable: destroyable,
      registerIf: registerIf,
      children: children,
    );
  }

  /// Registers an Object.
  ///
  /// - `register`: The Object to be registered.
  /// - `qualifier`: Qualifier name to identify the object.
  /// - `postConstruct`: Optional function to be executed after the instance is constructed.
  /// - `decorators`: List of decoration functions to apply to the instance.
  /// - `interceptor`: Optional interceptor to customize the creation, get, dispose or remove behavior.
  /// - `registerIf`: Optional function to conditionally register the instance.
  /// - `destroyable`: Optional parameter to make the instance indestructible.
  /// - `children`: Optional parameter, designed to receive types or qualifiers. This parameter allows you to register multiple classes under a single parent module.
  Future<void> registerObject<BeanT extends Object>(
    BeanT register, {
    Object? qualifier,
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    ListDDIInterceptor<BeanT>? interceptors,
    FutureOrBoolCallback? registerIf,
    bool destroyable = true,
    List<Object>? children,
  }) {
    ddi.addChildModules(child: qualifier ?? BeanT, qualifier: moduleQualifier);

    return ddi.registerObject<BeanT>(
      register,
      qualifier: qualifier,
      postConstruct: postConstruct,
      decorators: decorators,
      interceptors: interceptors,
      destroyable: destroyable,
      registerIf: registerIf,
      children: children,
    );
  }
}
