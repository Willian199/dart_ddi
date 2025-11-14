import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/typedef/typedef.dart';

extension DDIRegisterExtension on DDI {
  /// Registers an instance as a Singleton.
  ///
  /// - `clazzRegister`: Factory function to create the instance.
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `decorators`: List of decoration functions to apply to the instance.
  /// - `interceptor`: Optional interceptor to customize the creation, get, dispose or remove behavior.
  /// - `canRegister`: Optional function to conditionally register the instance.
  /// - `canDestroy`: Optional parameter to make the instance indestructible.
  /// - `children`: Optional parameter, designed to receive types or qualifiers. This parameter allows you to register multiple classes under a single parent module.
  /// - `selector`: Optional function that allows conditional selection of instances based on specific criteria. Useful for dynamically choosing an instance at runtime based on application context.
  /// - `required`: Optional set of qualifiers or types that must be registered before creating an instance.
  ///
  /// **Singleton Scope:**
  /// - Ensures that only one instance of the registered class is created and shared throughout the entire application.
  /// - Created once when registered.
  ///
  ///  **Use Case:**
  /// - Suitable for objects that are stateless or have shared state across the entire application.
  /// - Examples include utility classes, configuration objects, or services that maintain global state.
  Future<void> singleton<BeanT extends Object>(
    BeanRegister<BeanT> clazzRegister, {
    Object? qualifier,
    FutureOrBoolCallback? canRegister,
    bool canDestroy = true,
    ListDecorator<BeanT> decorators = const [],
    Set<Object> interceptors = const {},
    Set<Object> children = const {},
    FutureOr<bool> Function(Object)? selector,
    Set<Object>? required,
  }) {
    return register<BeanT>(
      factory: SingletonFactory<BeanT>(
        builder: clazzRegister.builder,
        children: children,
        interceptors: interceptors,
        decorators: decorators,
        canDestroy: canDestroy,
        selector: selector,
        required: required,
      ),
      qualifier: qualifier,
      canRegister: canRegister,
    );
  }

  /// Registers an instance as an Application.
  ///
  /// - `clazzRegister`: Factory function to create the instance.
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `decorators`: List of decoration functions to apply to the instance.
  /// - `interceptor`: Optional interceptor to customize the creation, get, dispose or remove behavior.
  /// - `canRegister`: Optional function to conditionally register the instance.
  /// - `canDestroy`: Optional parameter to make the instance indestructible.
  /// - `children`: Optional parameter, designed to receive types or qualifiers. This parameter allows you to register multiple classes under a single parent module.
  /// - `selector`: Optional function that allows conditional selection of instances based on specific criteria. Useful for dynamically choosing an instance at runtime based on application context.
  /// - `required`: Optional set of qualifiers or types that must be registered before creating an instance.
  ///
  /// **Application Scope:**
  /// - Ensures that only one instance of the registered class is created and shared throughout the entire application.
  /// - Created once when first requested.
  /// - Lazy instance creation
  ///
  ///  **Use Case:**
  /// - Appropriate for objects that need to persist during the entire application's lifecycle, but may have a more dynamic nature than Singleton instances.
  /// - Examples include managers, controllers, or services that should persist but might be recreated under certain circumstances.
  Future<void> application<BeanT extends Object>(
    BeanRegister<BeanT> clazzRegister, {
    Object? qualifier,
    FutureOrBoolCallback? canRegister,
    bool canDestroy = true,
    ListDecorator<BeanT> decorators = const [],
    Set<Object> interceptors = const {},
    Set<Object> children = const {},
    FutureOr<bool> Function(Object)? selector,
    bool useWeakReference = false,
    Set<Object>? required,
  }) {
    return register<BeanT>(
      factory: ApplicationFactory<BeanT>(
        builder: clazzRegister.builder,
        children: children,
        interceptors: interceptors,
        decorators: decorators,
        canDestroy: canDestroy,
        selector: selector,
        useWeakReference: useWeakReference,
        required: required,
      ),
      qualifier: qualifier,
      canRegister: canRegister,
    );
  }

  /// Registers an instance as a Dependent.
  ///
  /// - `clazzRegister`: Factory function to create the instance.
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `decorators`: List of decoration functions to apply to the instance.
  /// - `interceptor`: Optional interceptor to customize the creation, get, dispose or remove behavior.
  /// - `canRegister`: Optional function to conditionally register the instance.
  /// - `canDestroy`: Optional parameter to make the instance indestructible.
  /// - `children`: Optional parameter, designed to receive types or qualifiers. This parameter allows you to register multiple classes under a single parent module
  /// - `selector`: Optional function that allows conditional selection of instances based on specific criteria. Useful for dynamically choosing an instance at runtime based on application context.
  /// - `required`: Optional set of qualifiers or types that must be registered before creating an instance.
  ///
  /// **Dependent Scope:**
  /// - Creates a new instance every time it is requested.
  /// - It does not reuse instances and provides a fresh instance for each request.
  ///
  ///  **Use Case:**
  /// - Suitable for objects with a short lifecycle or those that need to be recreated frequently, ensuring isolation between different parts of the application.
  /// - Examples include transient objects, temporary data holders, or components with a short lifespan.
  Future<void> dependent<BeanT extends Object>(
    BeanRegister<BeanT> clazzRegister, {
    Object? qualifier,
    FutureOrBoolCallback? canRegister,
    bool canDestroy = true,
    ListDecorator<BeanT> decorators = const [],
    Set<Object> interceptors = const {},
    Set<Object> children = const {},
    FutureOr<bool> Function(Object)? selector,
    Set<Object>? required,
  }) {
    return register<BeanT>(
      factory: DependentFactory<BeanT>(
        builder: clazzRegister.builder,
        children: children,
        interceptors: interceptors,
        decorators: decorators,
        canDestroy: canDestroy,
        selector: selector,
        required: required,
      ),
      qualifier: qualifier,
      canRegister: canRegister,
    );
  }

  /// Registers an instance as a Object Scope.
  ///
  /// - `instance`: The instance to be registered.
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `decorators`: List of decoration functions to apply to the instance.
  /// - `interceptor`: Optional interceptor to customize the creation, get, dispose or remove behavior.
  /// - `canRegister`: Optional function to conditionally register the instance.
  /// - `canDestroy`: Optional parameter to make the instance indestructible.
  /// - `children`: Optional parameter, designed to receive types or qualifiers. This parameter allows you to register multiple classes under a single parent module.
  /// - `selector`: Optional function that allows conditional selection of instances based on specific criteria. Useful for dynamically choosing an instance at runtime based on application context.
  /// - `required`: Optional set of qualifiers or types that must be registered before creating an instance.
  ///
  /// **Singleton Scope:**
  /// - Ensures that only one instance of the registered class is created and shared throughout the entire application.
  /// - Created once when registered.
  ///
  ///  **Use Case:**
  /// - Suitable for objects that are stateless or have shared state across the entire application.
  /// - Examples include utility classes, configuration objects, or services that maintain global state.
  Future<void> object<BeanT extends Object>(
    BeanT instance, {
    Object? qualifier,
    FutureOrBoolCallback? canRegister,
    bool canDestroy = true,
    ListDecorator<BeanT> decorators = const [],
    Set<Object> interceptors = const {},
    Set<Object> children = const {},
    FutureOr<bool> Function(Object)? selector,
    Set<Object>? required,
  }) {
    return register<BeanT>(
      factory: ObjectFactory<BeanT>(
        instance: instance,
        children: children,
        interceptors: interceptors,
        decorators: decorators,
        canDestroy: canDestroy,
        selector: selector,
        required: required,
      ),
      qualifier: qualifier,
      canRegister: canRegister,
    );
  }
}
