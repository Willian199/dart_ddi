import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';

mixin DDIModule implements PostConstruct {
  Object get moduleQualifier => runtimeType;

  DDI get inject => DDI.instance;

  Future<void> registerSingleton<BeanT extends Object>(
    FutureOr<BeanT> Function() clazzRegister, {
    Object? qualifier,
    void Function()? postConstruct,
    List<BeanT Function(BeanT)>? decorators,
    List<DDIInterceptor<BeanT> Function()>? interceptors,
    FutureOr<bool> Function()? registerIf,
    bool destroyable = true,
  }) {
    DDI.instance.addChildModules(child: qualifier ?? BeanT, qualifier: moduleQualifier);

    return DDI.instance.registerSingleton<BeanT>(
      clazzRegister,
      qualifier: qualifier,
      postConstruct: postConstruct,
      decorators: decorators,
      interceptors: interceptors,
      destroyable: destroyable,
      registerIf: registerIf,
    );
  }

  /// Registers an instance of a class as a Application.
  ///
  /// - `clazzRegister`: Factory function to create the instance.
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `postConstruct`: Optional function to be executed after the instance is constructed.
  /// - `decorators`: List of decoration functions to apply to the instance.
  /// - `interceptor`: Optional interceptor to customize the creation, get, dispose or remove behavior.
  /// - `registerIf`: Optional function to conditionally register the instance.
  /// - `destroyable`: Optional parameter to make the instance indestructible.
  ///
  /// **Application Scope:**
  /// - Ensures that only one instance of the registered class is created and shared throughout the entire application.
  /// - Created once when first requested.
  /// - Lazy instance creation
  ///
  ///  **Use Case:**
  /// - Appropriate for objects that need to persist during the entire application's lifecycle, but may have a more dynamic nature than Singleton instances.
  /// - Examples include managers, controllers, or services that should persist but might be recreated under certain circumstances.
  Future<void> registerApplication<BeanT extends Object>(
    FutureOr<BeanT> Function() clazzRegister, {
    Object? qualifier,
    void Function()? postConstruct,
    List<BeanT Function(BeanT)>? decorators,
    List<DDIInterceptor<BeanT> Function()>? interceptors,
    FutureOr<bool> Function()? registerIf,
    bool destroyable = true,
  }) {
    DDI.instance.addChildModules(child: qualifier ?? BeanT, qualifier: moduleQualifier);

    return DDI.instance.registerApplication<BeanT>(
      clazzRegister,
      qualifier: qualifier,
      postConstruct: postConstruct,
      decorators: decorators,
      interceptors: interceptors,
      destroyable: destroyable,
      registerIf: registerIf,
    );
  }

  /// Registers an instance of a class as a Session.
  ///
  /// - `clazzRegister`: Factory function to create the instance.
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `postConstruct`: Optional function to be executed after the instance is constructed.
  /// - `decorators`: List of decoration functions to apply to the instance.
  /// - `interceptor`: Optional interceptor to customize the creation, get, dispose or remove behavior.
  /// - `registerIf`: Optional function to conditionally register the instance.
  /// - `destroyable`: Optional parameter to make the instance indestructible.
  ///
  /// **Session Scope:**
  /// - Ensures that only one instance of the registered class is created and shared throughout the entire application.
  /// - Created once when first requested.
  /// - Lazy instance creation.
  ///
  ///  **Use Case:**
  /// - Appropriate for objects that need to persist during the entire application's lifecycle, but may have a more dynamic nature than Singleton instances.
  /// - Examples include managing user authentication state or caching user-specific preferences.
  Future<void> registerSession<BeanT extends Object>(
    FutureOr<BeanT> Function() clazzRegister, {
    Object? qualifier,
    void Function()? postConstruct,
    List<BeanT Function(BeanT)>? decorators,
    List<DDIInterceptor<BeanT> Function()>? interceptors,
    FutureOr<bool> Function()? registerIf,
    bool destroyable = true,
  }) {
    DDI.instance.addChildModules(child: qualifier ?? BeanT, qualifier: moduleQualifier);

    return DDI.instance.registerSession<BeanT>(
      clazzRegister,
      qualifier: qualifier,
      postConstruct: postConstruct,
      decorators: decorators,
      interceptors: interceptors,
      destroyable: destroyable,
      registerIf: registerIf,
    );
  }

  /// Registers an instance of a class as a Dependent.
  ///
  /// - `clazzRegister`: Factory function to create the instance.
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `postConstruct`: Optional function to be executed after the instance is constructed.
  /// - `decorators`: List of decoration functions to apply to the instance.
  /// - `interceptor`: Optional interceptor to customize the creation, get, dispose or remove behavior.
  /// - `registerIf`: Optional function to conditionally register the instance.
  /// - `destroyable`: Optional parameter to make the instance indestructible.
  ///
  /// **Dependent Scope:**
  /// - Creates a new instance every time it is requested.
  /// - It does not reuse instances and provides a fresh instance for each request.
  ///
  ///  **Use Case:**
  /// - Suitable for objects with a short lifecycle or those that need to be recreated frequently, ensuring isolation between different parts of the application.
  /// - Examples include transient objects, temporary data holders, or components with a short lifespan.
  Future<void> registerDependent<BeanT extends Object>(
    FutureOr<BeanT> Function() clazzRegister, {
    Object? qualifier,
    void Function()? postConstruct,
    List<BeanT Function(BeanT)>? decorators,
    List<DDIInterceptor<BeanT> Function()>? interceptors,
    FutureOr<bool> Function()? registerIf,
    bool destroyable = true,
  }) {
    DDI.instance.addChildModules(child: qualifier ?? BeanT, qualifier: moduleQualifier);

    return DDI.instance.registerDependent<BeanT>(
      clazzRegister,
      qualifier: qualifier,
      postConstruct: postConstruct,
      decorators: decorators,
      interceptors: interceptors,
      destroyable: destroyable,
      registerIf: registerIf,
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
  ///
  /// **Object Scope:**
  /// - Ensures that the registered Object is created and shared throughout the entire application.
  /// - Created once when registered.
  /// - Works like Singleton Scope.
  ///
  ///  **Use Case:**
  /// - Suitable for objects that are stateless or have shared state across the entire application.
  /// - Examples include application or device properties, like platform or dark mode.
  Future<void> registerObject<BeanT extends Object>(
    BeanT register, {
    Object? qualifier,
    void Function()? postConstruct,
    List<BeanT Function(BeanT)>? decorators,
    List<DDIInterceptor<BeanT> Function()>? interceptors,
    FutureOr<bool> Function()? registerIf,
    bool destroyable = true,
  }) {
    DDI.instance.addChildModules(child: qualifier ?? BeanT, qualifier: moduleQualifier);

    return DDI.instance.registerObject<BeanT>(
      register,
      qualifier: qualifier,
      postConstruct: postConstruct,
      decorators: decorators,
      interceptors: interceptors,
      destroyable: destroyable,
      registerIf: registerIf,
    );
  }
}
