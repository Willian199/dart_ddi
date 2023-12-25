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

# Dart Dependency Injection (DDI) Library

## Overview

The Dart Dependency Injection (DDI) library is a robust and flexible dependency injection mechanism inspired by the Contexts and Dependency Injection (CDI) framework in Java and by Get_It dart package. DDI facilitates the management of object instances and their lifecycles by introducing different scopes and customization options. This documentation aims to provide an in-depth understanding of DDI's core concepts, usage, and features.

🚀 Contribute to the DDI by sharing your ideas, feedback, or practical examples.

Summary

1. [Getting Started](#getting-started)
2. [Core Concepts](#core-concepts)
   1. [Singleton](#singleton)
   2. [Application](#application)
   3. [Session](#session)
   4. [Dependent](#dependent)
   5. [Common Considerations](#common-considerations)
3. [Qualifiers](#qualifiers)
   1. [How Qualifiers Work](#how-qualifiers-work)
   2. [Use Cases for Qualifiers](#use-cases-for-qualifiers)
   3. [Considerations](#considerations)
4. [Extra Customization](#extra-customization)
   1. [PostConstruct](#postconstruct)
   2. [Decorators](#decorators)
   3. [Interceptor](#interceptor)
   4. [RegisterIf](#registerif)
   5. [DDIContext Extension](#ddicontext-extension)
5. [API Reference](#api-reference)
   1. [registerSingleton](#registersingleton)
   2. [registerApplication](#registerapplication)
   3. [registerDependent](#registerdependent)
   4. [registerSession](#registersession)
   5. [get](#get)
   6. [getByType](#getbytype)
   7. [call](#call)
   8. [destroy](#destroy)
   9. [destroyByType](#destroybytype)
   10. [dispose](#dispose)
   11. [disposeByType](#disposebytype)
   12. [addDecorator](#adddecorator)
   13. [addInterceptor](#addInterceptor)

## Getting Started

To incorporate DDI into your Dart project, you must implement the `DDI` abstract class. The default implementation, can be accessed through the `instance` getter.

```dart
// Instantiate DDI
DDI ddi = DDI.instance;

// Register a singleton instance
ddi.registerSingleton<MyService>(() => MyService());

// Retrieve the singleton instance
MyService myService = ddi.get<MyService>();

// Register an application-scoped instance
ddi.registerApplication<MyAppService>(() => MyAppService());

// Retrieve the application-scoped instance
MyAppService appService = ddi.get<MyAppService>();

// ... (similar usage for other scopes)
```

# Core Concepts
## Scopes

The Dart Dependency Injection (DDI) Library supports various scopes for efficient management of object instances. Each scope determines how instances are created, reused, and destroyed throughout the application lifecycle. Below are detailed characteristics of each scope, along with recommendations, use cases, and considerations for potential issues.

## Singleton
`Description`: This scope creates a single instance during registration and reuses it in all subsequent requests.

`Recommendation`: Suitable for objects that need to be globally shared across the application, maintaining a single instance.

`Use Case`: Sharing a configuration manager, a logging service, or a global state manager.
        

## Application
`Description`: Generates an instance when first used and reuses it for all subsequent requests during the application's execution.

`Recommendation`: Indicated for objects that need to be created only once per application and shared across different parts of the code.

`Use Case`: Managing application-level resources, such as a network client or a global configuration.

## Session
`Description`: Ties an instance to a specific session, persisting throughout the session's lifespan.

`Recommendation`: Suitable for objects that need to be retained while a session is active, such as user-specific data or state.

`Use Case`: Managing user authentication state or caching user-specific preferences.

## Dependent
`Description`: Produces a new instance every time it is requested, ensuring independence and uniqueness.

`Recommendation`: Useful for objects that should remain independent and different in each context or request.

`Use Case`: Creating instances of transient objects like data repositories or request handlers.

## Common Considerations:
`Single Registration`: Ensure that the instance to be registered is unique for a specific type or use qualifiers to enable the registration of multiple instances of the same type.

`Memory Management`: Be aware of memory implications for long-lived objects, especially in the Singleton and Application scopes.

`Nested Instances`: Avoid unintentional coupling by carefully managing instances within larger-scoped objects.

`const and Modifiers`: Take into account the impact of const and other class modifiers on the behavior of instances within different scopes.

# Qualifiers

Qualifiers play a crucial role in the DDI Library by differentiating between instances of the same type, enabling to uniquely identify and retrieve specific instances within a given scope. In scenarios where multiple instances coexist within a single scope, qualifiers serve as optional labels or identifiers associated with the registration and retrieval of instances, ensuring precision in managing dependencies.

## How Qualifiers Work
When registering an instance, can provide a qualifierName as part of the registration process. This qualifier acts as metadata associated with the instance and can later be used during retrieval to specify which instance is needed.

#### Example Registration with Qualifier

```dart
ddi.registerSingleton<MyService>(() => MyService(), qualifierName: "specialInstance");
```

## Retrieval with Qualifiers
During retrieval, if multiple instances of the same type exist, can use the associated qualifier to specify the desired instance. But remember, if you register using qualifier, should retrieve with qualifier.

####  Example Retrieval with Qualifier

```dart
MyService specialInstance = ddi.get<MyService>(qualifierName: "specialInstance");
```
## Use Cases for Qualifiers

#### Configuration Variations

When there are multiple configurations for a service, such as different API endpoints or connection settings.
```dart
ddi.registerSingleton<ApiService>(() => ApiService("endpointA"), qualifierName: "endpointA");
ddi.registerSingleton<ApiService>(() => ApiService("endpointB"), qualifierName: "endpointB");
```

#### Feature Flags

When different instances are required based on feature flags or runtime conditions.
```dart
ddi.registerSingleton<FeatureService>(() => FeatureService(enabled: true), qualifierName: "enabled");
ddi.registerSingleton<FeatureService>(() => FeatureService(enabled: false), qualifierName: "disabled");
```

#### Platform-Specific Implementations

In scenarios where platform-specific implementations are required, such as different services for Android and iOS, qualifiers can be employed to distinguish between the platform-specific instances.

```dart
ddi.registerSingleton<PlatformService>(() => AndroidService(), qualifierName: "android");
ddi.registerSingleton<PlatformService>(() => iOSService(), qualifierName: "ios");
```

## Considerations

`Consistent Usage:` Maintain consistent usage of qualifiers throughout the codebase to ensure clarity and avoid confusion.

`Avoid Overuse:` While qualifiers offer powerful customization, avoid overusing them to keep the codebase clean and maintainable.

`Type Identifiers:` Qualifiers are often implemented using string-based identifiers, which may introduce issues such as typos or potential naming conflicts. To mitigate these concerns, it is highly recommended to utilize enums or constants.

# Extra Customization
The DDI Library provides features for customizing the lifecycle of registered instances. These features include `postConstruct`, `decorators`, `interceptor` and `registerIf`.

## PostConstruct
The postConstruct callback allows to perform additional setup or initialization after an instance is created. This is particularly useful for executing logic that should run once the instance is ready for use.

#### Example Usage:
```dart
ddi.registerSingleton<MyService>(
  () => MyService(),
  postConstruct: () {
    // Additional setup logic after MyService instance creation.
    print("MyService instance is ready!");
  },
);
```

## Decorators
Decorators provide a way to modify or enhance the behavior of an instance before it is returned. Each decorator is a function that takes the existing instance and returns a modified instance. Multiple decorators can be applied, and they are executed in the order they are specified during registration.

#### Example Usage:
```dart

class ModifiedMyService extends MyService {
  ModifiedMyService(MyService instance) {
    super.value = 'new value';
  }
}

ddi.registerSingleton<MyService>(
  () => MyService(),
  decorators: [
    (existingInstance) => ModifiedMyService(existingInstance),
    // Additional decorators can be added as needed.
  ],
);
```

## Interceptor
The Interceptor is a powerful mechanism that provides fine-grained control over the instantiation, retrieval, destruction, and disposal of instances managed by the DDI Library. By creating a custom class that extends `DDIInterceptor`, you can inject custom logic at various stages of the instance's lifecycle.

## Interceptor Methods

### aroundConstruct
- Invoked during the instance creation process.
- Customize or replace the instance creation logic by returning a modified instance.

### aroundGet
- Invoked when retrieving an instance.
- Customize the behavior of the retrieved instance before it is returned.
- If you change any value, the next time you get this instance, it will be applied again. Be aware that this can lead to unexpected behavior.

### aroundDestroy
- Invoked when an instance is being destroyed.
- Allows customization of the instance destruction process.

### aroundDispose
- Invoked during the disposal of an instance.
- Provides an opportunity for customization before releasing resources or performing cleanup.

#### Example Usage

 ```dart
 class CustomInterceptor<T> extends DDIInterceptor<T> {
   @override
   T aroundConstruct(T instance) {
     // Logic to customize or replace instance creation.
     return CustomizedInstance();
   }

   @override
   T aroundGet(T instance) {
     // Logic to customize the behavior of the retrieved instance.
     return ModifiedInstance(instance);
   }

   @override
   void aroundDestroy(T instance) {
     // Logic to perform cleanup during instance destruction.
     // This method is optional and can be overridden as needed.
   }

   @override
   void aroundDispose(T instance) {
     // Logic to release resources or perform custom cleanup during instance disposal.
     // This method is optional and can be overridden as needed.
   }
 }
 ```

## RegisterIf
The registerIf parameter is a boolean function that determines whether an instance should be registered. It provides conditional registration based on a specified condition. This is particularly useful for ensuring that only a single instance is registered, preventing issues with duplicated instances.

#### Example Usage:
```dart
ddi.registerSingleton<MyService>(
  () => MyServiceAndroid(),
  registerIf: () {
    return Platform.isAndroid && MyUserService.isAdmin();
  },
);
ddi.registerSingleton<MyService>(
  () => MyServiceIos(),
  registerIf: () {
    return Platform.isIOS && MyUserService.isAdmin();
  },
);
ddi.registerSingleton<MyService>(
  () => MyServiceDefault(),
  registerIf: () {
    return !MyUserService.isAdmin();
  },
);
```

## DDIContext Extension

The `DDIContext` extension simplifies dependency injection access within the context of a Flutter widget. It provides a convenient method for retrieving instances directly in your widget's build context.

```dart
// Retrieve an instance of MyService from DDI with a specific qualifier
MyService myService = context.ddi<MyService>(qualifierName: 'customQualifier');
```

# API Reference

## registerSingleton

Registers a singleton instance. The `clazzRegister` parameter is a factory function to create the instance. Optional parameters allow customization of the instance's behavior and lifecycle.

```dart
void registerSingleton<T extends Object>(
  T Function() clazzRegister, {
  Object? qualifierName,
  void Function()? postConstruct,
  List<T Function(T)>? decorators,
  List<DDIInterceptor<T> Function()>? interceptors,
  bool Function()? registerIf,
});
```

## registerApplication<T>

Registers an application-scoped instance. The instance is created when first used and reused afterward.

```dart
void registerApplication<T extends Object>(
  T Function() clazzRegister, {
  Object? qualifierName,
  void Function()? postConstruct,
  List<T Function(T)>? decorators,
  List<DDIInterceptor<T> Function()>? interceptors,
  bool Function()? registerIf,
});
```

## registerDependent

Registers a dependent instance. A new instance is created every time it is used.

```dart
void registerDependent<T extends Object>(
  T Function() clazzRegister, {
  Object? qualifierName,
  void Function()? postConstruct,
  List<T Function(T)>? decorators,
  List<DDIInterceptor<T> Function()>? interceptors,
  bool Function()? registerIf,
});
```

## registerSession

Registers a session-scoped instance. The instance is tied to a specific session.

```dart
void registerSession<T extends Object>(
  T Function() clazzRegister, {
  Object? qualifierName,
  void Function()? postConstruct,
  List<T Function(T)>? decorators,
  List<DDIInterceptor<T> Function()>? interceptors,
  bool Function()? registerIf,
});
```

## get

Retrieves an instance of type T from the appropriate scope. You can provide a `qualifierName` to distinguish between instances of the same type.

```dart
T get<T extends Object>({Object? qualifierName});
```

## getByType

Retrieves all instance identifiers of type T from each scope.

```dart
List<Object> getByType<T extends Object>();
```

## call

A shorthand for get<T>(), allowing a more concise syntax for obtaining instances.

```dart
T call<T extends Object>();
```

## destroy

Destroy an instance from the container. Useful for manual cleanup.

```dart
void destroy<T>({Object? qualifierName});
```

## destroyByType

Destroy all instance with type `T`.

```dart
void destroyByType<T extends Object>();
```

## dispose

Disposes of an instance, invoking any cleanup logic. This is particularly useful for instances with resources that need to be released. Only applied to Application and Session Scopes

```dart
void dispose<T>({Object? qualifierName});
```

## disposeByType

Disposes all instance with type `T`. Only applied to Application and Session Scopes

```dart
void disposeByType<T extends Object>();
```

## addDecorator

This provides a dynamic way to enhance the behavior of registered instances by adding decorators. The `addDecorator` method allows you to apply additional functionality to instances managed by the library.
When using the addDecorator method, keep in mind the order of execution, scope considerations, and the fact that instances already obtained remain unaffected. 

```dart
void addDecorator<T extends Object>(List<T Function(T)> decorators, {Object? qualifierName});
```

## addInterceptor

This feature allows you to dynamically influence the instantiation, retrieval, destruction, and disposal of instances by adding custom interceptors. The `addInterceptor` method enables you to associate specific interceptors with particular types.
```dart
void addInterceptor<T extends Object>(List<DDIInterceptor<T> Function()> interceptors, {Object? qualifierName});
```

