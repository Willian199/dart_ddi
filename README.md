<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

# Dart Dependency Injection (DDI) Package

[![pub package](https://img.shields.io/pub/v/dart_ddi.svg?logo=dart&logoColor=00b9fc)](https://pub.dartlang.org/packages/dart_ddi)
[![CI](https://img.shields.io/github/actions/workflow/status/Willian199/dart_ddi/dart.yml?branch=master&logo=github-actions&logoColor=white)](https://github.com/Willian199/dart_ddi/actions)
[![Coverage Status](https://coveralls.io/repos/github/Willian199/dart_ddi/badge.svg?branch=master)](https://coveralls.io/github/Willian199/dart_ddi?branch=master)
[![Last Commits](https://img.shields.io/github/last-commit/Willian199/dart_ddi?logo=git&logoColor=white)](https://github.com/Willian199/dart_ddi/commits/master)
[![Issues](https://img.shields.io/github/issues/Willian199/dart_ddi?logo=github&logoColor=white)](https://github.com/Willian199/dart_ddi/issues)
[![Pull Requests](https://img.shields.io/github/issues-pr/Willian199/dart_ddi?logo=github&logoColor=white)](https://github.com/Willian199/dart_ddi/pulls)
[![Code size](https://img.shields.io/github/languages/code-size/Willian199/dart_ddi?logo=github&logoColor=white)](https://github.com/Willian199/dart_ddi)
[![License](https://img.shields.io/github/license/Willian199/dart_ddi?logo=open-source-initiative&logoColor=green)](https://github.com/Willian199/dart_ddi/blob/master/LICENSE)

## Overview

The Dart Dependency Injection (DDI) package is a robust and flexible dependency injection mechanism. It facilitates the management of object instances and their lifecycles by introducing different scopes and customization options. This documentation aims to provide an in-depth understanding of DDI's core concepts, usage, and features.

🚀 Contribute to the DDI by sharing your ideas, feedback, or practical examples.

See this [example](https://github.com/Willian199/dart_ddi/blob/master/example/main.dart) to get started with DDI.

## Packages

- [Flutter DDI](https://pub.dev/packages/flutter_ddi) - This package is designed to facilitate the dependency injection process in your Flutter application.

## Projects

- [Budgetopia](https://github.com/Willian199/budgetopia) - An intuitive personal finance app that helps users track expenses.
- [Perfumei](https://github.com/Willian199/Perfumei) - A simple mobile app about perfumes. Built using DDI and Cubit.
- [Clinicas](https://github.com/Willian199/lab_clinicas_fe) - A project for a mobile, desktop and web application about Attendance Rank. Built using Signal and Flutter DDI to enable route-based dependency injection management.

### Summary

1. [Core Concepts](#core-concepts)
   1. [Singleton](#singleton)
   2. [Application](#application)
   3. [Dependent](#dependent)
   4. [Object](#object)
   5. [Common Considerations](#common-considerations)
   6. [Custom Scopes](#custom-scopes)
   7. [Zone Management](#zone-management)
2. [Instance Wrapper](#instance-wrapper)
   1. [Overview](#instance-wrapper-overview)
   2. [Cache and Weak Reference](#instance-cache-and-weak-reference)
   3. [Interceptor and Decorator Behavior](#instance-interceptor-and-decorator-behavior)
   4. [Use Cases](#instance-use-cases)
3. [Factories](#factories)
   1. [How Factories Work](#how-factories-work)
   2. [Use Cases for Factories](#use-cases-for-factories)
   3. [Considerations](#considerations)
4. [Qualifiers](#qualifiers)
   1. [How Qualifiers Work](#how-qualifiers-work)
   2. [Use Cases for Qualifiers](#use-cases-for-qualifiers)
   3. [Considerations](#considerations)
5. [Extra Customization](#extra-customization)
   1. [PostConstruct](#postconstruct)
   2. [Decorators](#decorators)
   3. [Interceptor](#interceptor)
   4. [CanRegister](#canregister)
   5. [CanDestroy](#candestroy)
   6. [Selectors](#selector)
   7. [Required Dependencies](#required-dependencies)
6. [Modules](#modules)
   1. [Adding a Class](#adding-a-class)
   2. [Adding Multiple Classes](#adding-multiple-classes)
7. [Mixins](#mixins)
   1. [Post Construct](#post-construct-mixin)
   2. [Pre Destroy](#pre-destroy-mixin)
   3. [Pre Dispose](#pre-dispose-mixin)
   4. [DDIModule Mixin](#ddimodule-mixin)
   5. [DDIInject, DDIInjectAsync and DDIComponentInject Mixins](#ddiinject-ddiinjectasync-and-ddicomponentinject-mixins)

# Core Concepts
## Scopes

The Dart Dependency Injection (DDI) package supports various scopes for efficient management of object instances. Each scope determines how instances are created, reused, and destroyed throughout the application lifecycle. Below are detailed characteristics of each scope, along with recommendations, use cases, and considerations for potential issues.

## Singleton
This scope creates a single instance during registration and reuses it in all subsequent requests.

**Recommendation**: Suitable for objects that need to be globally shared across the application, maintaining a single instance.

**Use Case**: Sharing a configuration manager, a logging service, or a global state manager.

**Required Dependencies**: You can use the `required` parameter to ensure dependencies are registered and ready before instance creation. Validation occurs during `register()`.      

**Note**: 

 * `Interceptor.onDispose` and `PreDispose` mixin are not supported. You can just destroy the instance. 

 * If you call dispose, only the Application children will be disposed.

## Application
Generates an instance when first used and reuses it for all subsequent requests during the application's execution.

**Recommendation**: Indicated for objects that need to be created only once per application and shared across different parts of the code.

**Use Case**: Managing application-level resources, such as a network client or a global configuration.

**Note**: `PreDispose` and `PreDestroy` mixins will only be called if the instance is in use. Use `Interceptor` if you want to call them regardless.

**Required Dependencies**: You can use the `required` parameter to ensure dependencies are registered and ready before instance creation. Validation occurs during `getWith()` or `getAsyncWith()`.

## Dependent
Produces a new instance every time it is requested, ensuring independence and uniqueness.

**Recommendation**: Useful for objects that should remain independent and different in each context or request.

**Use Case**: Creating instances of transient objects like data repositories or request handlers.

**Required Dependencies**: You can use the `required` parameter to ensure dependencies are registered before instance creation. Validation occurs during `getWith()` or `getAsyncWith()`. 

**Note**:

 * `Dispose` functions, `Interceptor.onDispose` and `PreDispose` mixin are not supported.

 * `PreDestroy` mixins are not supported. Use `Interceptor.onDestroy` instead.

## Object
Registers an Object in the Object Scope, ensuring it is created once and shared throughout the entire application, working like Singleton.

**Recommendation**: Suitable for objects that are stateless or have shared state across the entire application.

**Use Case**: Application or device properties, like platform or dark mode settings, where the object's state needs to be consistent across the entire application.

**Required Dependencies**: You can use the `required` parameter to ensure dependencies are registered and ready before instance creation. Validation occurs during `register()`.

**Note**:

 * `Interceptor.onDispose` and `PreDispose` mixin are not supported. You can just destroy the instance.

 * If you call dispose, only the Application children will be disposed.

## Custom Scopes
The DDI package provides a flexible architecture that allows you to create custom scopes by extending the `DDIBaseFactory` abstract class. This enables you to implement specialized lifecycle management strategies tailored to your specific application needs.

### Creating Custom Scopes

To create a custom scope, you need to extend `DDIBaseFactory<BeanT>` and implement the required methods:

```dart
class CustomScopeFactory<BeanT extends Object> extends DDIBaseFactory<BeanT> {...}
```

### Using Custom Scopes

Once you've created a custom scope factory, you can register it using the standard `register` method:

```dart
// Register your custom scope
await ddi.register<MyService>(
  factory: CustomScopeFactory<MyService>(
    builder: MyService.new.builder,
    canDestroy: true,
    decorators: [(instance) => ModifiedService(instance)],
    interceptors: {MyInterceptor()},
  ),
);

// Retrieve the instance
final service = ddi.get<MyService>();
```

## Zone Management

Run in a new Zone, making possible to register specific instances in a different context.

**Important:** To use Zone support, you must create a new DDI instance with `enableZoneRegistry: true`. The default `DDI.instance` does not support Zone.

```dart
// Create a new DDI instance with Zone support
final ddi = DDI.newInstance(enableZoneRegistry: true);

T runInZone<T>(String name, T Function() body);
```

This method creates a new Dart Zone with its own isolated registry of beans. This allows you to register and manage instances in a separate context without affecting the global DDI container. When the zone completes, all registered instances in that zone are automatically destroyed.

**Use cases:**
- Testing scenarios where you need isolated instances
- Temporary registrations that shouldn't persist
- Scoped dependency injection for specific operations
- Avoiding conflicts between different parts of the application

Example:
```dart
// Create a DDI instance with Zone support
final ddi = DDI.newInstance(enableZoneRegistry: true);

final result = ddi.runInZone('test-zone', () {
  // Register instances specific to this zone
  ddi.registerSingleton<TestService>(TestService.new);

  // Use the zone-specific instance
  final service = ddi.get<TestService>();
  return service.process();
});
// Zone instances are automatically destroyed here
```

## Common Considerations:
**Unique Registration**: Ensure that the instance to be registered is unique for a specific type or use qualifiers to enable the registration of multiple instances of the same type.

**Memory Management**: Be aware of memory implications for long-lived objects, especially in the Singleton and Object scopes.

**Nested Instances**: Avoid unintentional coupling by carefully managing instances within larger-scoped objects.

**const and Modifiers**: Take into account the impact of const and other class modifiers on the behavior of instances within different scopes.

# Instance Wrapper

The `Instance<BeanT>` wrapper provides a programmatic way to access beans. It allows you to check if a bean is resolvable, get instances, and destroy them programmatically.

## Instance Wrapper Overview

The `Instance` wrapper is obtained using the `getInstance` method and provides the following capabilities:

- **`isResolvable()`**: Checks if the bean is registered and can be retrieved.
- **`get<ParameterT>({ParameterT? parameter})`**: Gets the bean instance synchronously, optionally with parameters.
- **`getAsync<ParameterT>({ParameterT? parameter})`**: Gets the bean instance asynchronously, optionally with parameters.
- **`destroy()`**: Destroys the bean instance if it exists and can be destroyed.
- **`dispose()`**: Disposes of the bean instance if it exists.

#### Basic Usage Example

```dart
// Register a service
ddi.dependent<MyService>(MyService.new);

// Get an Instance wrapper
final instance = ddi.getInstance<MyService>();

// Check if resolvable
if (instance.isResolvable()) {
  // Get the service instance
  final service = instance.get();
  service.doSomething();
  
  // Destroy when done
  await instance.destroy();
}
```

#### Example with Qualifier

```dart
// Register multiple instances with qualifiers
ddi.dependent<MyService>(MyService.new, qualifier: 'service1');
ddi.dependent<MyService>(MyService.new, qualifier: 'service2');

// Get Instance wrapper for specific qualifier
final instance1 = ddi.getInstance<MyService>(qualifier: 'service1');
final instance2 = ddi.getInstance<MyService>(qualifier: 'service2');

final service1 = instance1.get();
final service2 = instance2.get();
```

## Instance Cache and Weak Reference

The `Instance` wrapper supports two optional parameters that control how instances are stored and managed:

- **`cache`**: If `true`, maintains a strong reference to the instance (caching). This prevents the instance from being garbage collected while the Instance wrapper exists.
- **`useWeakReference`**: If `true`, maintains a weak reference to the instance. This allows the instance to be garbage collected if no other strong references exist.

**Important:** If both `useWeakReference` and `cache` are `true`, `cache` takes precedence (strong reference is maintained).

**⚠️ Memory Management Warning:** When using `cache: true`, the `Instance` wrapper maintains a strong reference to the cached instance, which can lead to memory leaks if not properly managed. Always call `destroy()` or `dispose()` on the `Instance` wrapper when you're done using it to release the cached instance and prevent memory leaks.

#### Example with Cache

```dart
// Register a service
ddi.dependent<MyService>(MyService.new);

// Get Instance wrapper with cache enabled
final instance = ddi.getInstance<MyService>(cache: true);

// First get - instance is created and cached
final service1 = instance.get();

// Second get - returns cached instance (same reference)
final service2 = instance.get();
expect(service1, same(service2)); // true

// Important: Always destroy the Instance wrapper when done to prevent memory leaks
await instance.destroy();
```

#### Example with Weak Reference

```dart
// Register a service
ddi.dependent<MyService>(MyService.new);

// Get Instance wrapper with weak reference
final instance = ddi.getInstance<MyService>(useWeakReference: true);

// Get instance - stored as weak reference
final service1 = instance.get();

// If no other strong references exist, instance may be GC collected
// Next get will recreate the instance if it was collected
final service2 = instance.get();
```

#### Example: Converting WeakReference to Strong Reference

```dart
// Register ApplicationScope with WeakReference
ddi.application<MyService>(
  MyService.new,
  useWeakReference: true,
);

// Get Instance wrapper with cache = true
// This converts the WeakReference to a Strong reference
final instance = ddi.getInstance<MyService>(cache: true);

// Instance maintains strong reference, preventing GC
final service1 = instance.get();
final service2 = instance.get();
expect(service1, same(service2)); // true
```

## Instance Interceptor and Decorator Behavior

The `Instance` wrapper interacts with interceptors and decorators in a specific way:

### When `Instance.cache = true` or `Instance.useWeakReference = true`:

- **Interceptors `onGet`**: Called only once (when instance is first retrieved and cached/stored).
- **Decorators**: Applied only once (during instance creation).

### When `ApplicationScope.useWeakReference = true` (without Instance cache):

- **Interceptors `onGet`**: Called every time.
- **Decorators**: Applied during instance creation and everytime the GC collect the instance.

### Example with Interceptors

```dart
// Register interceptor
ddi.singleton<TrackingInterceptor>(TrackingInterceptor.new);

// Register service with interceptor
ddi.application<MyService>(
  MyService.new,
  interceptors: {TrackingInterceptor},
);

// Get Instance wrapper with cache
final instance = ddi.getInstance<MyService>(cache: true);

// First get - interceptor.onGet is called once
final service1 = instance.get();

// Second get - interceptor.onGet is NOT called again (instance is cached)
final service2 = instance.get();

final interceptor = ddi.get<TrackingInterceptor>();
expect(interceptor.getCallCount, equals(1)); // Only called once
```

## Instance Use Cases

### Lazy Initialization

```dart
// Get Instance wrapper without creating the service yet
final instance = ddi.getInstance<MyService>();

// Service is created only when get() is called
if (someCondition) {
  final service = instance.get();
  service.doSomething();
}
```

### Conditional Usage

```dart
final instance = ddi.getInstance<MyService>();

// Check if service is available before using
if (instance.isResolvable()) {
  final service = instance.get();
  service.doSomething();
} else {
  // Handle case when service is not registered
  print('Service not available');
}
```

### Programmatic Lifecycle Management

```dart
final instance = ddi.getInstance<MyService>();

// Use the service
final service = instance.get();
service.doSomething();

// Dispose when done
await instance.dispose();

// Or destroy completely
await instance.destroy();
```

**⚠️ Important:** If you used `cache: true` when creating the `Instance` wrapper, it's especially important to call `destroy()` or `dispose()` to release the cached instance and prevent memory leaks.

### Working with Parameters

```dart
// Register service that accepts parameters
ddi.dependent<MyService>(
  (String config) => MyService(config),
);

// Get Instance wrapper
final instance = ddi.getInstance<MyService>();

// Get instance with parameter
final service1 = instance.get(parameter: 'config1');
final service2 = instance.get(parameter: 'config2');
// Different parameters create different instances
expect(service1, isNot(same(service2))); // true

// With cache, only the first retrieved instance is cached
// ⚠️ Important: Cache does NOT differentiate between parameters
// The cached instance will ALWAYS be returned, regardless of parameters
final instanceWithCache = ddi.getInstance<MyService>(cache: true);
final service3 = instanceWithCache.get(parameter: 'config1');
// service3 is now cached (created with 'config1')

// If you use the same parameter again, returns the cached instance
final service4 = instanceWithCache.get(parameter: 'config1');
expect(service3, same(service4)); // true - same cached instance

// ⚠️ Even if you use a different parameter, it STILL returns the cached instance
// The parameter is IGNORED when cache is enabled and an instance is already cached
final service5 = instanceWithCache.get(parameter: 'config2');
// service5 is the SAME instance as service3 (cached instance, parameter ignored)
expect(service3, same(service5)); // true - same cached instance
expect(service4, same(service5)); // true - same cached instance

// The cached instance (created with 'config1') is always returned
// regardless of what parameter you pass
final service6 = instanceWithCache.get(parameter: 'config2');
expect(service5, same(service6)); // true - same cached instance
expect(service3, same(service6)); // true - same cached instance
```

# Factories

Encapsulate the instantiation logic, providing a better way to define how and when objects are created. They use a builder function to manage the creation process, providing flexibility and control over the instances.

## How Factories Work

When you register a factory, you provide a builder function that defines how the instance will be constructed. This builder can take parameters, enabling the factory to customize the creation process based on the specific needs of the application. Depending on the specified scope (e.g., singleton or application), the factory can either create a new instance each time it is requested or return the same instance for subsequent requests.

#### Example Registration

```dart
MyService.new.builder.asApplication();
```

In this example:

* `MyService.new.` is the default constructor of the class (e.g., `() => MyService()`). 
* `.builder` defines the parameters for the instance of `MyService`.
* `.asApplication()` defines the scope of the factory to create a new instance of `MyService` and register the factory in the `dart_ddi` system.

## Use Cases for Factories

#### Asynchronous Creation
Factories support asynchronous creation, which is useful when initialization requires asynchronous tasks, such as data fetching.

```dart
DDI.instance.register(
  factory: ApplicationFactory<MyApiService>(
    builder: () async {
      final data = await getApiData();
      return MyApiService(data);
    }.builder,
  ),
);
```

### Custom Parameters
Factories can define parameters for builders, allowing for more flexible object creation based on runtime conditions. This also enables automatic injection of `Beans` into factories.

```dart
// Registering the factory
DDI.instance.register(
  factory: ApplicationFactory(
    builder: (RecordParameter parameter) { 
      return ServiceWithParameter(parameter);
    }.builder,
  ),
);

DDI.instance.register(
  factory: ApplicationFactory(
    builder: (MyDatabase database, UserService userService) {
      return ServiceAutoInject(database, userService);
    }.builder,
  ),
);

// Retrieving the instances
ddi.getWith<ServiceWithParameter, RecordParameter>(parameter: parameter);
ddi.get<ServiceAutoInject>();
```
## Considerations

**Singleton Scope**: The Singleton Scope can only be created with auto-inject. If you attempt to create a singleton with custom objects, a `BeanNotFoundException` will be thrown.

**Super-types or Interfaces**: You cannot use the shortcut builder (`MyService.new.builder.asApplication()`) with super-types or interfaces. This limitation exists because the builder function only recognizes the implementation class, not the super-type or interface.

**Decorators and Interceptors**: It is highly recommended to register the factory using `factory: CustomFactory(...)`. This approach handles type inference more effectively.

**Lazy vs. Eager Injection**: Eager Injection occurs when you inject beans using auto-inject functionality or manually via constructors. For lazy injection, you can use the `DDIInject` mixin or define the variable as `late` (e.g., `late final ServiceAutoInject serviceAutoInject = ddi.get()`).

# Qualifiers

Qualifiers are used to differentiate instances of the same type, enabling you to identify and retrieve specific instances. In scenarios where multiple instances coexist, qualifiers serve as optional labels or identifiers associated with the registration and retrieval of instances.

## How Qualifiers Work
When registering an instance, you can provide a qualifier as part of the registration process. This qualifier acts as metadata associated with the instance and can later be used during retrieval to specify which instance is needed.

#### Example Registration with Qualifier

```dart
ddi.registerSingleton<MyService>(MyService.new, qualifier: "specialInstance");
```

## Retrieval with Qualifiers
During retrieval, if multiple instances of the same type exist, you can use the associated qualifier to specify the desired instance. But remember, if you register using a qualifier, you should retrieve with a qualifier.

####  Example Retrieval with Qualifier

```dart
MyService specialInstance = ddi.get<MyService>(qualifier: "specialInstance");
```
## Use Cases for Qualifiers

#### Configuration Variations

When there are multiple configurations for a service, such as different API endpoints or connection settings.
```dart
ddi.registerSingleton<ApiService>(() => ApiService("endpointA"), qualifier: "endpointA");
ddi.registerSingleton<ApiService>(() => ApiService("endpointB"), qualifier: "endpointB");
```

#### Feature Flags

When different instances are required based on feature flags or runtime conditions.
```dart
ddi.registerSingleton<FeatureService>(() => FeatureService(enabled: true), qualifier: "enabled");
ddi.registerSingleton<FeatureService>(() => FeatureService(enabled: false), qualifier: "disabled");
```

#### Platform-Specific Implementations

In scenarios where platform-specific implementations are required, such as different services for Android and iOS, qualifiers can be employed to distinguish between the platform-specific instances.

```dart
ddi.registerSingleton<PlatformService>(AndroidService.new, qualifier: "android");
ddi.registerSingleton<PlatformService>(iOSService.new, qualifier: "ios");
```

## Considerations

**Consistent Usage**: Maintain consistent usage of qualifiers throughout the codebase to ensure clarity and avoid confusion.

**Avoid Overuse**: While qualifiers offer powerful customization, avoid overusing them to keep the codebase clean and maintainable.

**Type Identifiers**: Qualifiers are often implemented using string-based identifiers, which may introduce issues such as typos or potential naming conflicts. To mitigate these concerns, it is highly recommended to utilize enums or constants.

# Extra Customization
The DDI package provides features for customizing the lifecycle of registered instances. These features include `decorators`, `interceptor`, `canRegister` and `canDestroy`.


## Decorators
Decorators provide a way to modify or enhance the behavior of an instance before it is returned. Each decorator is a function that takes the existing instance and returns a modified instance. Multiple decorators can be applied, and they are executed in the order they are specified during registration.

#### Example Usage:
```dart

class ModifiedMyService extends MyService {
  ModifiedMyService(MyService instance) {
    super.value = instance.value.toUpperCase();
  }
}

ddi.registerSingleton<MyService>(
  MyService.new,
  decorators: [
    (existingInstance) => ModifiedMyService(existingInstance),
    // Additional decorators can be added as needed.
  ],
);
```

## Interceptor
The Interceptor provides control over the instantiation, retrieval, destruction, and disposal of instances managed by the DDI package. By creating a custom class that extends `DDIInterceptor`, you can inject custom logic at various stages of the instance's lifecycle.

## Interceptor Methods

### onCreate
- Invoked after instance creation and before Decorators and PostConstruct mixin.
- Execute custom logic, Customize or replace the instance by returning a modified instance.

### onGet
- Invoked when retrieving an instance.
- Customize the behavior of the retrieved instance before it is returned.
- If you change any value, the next time you get this instance, it will be applied again. Be aware that this can lead to unexpected behavior.

### onDestroy
- Invoked when an instance is being destroyed.
- Allows customization of the instance destruction process.

### onDispose
- Invoked during the disposal of an instance.
- Provides an opportunity for customization before releasing resources or performing cleanup.

#### Example Usage

 ```dart
 class CustomInterceptor<BeanT> extends DDIInterceptor<BeanT> {
   @override
   BeanT onCreate(BeanT instance) {
     // Logic to customize or replace instance creation.
     return CustomizedInstance();
   }

   @override
   BeanT onGet(BeanT instance) {
     // Logic to customize the behavior of the retrieved instance.
     return ModifiedInstance(instance);
   }

   @override
   void onDestroy(BeanT instance) {
     // Logic to perform cleanup during instance destruction.
     // This method is optional and can be overridden as needed.
   }

   @override
   void onDispose(BeanT instance) {
     // Logic to release resources or perform custom cleanup during instance disposal.
     // This method is optional and can be overridden as needed.
   }
 }
 ```

## CanRegister
The canRegister parameter is a boolean function that determines whether an instance should be registered. It provides conditional registration based on a specified condition. This is particularly useful for ensuring that only a single instance is registered, preventing issues with duplicated instances.

#### Example Usage:
```dart
ddi.registerSingleton<MyService>(
  MyServiceAndroid.new,
  canRegister: () {
    return Platform.isAndroid && MyUserService.isAdmin();
  },
);
ddi.registerSingleton<MyService>(
  MyServiceIos.new,
  canRegister: () {
    return Platform.isIOS && MyUserService.isAdmin();
  },
);
ddi.registerSingleton<MyService>(
  MyServiceDefault.new,
  canRegister: () {
    return !MyUserService.isAdmin();
  },
);
```

## CanDestroy 
The canDestroy parameter, is optional and can be set to false if you want to make the registered instance indestructible. When set to false, the instance cannot be removed using the `destroy` or `destroyByType` methods.

#### Example Usage:
```dart
// Register an Application instance that is indestructible
ddi.registerApplication<MyService>(
  MyService.new,
  canDestroy: false,
);
```

## Selector
The `selector` parameter allows for conditional selection when retrieving an instance, providing a way to determine which instance should be used based on specific criteria. The first instance that matches `true` will be selected; if no instance matches, a `BeanNotFoundException` will be thrown. The selector requires registration with an interface type, making it particularly useful in scenarios where multiple instances of the same type are registered, but only one needs to be chosen dynamically at runtime based on context.

#### Example Usage:
```dart
void main() {

   // Registering CreditCardPaymentService with a selector condition
  ddi.registerApplication<PaymentService>(
    CreditCardPaymentService.new,
    qualifier: 'creditCard',
    selector: (paymentMethod) => paymentMethod == 'creditCard',
  );

  // Registering PayPalPaymentService with a selector condition
  ddi.registerApplication<PaymentService>(
    PayPalPaymentService.new,
    qualifier: 'paypal',
    selector: (paymentMethod) => paymentMethod == 'paypal',
  );

  // Runtime value to determine the payment method
  const selectedPaymentMethod = 'paypal'; // Could also be 'creditCard'

  // Retrieve the appropriate PaymentService based on the selector condition
  late final paymentService = ddi.get<PaymentService>(
    select: selectedPaymentMethod,
  );

  // Process a payment with the selected service
  paymentService.processPayment(100.0);
}
```

## Required Dependencies
The `required` parameter allows you to explicitly declare which qualifiers or types must be registered before an instance can be created. This ensures that all necessary dependencies are available and ready before the factory attempts to create an instance.

**Behavior:**
- **Singleton/Object**: Validation occurs during `register()`. If a dependency is not ready, it will be created automatically.
- **Application/Dependent**: Validation occurs during `getWith()` or `getAsyncWith()`. For Application scope, dependencies are created if not ready.
- If a required dependency is not registered, a `MissingDependenciesException` will be thrown.

#### Example Usage:
```dart
// Register dependencies first
ddi.singleton<Database>(Database.new);
ddi.application<Logger>(Logger.new);

// Register a service that requires Database and Logger
ddi.application<MyService>(
  MyService.new,
  required: {Database, Logger},
);

// MyService will only be created after Database and Logger are ready
final service = ddi.get<MyService>();
```

## Modules

Modules offer a convenient way to modularize and organize dependency injection configuration in your application. Through the use of the `addChildModules` and `addChildrenModules` methods, you can add and configure specific modules, grouping related dependencies and facilitating management of your dependency injection container.

When you execute `dispose` or `destroy` for a module, they will be executed for all its children.

### Adding a Class

To add a single class to a module to your dependency injection container, you can use the `addChildModules` method.

- `child`: This refers to the type or qualifier of the subclasses that will be part of the module. Note that these are not instances, but rather types or qualifiers.
- `qualifier` (optional): This parameter refers to the main class type of the module. It is optional and is used as a qualifier if needed.

```dart
// Adding a single module with an optional specific qualifier.
ddi.addChildModules<MyModule>(
  child: MySubmoduleType, 
  qualifier: 'MyModule',
);
```

### Adding Multiple Classes
To add multiple classes to a module at once, you can utilize the `addChildrenModules` method.

- `child`: This refers to the type or qualifier of the subclasses that will be part of the module. Note that these are not instances, but rather types or qualifiers.
- `qualifier` (optional): This parameter refers to the main class type of the module. It is optional and is used as a qualifier if needed.

```dart
// Adding multiple modules at once.
ddi.addChildrenModules<MyModule>(
  child: [MySubmoduleType1, MySubmoduleType2], 
  qualifier: 'MyModule',
);
```
With these methods, you can modularize your dependency injection configuration, which can be especially useful in larger applications with complex instance management requirements.

### Register With Children Parameter

The `children` parameter is designed to receive types or qualifiers. This parameter allows you to register multiple classes under a single parent module.

```dart
// Adding multiple modules at once.
ddi.registerApplication<ParentModule>(
  () => ParentModule(),
  children: [
    ChildModule,
    OtherModule,
    'ChildModuleQualifier',
    'OtherModuleQualifier'
  ],
);
```

## Mixins

### Post Construct Mixin

The `PostConstruct` mixin has been added to provide the ability to execute specific rules after the construction of an instance of the class using it. Its primary purpose is to offer an extension point for additional logic that needs to be executed immediately after an object is created.

By including the PostConstruct mixin in a class and implementing the `onPostConstruct()` method, you can ensure that this custom logic is automatically executed right after the instantiation of the class.

#### Example Usage:
```dart
class MyClass with PostConstruct {
  final String name;

  MyClass(this.name);

  @override
  void onPostConstruct() {
    // Custom logic to be executed after construction.
    print('Instance of MyClass has been successfully constructed.');
    print('Name: $_name');
  }
}
```

### Pre Destroy Mixin

The `PreDestroy` mixin has been created to provide a mechanism for executing specific actions just before an object is destroyed. This mixin serves as a counterpart to the PostConstruct mixin, allowing to define custom cleanup logic that needs to be performed before an object's lifecycle ends.

#### Example Usage:
```dart
class MyClassName with PreDestroy {
  final String name;

  MyClassName(this.name);

  @override
  void onPreDestroy() {
    // Custom cleanup logic to be executed before destruction.
    print('Instance of MyClassName is about to be destroyed.');
    print('Performing cleanup for $name');
  }
}

void main() {
  // Registering an instance of MyClassName
  ddi.registerSingleton<MyClassName>(
     () => MyClassName('DDI Example'),
  );
  
  // Destroying the instance (removing it from the container).
  ddi.remove<MyClassName>();
  
  // Output:
  // Instance of MyClassName is about to be destroyed.
  // Performing cleanup for DDI Example
}
```

### Pre Dispose Mixin

The `PreDispose` mixin extends the lifecycle management capabilities, allowing custom logic to be executed before an instance is disposed.

#### Example Usage:
```dart
class MyClass with PreDispose {
  final String name;

  MyClass(this.name);

  @override
  void onPreDispose() {
    // Custom cleanup logic to be executed before disposal.
    print('Instance of MyClass is about to be disposed.');
    print('Performing cleanup for $name');
  }
}
```

### DDIModule Mixin

The `DDIModule` mixin provides a convenient way to organize and manage your dependency injection configuration within your Dart application. By implementing this mixin in your module classes, you can easily register instances with different scopes and dependencies using the provided methods.

#### Example Usage:

```dart
// Define a module using the DDIModule mixin

class AppModule with DDIModule {
  @override
  void onPostConstruct() {
    // Registering instances with different scopes
    singleton(() => Database('main_database'), qualifier: 'mainDatabase');
    application(() => Logger(), qualifier: 'appLogger');
    object('https://api.example.com', qualifier: 'apiUrl');
    
    // Register a service with required dependencies
    application(
      () => ApiService(ddi.get(qualifier: 'apiUrl')),
      qualifier: 'apiService',
      required: {'mainDatabase', 'appLogger'},
    );
    
    dependent(() => TransientService(), qualifier: 'transientService');
  }
}
```

### `DDIInject`, `DDIInjectAsync` and `DDIComponentInject` Mixins

The `DDIInject`, `DDIInjectAsync` and `DDIComponentInject` mixins are designed to facilitate dependency injection of an instance into your classes. They provide a convenient method to obtain an instance of a specific type from the dependency injection container.

The `DDIInject` mixin allows for synchronous injection of an instance and `DDIInjectAsync` mixin allows for asynchronous injection. Both define an `instance` property that will be initialized with the `InjectType` instance obtained.

The `DDIComponentInject` allows injecting a specific instance using a module as a selector.

#### Example Usage:
```dart
class MyController with DDIInject<MyService> {
  void businessLogic() {
    instance.runSomething();
  }
}

class MyAsyncController with DDIInjectAsync<MyService> {
  Future<void> businessLogic() async {
    final myInstance = await instance;
    myInstance.runSomething();
  }
}

class MyController with DDIComponentInject<MyComponent, MyModule> {

  void businessLogic() {
    instance.runSomething();
  }
}
```	