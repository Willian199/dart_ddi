import 'dart:async';

import 'package:dart_ddi/src/data/factory_clazz.dart';
import 'package:dart_ddi/src/enum/scopes.dart';
import 'package:dart_ddi/src/features/ddi_interceptor.dart';
import 'package:flutter/material.dart';

part 'dart_ddi_impl.dart';

/// Extension for convenient dependency injection access within the context of a Flutter widget.
extension DDIContext on BuildContext {
  /// Retrieves an instance of type `T`.
  ///
  /// The [qualifierName] parameter is optional and can be used to distinguish between instances of the same type.
  ///
  /// Example:
  /// ```dart
  /// MyService myService = context.ddi<MyService>(qualifierName: 'customQualifier');
  /// ```
  ///
  T ddi<T extends Object>({Object? qualifierName}) =>
      DDI.instance.get<T>(qualifierName: qualifierName);
}

/// [DDI] is an abstract class representing a Dependency Injection system.
abstract class DDI {
  /// Creates the shared instance of the [DDI] class.
  static final DDI _instance = _DDIImpl();

  /// Gets the shared instance of the [DDI] class.
  static DDI get instance => _instance;

  /// Registers an instance of a class as a Singleton.
  ///
  /// - `clazzRegister`: Factory function to create the instance.
  /// - `qualifierName`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `postConstruct`: Optional function to be executed after the instance is constructed.
  /// - `decorators`: List of decoration functions to apply to the instance.
  /// - `interceptor`: Optional interceptor to customize the creation, get, dispose or remove behavior.
  /// - `registerIf`: Optional function to conditionally register the instance.
  ///
  /// **Singleton Scope:**
  /// - Ensures that only one instance of the registered class is created and shared throughout the entire application.
  /// - Created once when registered.
  ///
  ///  **Use Case:**
  /// - Suitable for objects that are stateless or have shared state across the entire application.
  /// - Examples include utility classes, configuration objects, or services that maintain global state.
  void registerSingleton<T extends Object>(
    T Function() clazzRegister, {
    Object? qualifierName,
    void Function()? postConstruct,
    List<T Function(T)>? decorators,
    List<DDIInterceptor<T> Function()>? interceptors,
    bool Function()? registerIf,
    bool destroyable = true,
  });

  /// Registers an instance of a class as a Application.
  ///
  /// - `clazzRegister`: Factory function to create the instance.
  /// - `qualifierName`: Optional qualifier name to distinguish between different instances of the same type.
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
  void registerApplication<T extends Object>(
    T Function() clazzRegister, {
    Object? qualifierName,
    void Function()? postConstruct,
    List<T Function(T)>? decorators,
    List<DDIInterceptor<T> Function()>? interceptors,
    bool Function()? registerIf,
    bool destroyable = true,
  });

  /// Registers an instance of a class as a Session.
  ///
  /// - `clazzRegister`: Factory function to create the instance.
  /// - `qualifierName`: Optional qualifier name to distinguish between different instances of the same type.
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
  void registerSession<T extends Object>(
    T Function() clazzRegister, {
    Object? qualifierName,
    void Function()? postConstruct,
    List<T Function(T)>? decorators,
    List<DDIInterceptor<T> Function()>? interceptors,
    bool Function()? registerIf,
    bool destroyable = true,
  });

  /// Registers an instance of a class as a Dependent.
  ///
  /// - `clazzRegister`: Factory function to create the instance.
  /// - `qualifierName`: Optional qualifier name to distinguish between different instances of the same type.
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
  void registerDependent<T extends Object>(
    T Function() clazzRegister, {
    Object? qualifierName,
    void Function()? postConstruct,
    List<T Function(T)>? decorators,
    List<DDIInterceptor<T> Function()>? interceptors,
    bool Function()? registerIf,
    bool destroyable = true,
  });

  /// Registers an Object.
  ///
  /// - `register`: The Object to be registered.
  /// - `qualifierName`: Optional qualifier name to distinguish between different instances of the same type.
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
  void registerObject<T extends Object>({
    required Object qualifierName,
    required T register,
    void Function()? postConstruct,
    List<T Function(T)>? decorators,
    List<DDIInterceptor<T> Function()>? interceptors,
    bool Function()? registerIf,
    bool destroyable = true,
  });

  /// Gets an instance of the registered class in [DDI].
  ///
  /// - `qualifierName`: Optional qualifier name to distinguish between different instances of the same type.
  T get<T extends Object>({Object? qualifierName});

  /// Retrieves a list of keys associated with objects of a specific type `T`.
  ///
  /// This method allows you to obtain all keys (qualifier names) that have been used to register objects of the specified type `T`.
  List<Object> getByType<T extends Object>();

  /// Gets an instance of the registered class in [DDI].
  ///
  /// - `qualifierName`: Optional qualifier name to distinguish between different instances of the same type.
  T call<T extends Object>();

  /// Removes the instance of the registered class in [DDI].
  ///
  /// - `qualifierName`: Optional qualifier name to distinguish between different instances of the same type.
  void destroy<T>({Object? qualifierName});

  /// Removes all the instance registered as Session Scope.
  void destroyAllSession();

  /// Removes all the instance registered as type `T`.
  void destroyByType<T extends Object>();

  /// Disposes of the instance of the registered class in [DDI].
  ///
  /// - `qualifierName`: Optional qualifier name to distinguish between different instances of the same type.
  void dispose<T>({Object? qualifierName});

  /// Disposes all the instance registered as Session Scope.
  void disposeAllSession();

  /// Disposes all the instance registered as type `T`.
  void disposeByType<T extends Object>();

  /// Allows to dynamically add a Decorators.
  ///
  /// When using this method, consider the following:
  ///
  /// - **Order of Execution:** Decorators are applied in the order they are provided.
  /// - **Instaces Already Gets:** No changes any Instances that have been get.
  void addDecorator<T extends Object>(List<T Function(T)> decorators,
      {Object? qualifierName});

  /// Allows to dynamically add a Interceptor.
  ///
  /// When using this method, consider the following:
  ///
  /// - **Scope:** Different scopes may have varying behaviors when adding interceptors.
  /// - **Aorund Constructor:** Will not work with Singletons Scope.
  /// - **Order of Execution:** Interceptor are applied in the order they are provided.
  /// - **Instaces Already Gets:** No changes any Instances that have been get.
  void addInterceptor<T extends Object>(
      List<DDIInterceptor<T> Function()> interceptors,
      {Object? qualifierName});
}
