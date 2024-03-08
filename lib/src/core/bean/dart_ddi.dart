import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/data/factory_clazz.dart';
import 'package:dart_ddi/src/enum/scopes.dart';
import 'package:dart_ddi/src/exception/bean_destroyed.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:dart_ddi/src/exception/circular_detection.dart';
import 'package:dart_ddi/src/exception/duplicated_bean.dart';
import 'package:dart_ddi/src/exception/future_not_accept.dart';

part 'dart_ddi_impl.dart';

DDI ddi = DDI.instance;

/// [DDI] is an abstract class representing a Dependency Injection system.
abstract class DDI {
  /// Creates the shared instance of the [DDI] class.
  static final DDI _instance = _DDIImpl();

  /// Gets the shared instance of the [DDI] class.
  static DDI get instance => _instance;

  /// Registers an instance of a class as a Singleton.
  ///
  /// - `clazzRegister`: Factory function to create the instance.
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `postConstruct`: Optional function to be executed after the instance is constructed.
  /// - `decorators`: List of decoration functions to apply to the instance.
  /// - `interceptor`: Optional interceptor to customize the creation, get, dispose or remove behavior.
  /// - `registerIf`: Optional function to conditionally register the instance.
  /// - `destroyable`: Optional parameter to make the instance indestructible.
  /// - `children`: Optional parameter, designed to receive types or qualifiers. This parameter allows you to register multiple classes under a single parent module
  ///
  /// **Singleton Scope:**
  /// - Ensures that only one instance of the registered class is created and shared throughout the entire application.
  /// - Created once when registered.
  ///
  ///  **Use Case:**
  /// - Suitable for objects that are stateless or have shared state across the entire application.
  /// - Examples include utility classes, configuration objects, or services that maintain global state.
  Future<void> registerSingleton<BeanT extends Object>(
    FutureOr<BeanT> Function() clazzRegister, {
    Object? qualifier,
    void Function()? postConstruct,
    List<BeanT Function(BeanT)>? decorators,
    List<DDIInterceptor<BeanT> Function()>? interceptors,
    FutureOr<bool> Function()? registerIf,
    bool destroyable = true,
    List<Object>? children,
  });

  /// Registers an instance of a class as a Application.
  ///
  /// - `clazzRegister`: Factory function to create the instance.
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `postConstruct`: Optional function to be executed after the instance is constructed.
  /// - `decorators`: List of decoration functions to apply to the instance.
  /// - `interceptor`: Optional interceptor to customize the creation, get, dispose or remove behavior.
  /// - `registerIf`: Optional function to conditionally register the instance.
  /// - `destroyable`: Optional parameter to make the instance indestructible.
  /// - `children`: Optional parameter, designed to receive types or qualifiers. This parameter allows you to register multiple classes under a single parent module
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
    List<Object>? children,
  });

  /// Registers an instance of a class as a Session.
  ///
  /// - `clazzRegister`: Factory function to create the instance.
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `postConstruct`: Optional function to be executed after the instance is constructed.
  /// - `decorators`: List of decoration functions to apply to the instance.
  /// - `interceptor`: Optional interceptor to customize the creation, get, dispose or remove behavior.
  /// - `registerIf`: Optional function to conditionally register the instance.
  /// - `destroyable`: Optional parameter to make the instance indestructible.
  /// - `children`: Optional parameter, designed to receive types or qualifiers. This parameter allows you to register multiple classes under a single parent module
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
    List<Object>? children,
  });

  /// Registers an instance of a class as a Dependent.
  ///
  /// - `clazzRegister`: Factory function to create the instance.
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `postConstruct`: Optional function to be executed after the instance is constructed.
  /// - `decorators`: List of decoration functions to apply to the instance.
  /// - `interceptor`: Optional interceptor to customize the creation, get, dispose or remove behavior.
  /// - `registerIf`: Optional function to conditionally register the instance.
  /// - `destroyable`: Optional parameter to make the instance indestructible.
  /// - `children`: Optional parameter, designed to receive types or qualifiers. This parameter allows you to register multiple classes under a single parent module
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
    List<Object>? children,
  });

  /// Registers an Object.
  ///
  /// - `register`: The Object to be registered.
  /// - `qualifier`: Qualifier name to identify the object.
  /// - `postConstruct`: Optional function to be executed after the instance is constructed.
  /// - `decorators`: List of decoration functions to apply to the instance.
  /// - `interceptor`: Optional interceptor to customize the creation, get, dispose or remove behavior.
  /// - `registerIf`: Optional function to conditionally register the instance.
  /// - `destroyable`: Optional parameter to make the instance indestructible.
  /// - `children`: Optional parameter, designed to receive types or qualifiers. This parameter allows you to register multiple classes under a single parent module
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
    List<Object>? children,
  });

  /// Verify if an instance is already registered in [DDI].
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  bool isRegistered<BeanT extends Object>({Object? qualifier});

  /// Gets an instance of the registered class in [DDI].
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  BeanT get<BeanT extends Object>({Object? qualifier});

  /// Gets an instance of the registered class in [DDI].
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  Future<BeanT> getAsync<BeanT extends Object>({Object? qualifier});

  /// Retrieves a list of keys associated with objects of a specific type BeanT`.
  ///
  /// This method allows you to obtain all keys (qualifier names) that have been used to register objects of the specified type `BeanT`.
  List<Object> getByType<BeanT extends Object>();

  /// Gets an instance of the registered class in [DDI].
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  BeanT call<BeanT extends Object>();

  /// Removes the instance of the registered class in [DDI].
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  void destroy<BeanT extends Object>({Object? qualifier});

  /// Removes all the instance registered as Session Scope.
  void destroyAllSession();

  /// Removes all the instance registered as type `BeanT`.
  void destroyByType<BeanT extends Object>();

  /// Disposes of the instance of the registered class in [DDI].
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  void dispose<BeanT extends Object>({Object? qualifier});

  /// Disposes all the instance registered as Session Scope.
  void disposeAllSession();

  /// Disposes all the instance registered as type `BeanT`.
  void disposeByType<BeanT extends Object>();

  /// Allows to dynamically add a Decorators.
  ///
  /// When using this method, consider the following:
  ///
  /// - **Order of Execution:** Decorators are applied in the order they are provided.
  /// - **Instaces Already Gets:** No changes any Instances that have been get.
  FutureOr<void> addDecorator<BeanT extends Object>(
      List<BeanT Function(BeanT)> decorators,
      {Object? qualifier});

  /// Allows to dynamically add a Interceptor.
  ///
  /// When using this method, consider the following:
  ///
  /// - **Scope:** Different scopes may have varying behaviors when adding interceptors.
  /// - **Around Constructor:** Will not work with Singletons Scope.
  /// - **Order of Execution:** Interceptor are applied in the order they are provided.
  /// - **Instaces Already Gets:** No changes any Instances that have been get.
  void addInterceptor<BeanT extends Object>(
      List<DDIInterceptor<BeanT> Function()> interceptors,
      {Object? qualifier});

  /// Allows to dynamically refresh the Object.
  ///
  /// When using this method, consider the following:
  ///
  /// - **Instaces Already Gets:** No changes any Instances that have been get.
  void refreshObject<BeanT extends Object>(
    BeanT register, {
    Object? qualifier,
  });

  // This function adds multiple child modules to a parent module.
  // It takes a list of 'child' objects and an optional 'qualifier' for the parent module.
  void addChildrenModules<BeanT extends Object>(
      {required List<Object> child, Object? qualifier});

  // This function adds a single child module to a parent module.
  // It takes a 'child' object and an optional 'qualifier' for the parent module.
  void addChildModules<BeanT extends Object>(
      {required Object child, Object? qualifier});

  // This function sets the debug mode.
  // It takes a boolean 'debug' parameter to enable or disable debug mode.
  void setDebugMode(bool debug);
}
