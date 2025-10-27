import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/core/dart_ddi_qualifier.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:dart_ddi/src/exception/duplicated_bean.dart';
import 'package:dart_ddi/src/exception/factory_not_allowed.dart';
import 'package:dart_ddi/src/typedef/typedef.dart';
import 'package:dart_ddi/src/utils/instance_runner_utils.dart';

part 'dart_ddi_impl.dart';

/// Shortcut for getting the shared instance of the [DDI] class.
/// The [DDI] class provides methods for managing beans.
final DDI ddi = DDI.instance;

/// [DDI] is an abstract class representing a Dependency Injection system.
/// It provides methods for managing beans.
abstract class DDI {
  /// Creates the shared instance of the [DDI] class.
  static final DDI _instance = _DDIImpl();

  /// Gets the shared instance of the [DDI] class.
  static DDI get instance => _instance;

  /// Get a new instance of the [DDI] class.
  static DDI get newInstance => _DDIImpl();

  /// This method creates a new Dart Zone with its own isolated registry of beans. This allows you to
  /// register and manage instances in a separate context without affecting the global DDI container.
  /// When the zone completes, all registered instances in that zone are automatically destroyed.
  ///
  /// **Use cases:**
  /// - Testing scenarios where you need isolated instances
  /// - Temporary registrations that shouldn't persist
  /// - Scoped dependency injection for specific operations
  /// - Avoiding conflicts between different parts of the application
  ///
  /// - `name`: A unique identifier for the zone (used for debugging and identification).
  /// - `body`: The function to execute within the new zone context.
  ///
  /// **Important notes:**
  /// - Instances registered in the zone are only available within that zone
  /// - When the zone completes, all instances are automatically destroyed
  /// - The global DDI container is not affected by zone operations
  /// - Zones can be nested, with child zones having access to parent zone instances
  ///
  /// Example:
  /// ```dart
  /// final result = ddi.runInZone('test-zone', () {
  ///   // Register instances specific to this zone
  ///   ddi.registerSingleton<TestService>(TestService.new);
  ///
  ///   // Use the zone-specific instance
  ///   final service = ddi.get<TestService>();
  ///   return service.process();
  /// });
  /// // Zone instances are automatically destroyed here
  /// ```
  T runInZone<T>(String name, T Function() body);

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
  });

  /// Verify if an instance is already registered in [DDI].
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  bool isRegistered<BeanT extends Object>({Object? qualifier});

  /// Verify if the factory is a Future in [DDI].
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  bool isFuture<BeanT extends Object>({Object? qualifier});

  /// Verify if the factory is ready (Created) in [DDI].
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  bool isReady<BeanT extends Object>({Object? qualifier});

  /// Gets an instance of the registered class in [DDI].
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `parameter`: Optional parameter to pass during the instance creation.
  /// - `select`: Optional value to pass to distinguish between different instances of the same type.
  ///
  /// **Note:** The `parameter` will be ignored: If the instance is already created or the constructor doesn't match with the parameter type.
  BeanT getWith<BeanT extends Object, ParameterT extends Object>({
    ParameterT? parameter,
    Object? qualifier,
    Object? select,
  });

  /// Gets an instance of the registered class in [DDI].
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `parameter`: Optional parameter to pass during the instance creation.
  /// - `select`: Optional value to pass to distinguish between different instances of the same type.
  ///
  /// **Note:** The `parameter` will be ignored: If the instance is already created or the constructor doesn't match with the parameter type.
  Future<BeanT> getAsyncWith<BeanT extends Object, ParameterT extends Object>({
    ParameterT? parameter,
    Object? qualifier,
    Object? select,
  });

  /// Retrieves a list of keys associated with objects of a specific type `BeanT`.
  ///
  /// This method allows you to obtain all keys (qualifier names) that have been used to register objects of the specified type `BeanT`.
  /// It's useful for discovering all registered instances of a particular type, especially when using qualifiers.
  ///
  /// **Use cases:**
  /// - Discovering all registered instances of a type
  /// - Debugging registration issues
  /// - Managing multiple instances of the same type
  /// - Cleanup operations for specific types
  ///
  /// Example:
  /// ```dart
  /// // Get all registered keys for MyService
  /// final keys = ddi.getByType<MyService>();
  /// print('Registered MyService instances: $keys');
  ///
  /// // Iterate through all instances
  /// for (final key in keys) {
  ///   final instance = ddi.get<MyService>(qualifier: key);
  ///   // Process instance...
  /// }
  /// ```
  List<Object> getByType<BeanT extends Object>();

  /// Removes the instance of the registered class in [DDI].
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  FutureOr<void> destroy<BeanT extends Object>({Object? qualifier});

  /// Removes all the instance registered as type `BeanT`.
  void destroyByType<BeanT extends Object>();

  /// Disposes of the instance of the registered class in [DDI].
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  Future<void> dispose<BeanT extends Object>({Object? qualifier});

  /// Disposes all the instance registered as type `BeanT`.
  void disposeByType<BeanT extends Object>();

  /// Allows you to dynamically add decorators.
  ///
  /// When using this method, consider the following:
  ///
  /// - **Order of Execution:** Decorators are applied in the order they are provided.
  /// - **Instances Already Retrieved:** No changes are applied to instances that have already been retrieved.
  FutureOr<void> addDecorator<BeanT extends Object>(
      ListDecorator<BeanT> decorators,
      {Object? qualifier});

  /// Allows you to dynamically add interceptors to existing instances.
  ///
  /// This method allows you to add interceptors to instances that have already been registered and created.
  /// The interceptors will be applied to subsequent retrievals of the instance, but not to instances that have already been retrieved.
  ///
  /// **Important limitations:**
  /// - **Scope:** Different scopes may have varying behaviors when adding interceptors.
  /// - **onCreate:** Won't work with Singleton scope since instances are created during registration.
  /// - **Order of Execution:** Interceptors are applied in the order they are provided.
  /// - **Instances Already Retrieved:** No changes are applied to instances that have already been retrieved.
  ///
  /// **Use cases:**
  /// - Adding logging or monitoring to existing services
  /// - Implementing cross-cutting concerns dynamically
  /// - Adding validation or transformation logic to existing instances
  /// - Implementing aspect-oriented programming patterns
  ///
  /// - `interceptors`: Set of interceptor qualifiers or interceptor classes to add.
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  ///
  /// Example:
  /// ```dart
  /// // Add a logging interceptor to an existing service
  /// ddi.addInterceptor<MyService>(
  ///   {LoggingInterceptor},
  ///   qualifier: 'myService',
  /// );
  ///
  /// ```
  void addInterceptor<BeanT extends Object>(Set<Object>? interceptors,
      {Object? qualifier});

  /// Adds a single child module to a parent module.
  ///
  /// This method allows you to establish a parent-child relationship between modules,
  /// where the parent module can manage the lifecycle of its child modules.
  /// When the parent module is disposed or destroyed, all its children are also disposed or destroyed.
  ///
  /// **Use cases:**
  /// - Organizing related services into logical groups
  /// - Managing lifecycle dependencies between modules
  /// - Creating hierarchical dependency injection structures
  /// - Ensuring proper cleanup of related services
  ///
  /// - `child`: The type or qualifier of the child module to add to the parent.
  /// - `qualifier`: Optional qualifier for the parent module (defaults to the type).
  ///
  /// Example:
  /// ```dart
  /// // Add a child module to a parent
  /// ddi.addChildModules<AppModule>(
  ///   child: DatabaseModule,
  ///   qualifier: 'mainApp',
  /// );
  ///
  /// // When AppModule is disposed, DatabaseModule will also be disposed
  /// await ddi.dispose<AppModule>(qualifier: 'mainApp');
  /// ```
  void addChildModules<BeanT extends Object>(
      {required Object child, Object? qualifier});

  /// Adds multiple child modules to a parent module at once.
  ///
  /// This method allows you to establish parent-child relationships with multiple modules simultaneously.
  /// All child modules will be managed by the parent module's lifecycle.
  ///
  /// **Use cases:**
  /// - Adding multiple related modules to a parent
  /// - Bulk module organization
  /// - Creating complex module hierarchies
  /// - Managing multiple dependencies under a single parent
  ///
  /// - `child`: Set of types or qualifiers of the child modules to add to the parent.
  /// - `qualifier`: Optional qualifier for the parent module (defaults to the type).
  ///
  /// Example:
  /// ```dart
  /// // Add multiple child modules to a parent
  /// ddi.addChildrenModules<AppModule>(
  ///   child: {DatabaseModule, NetworkModule, CacheModule},
  ///   qualifier: 'mainApp',
  /// );
  ///
  /// // When AppModule is disposed, all child modules will be disposed
  /// await ddi.dispose<AppModule>(qualifier: 'mainApp');
  /// ```
  void addChildrenModules<BeanT extends Object>(
      {required Set<Object> child, Object? qualifier});

  /// Retrieves the set of child modules for a given parent module.
  ///
  /// This method returns all child modules that have been registered under the specified parent module.
  /// It's useful for discovering the module hierarchy and managing child modules.
  ///
  /// - `qualifier`: Optional qualifier for the parent module (defaults to the type).
  ///
  /// Example:
  /// ```dart
  /// // Get all child modules of AppModule
  /// final children = ddi.getChildren<AppModule>(qualifier: 'mainApp');
  /// print('Child modules: $children');
  ///
  /// // Iterate through child modules
  /// for (final child in children) {
  ///   // Process child module...
  /// }
  /// ```
  Set<Object> getChildren<BeanT extends Object>({Object? qualifier});

  /// Checks if the [DDI] instance has no registered beans.
  ///
  /// Returns `true` if no beans are currently registered in the DDI container,
  /// `false` otherwise.
  ///
  bool get isEmpty;

  /// Retrieves the number of registered beans in the [DDI] instance.
  ///
  /// Returns the total count of all registered beans across all types and qualifiers.
  ///
  int get length;
}
