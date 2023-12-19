import 'package:dart_di/data/factory_clazz.dart';
import 'package:dart_di/enum/scopes.dart';
import 'package:dart_di/features/ddi_interceptor.dart';
import 'package:flutter/material.dart';

part 'dart_di_impl.dart';

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
    DDIInterceptor Function()? interceptor,
    bool Function()? registerIf,
  });

  /// Registers an instance of a class as a Application.
  ///
  /// - `clazzRegister`: Factory function to create the instance.
  /// - `qualifierName`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `postConstruct`: Optional function to be executed after the instance is constructed.
  /// - `decorators`: List of decoration functions to apply to the instance.
  /// - `interceptor`: Optional interceptor to customize the creation, get, dispose or remove behavior.
  /// - `registerIf`: Optional function to conditionally register the instance.
  ///
  /// **Application Scope:**
  /// - Ensures that only one instance of the registered class is created and shared throughout the entire application.
  /// - Created once when first requested.
  ///
  ///  **Use Case:**
  /// - Appropriate for objects that need to persist during the entire application's lifecycle, but may have a more dynamic nature than Singleton instances.
  /// - Examples include managers, controllers, or services that should persist but might be recreated under certain circumstances.
  void registerApplication<T extends Object>(
    T Function() clazzRegister, {
    Object? qualifierName,
    void Function()? postConstruct,
    List<T Function(T)>? decorators,
    DDIInterceptor Function()? interceptor,
    bool Function()? registerIf,
  });

  /// Registers an instance of a class as a Dependent.
  ///
  /// - `clazzRegister`: Factory function to create the instance.
  /// - `qualifierName`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `postConstruct`: Optional function to be executed after the instance is constructed.
  /// - `decorators`: List of decoration functions to apply to the instance.
  /// - `interceptor`: Optional interceptor to customize the creation, get, dispose or remove behavior.
  /// - `registerIf`: Optional function to conditionally register the instance.
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
    DDIInterceptor Function()? interceptor,
    bool Function()? registerIf,
  });

  void registerSession<T extends Object>(
    T Function() clazzRegister, {
    Object? qualifierName,
    void Function()? postConstruct,
    List<T Function(T)>? decorators,
    DDIInterceptor Function()? interceptor,
    bool Function()? registerIf,
  });

  /// Registers an instance of a class as a Dependent.
  ///
  /// - `clazzRegister`: Factory function to create the instance.
  /// - `qualifierName`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `postConstruct`: Optional function to be executed after the instance is constructed.
  /// - `decorators`: List of decoration functions to apply to the instance.
  /// - `interceptor`: Optional interceptor to customize the creation, get, dispose or remove behavior.
  /// - `registerIf`: Optional function to conditionally register the instance.
  ///
  /// **Dependent Scope:**
  /// - Creates a new instance every time it is requested.
  /// - It does not reuse instances and provides a fresh instance for each request.
  ///
  ///  **Use Case:**
  /// - Suitable for objects with a short lifecycle or those that need to be recreated frequently, ensuring isolation between different parts of the application.
  /// - Examples include transient objects, temporary data holders, or components with a short lifespan.
  void registerWidget<T extends Widget>(
    T Function() clazzRegister, {
    Object? qualifierName,
    void Function()? postConstruct,
    List<T Function(T)>? decorators,
    DDIInterceptor Function()? interceptor,
    bool Function()? registerIf,
  });

  /// Gets an instance of the registered class in [DDI].
  ///
  /// - `qualifierName`: Optional qualifier name to distinguish between different instances of the same type.
  T get<T extends Object>({Object? qualifierName});

  /// Gets an instance of the registered class in [DDI].
  ///
  /// - `qualifierName`: Optional qualifier name to distinguish between different instances of the same type.
  T call<T extends Object>();

  /// Removes the instance of the registered class in [DDI].
  ///
  /// - `qualifierName`: Optional qualifier name to distinguish between different instances of the same type.
  void destroy<T>({Object? qualifierName});

  /// Disposes of the instance of the registered class in [DDI].
  ///
  /// - `qualifierName`: Optional qualifier name to distinguish between different instances of the same type.
  void dispose<T>({Object? qualifierName});
}
