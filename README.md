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

[![pub package](https://img.shields.io/pub/v/dart_ddi.svg?logo=dart&logoColor=00b9fc)](https://pub.dartlang.org/packages/dart_ddi)
[![CI](https://img.shields.io/github/actions/workflow/status/Willian199/dart_ddi/dart.yml?branch=master&logo=github-actions&logoColor=white)](https://github.com/Willian199/dart_ddi/actions)
[![Last Commits](https://img.shields.io/github/last-commit/Willian199/dart_ddi?logo=git&logoColor=white)](https://github.com/Willian199/dart_ddi/commits/master)
[![Issues](https://img.shields.io/github/issues/Willian199/dart_ddi?logo=github&logoColor=white)](https://github.com/Willian199/dart_ddi/issues)
[![Pull Requests](https://img.shields.io/github/issues-pr/Willian199/dart_ddi?logo=github&logoColor=white)](https://github.com/Willian199/dart_ddi/pulls)
[![Code size](https://img.shields.io/github/languages/code-size/Willian199/dart_ddi?logo=github&logoColor=white)](https://github.com/Willian199/dart_ddi)
[![License](https://img.shields.io/github/license/Willian199/dart_ddi?logo=open-source-initiative&logoColor=green)](https://github.com/Willian199/dart_ddi/blob/master/LICENSE)

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
   5. [Object](#object)
   6. [Common Considerations](#common-considerations)
3. [Qualifiers](#qualifiers)
   1. [How Qualifiers Work](#how-qualifiers-work)
   2. [Use Cases for Qualifiers](#use-cases-for-qualifiers)
   3. [Considerations](#considerations)
4. [Extra Customization](#extra-customization)
   1. [PostConstruct](#postconstruct)
   2. [Decorators](#decorators)
   3. [Interceptor](#interceptor)
   4. [RegisterIf](#registerif)
   5. [Destroyable](#destroyable)
5. [Mixins](#mixins)
   1. [Post Construct](#post-construct-mixin)
   2. [Pre Destroy](#pre-destroy-mixin)
6. [Events](#events)
   1. [Creating and Managing Events](#creating-and-managing-events)
   2. [Subscribing an Event](#subscribing-an-event)
   3. [Unsubscribing an Event](#unsubscribing-an-event)
   4. [Firing an Event](#firing-an-event)
   5. [Events Considerations](#events-considerations)
   6. [Use Cases](#use-cases)
7. [Stream](#stream)
   1. [Subscription](#subscription)
   2. [Closing Stream](#closing-stream)
   3. [Firing Events](#firing-events)
   4. [Retrieving Stream](#retrieving-stream)
9. [API Reference](#api-reference)
   1. [registerSingleton](#registersingleton)
   2. [registerApplication](#registerapplication)
   3. [registerDependent](#registerdependent)
   4. [registerSession](#registersession)
   5. [registerObject](#registerobject)
   6. [get](#get)
   7. [getAsync](#getasync)
   8. [getByType](#getbytype)
   9. [call](#call)
   10. [destroy](#destroy)
   11. [destroyByType](#destroybytype)
   12. [dispose](#dispose)
   13. [disposeByType](#disposebytype)
   14. [addDecorator](#adddecorator)
   15. [addInterceptor](#addinterceptor)
   16. [refreshObject](#refreshobject)

## Getting Started

To incorporate DDI into your Dart project, you must implement the `DDI` abstract class. The default implementation, can be accessed through the `instance` getter.

```dart
// Instantiate DDI
DDI ddi = DDI.instance;

// Register a singleton instance
ddi.registerSingleton<MyService>(MyService.new);

// Retrieve the singleton instance
MyService myService = ddi.get<MyService>();

// Register an application-scoped instance
ddi.registerApplication<MyAppService>(MyAppService.new);

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

## Object
`Description`: Registers an Object in the Object Scope, ensuring it is created once and shared throughout the entire application, functioning similarly to a Singleton.

`Recommendation`: Suitable for objects that are stateless or have shared state across the entire application.

`Use Case`: Application or device properties, like platform or dark mode settings, where the object's state needs to be consistent across the entire application.

## Common Considerations:
`Single Registration`: Ensure that the instance to be registered is unique for a specific type or use qualifiers to enable the registration of multiple instances of the same type.

`Memory Management`: Be aware of memory implications for long-lived objects, especially in the Singleton and Application scopes.

`Nested Instances`: Avoid unintentional coupling by carefully managing instances within larger-scoped objects.

`const and Modifiers`: Take into account the impact of const and other class modifiers on the behavior of instances within different scopes.

# Qualifiers

Qualifiers play a crucial role in the DDI Library by differentiating between instances of the same type, enabling to uniquely identify and retrieve specific instances within a given scope. In scenarios where multiple instances coexist within a single scope, qualifiers serve as optional labels or identifiers associated with the registration and retrieval of instances, ensuring precision in managing dependencies.

## How Qualifiers Work
When registering an instance, can provide a qualifier as part of the registration process. This qualifier acts as metadata associated with the instance and can later be used during retrieval to specify which instance is needed.

#### Example Registration with Qualifier

```dart
ddi.registerSingleton<MyService>(MyService.new, qualifier: "specialInstance");
```

## Retrieval with Qualifiers
During retrieval, if multiple instances of the same type exist, can use the associated qualifier to specify the desired instance. But remember, if you register using qualifier, should retrieve with qualifier.

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

`Consistent Usage:` Maintain consistent usage of qualifiers throughout the codebase to ensure clarity and avoid confusion.

`Avoid Overuse:` While qualifiers offer powerful customization, avoid overusing them to keep the codebase clean and maintainable.

`Type Identifiers:` Qualifiers are often implemented using string-based identifiers, which may introduce issues such as typos or potential naming conflicts. To mitigate these concerns, it is highly recommended to utilize enums or constants.

# Extra Customization
The DDI Library provides features for customizing the lifecycle of registered instances. These features include `postConstruct`, `decorators`, `interceptor`, `registerIf` and `destroyable`.

## PostConstruct
The postConstruct callback allows to perform additional setup or initialization after an instance is created. This is particularly useful for executing logic that should run once the instance is ready for use.

#### Example Usage:
```dart
ddi.registerSingleton<MyService>(
  MyService.new,
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
  MyService.new,
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
 class CustomInterceptor<BeanT> extends DDIInterceptor<BeanT> {
   @override
   BeanT aroundConstruct(BeanT instance) {
     // Logic to customize or replace instance creation.
     return CustomizedInstance();
   }

   @override
   BeanT aroundGet(BeanT instance) {
     // Logic to customize the behavior of the retrieved instance.
     return ModifiedInstance(instance);
   }

   @override
   void aroundDestroy(BeanT instance) {
     // Logic to perform cleanup during instance destruction.
     // This method is optional and can be overridden as needed.
   }

   @override
   void aroundDispose(BeanT instance) {
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
  MyServiceAndroid.new,
  registerIf: () {
    return Platform.isAndroid && MyUserService.isAdmin();
  },
);
ddi.registerSingleton<MyService>(
  MyServiceIos.new,
  registerIf: () {
    return Platform.isIOS && MyUserService.isAdmin();
  },
);
ddi.registerSingleton<MyService>(
  MyServiceDefault.new,
  registerIf: () {
    return !MyUserService.isAdmin();
  },
);
```

## Destroyable 
The destroyable parameter, introduced in various registration methods, is optional and can be set to false if you want to make the registered instance indestructible. When set to false, the instance cannot be removed using the `destroy` or `destroyByType` methods, providing control over the lifecycle and preventing accidental removal.

#### Example Usage:
```dart
// Register an Application instance that is indestructible
ddi.registerApplication<MyService>(
  MyService.new,
  destroyable: false,
);
```

## Mixins

### Post Construct Mixin

The PostConstruct mixin has been added to provide the ability to execute specific rules after the construction of an instance of the class using it. Its primary purpose is to offer an extension point for additional logic that needs to be executed immediately after an object is created.

By including the PostConstruct mixin in a class and implementing the onPostConstruct() method, you can ensure that this custom logic is automatically executed right after the instantiation of the class.

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

The PreDestroy mixin has been created to provide a mechanism for executing specific actions just before an object is destroyed. This mixin serves as a counterpart to the PostConstruct mixin, allowing to define custom cleanup logic that needs to be performed before an object's lifecycle ends.

#### Example Usage:
```dart
class MyClass with PreDestroy {
  final String name;

  MyClass(this.name);

  @override
  void onPreDestroy() {
    // Custom cleanup logic to be executed before destruction.
    print('Instance of MyClass is about to be destroyed.');
    print('Performing cleanup for $name');
  }
}

void main() {
  // Registering an instance of MyClass
  ddi.registerSingleton<MyClass>(
     () => MyClass('Willian'),
  );
  
  // Destroying the instance (removing it from the container).
  ddi.remove<MyClass>();
  
  // Output:
  // Instance of MyClass is about to be destroyed.
  // Performing cleanup for Willian
}
```

# Events
Designed for flexibility and efficiency, this system empowers you to seamlessly manage, subscribe to, and respond to events, making it a crucial asset for building reactive and scalable Dart applications.

## Creating and Managing Events
The Events follow a straightforward flow. Functions or methods `subscribe` to specific events using the subscribe method of the `DDIEvent` class. Events are fired using the `fire` method, triggering the execution of all subscribed callbacks. Subscribed callbacks are then executed, handling the event data and performing any specified tasks. Subscriptions can be removed using the `unsubscribe` function.

### Subscribing an Event
When subscribing to an event, you have the option to choose from three different types of subscriptions:  `subscribe`, `subscribeAsync` and `subscribeIsolate`.

#### subscribe
The common subscription type, subscribe, functions as a simple callback. It allows you to respond to events in a synchronous manner, making it suitable for most scenarios.

- `DDIEvent.instance.subscribe` It's the common type, working as a simples callback.
- `DDIEvent.instance.subscribeAsync` Runs as a Future. Perhaps it's not possible to await.
- `DDIEvent.instance.subscribeIsolate` Runs as a Isolate.

Parameters:

- `event:` The callback function to be executed when the event is fired.
- `qualifier:` Optional qualifier name to distinguish between different events of the same type.
- `registerIf:` A bool function that if returns true, allows the subscription to proceed.
- `allowUnsubscribe:` Indicates if the event can be unsubscribe.
- `priority:` Priority of the subscription relative to other subscriptions (lower values indicate higher priority).
- `unsubscribeAfterFire:` If true, the subscription will be automatically removed after the first time the event is fired.

```dart
void myEvent(String message) {
    print('Event received: $message');
}

DDIEvent.instance.subscribe<String>(
  myEvent,
  qualifier: 'exampleEvent',
  registerIf: () => true,
  allowUnsubscribe: true,
  unsubscribeAfterFire: false,
  runAsIsolate: false,
);
```

#### subscribeAsync
The subscribeAsync type runs the callback as a Future, allowing for asynchronous event handling. Making it suitable for scenarios where asynchronous execution is needed without waiting for completion.
Note that it not be possible to await this type of subscription.

Parameters are the same as for `subscribe`.

```dart
void myEvent(String message) {
    print('Event received: $message');
}

DDIEvent.instance.subscribeAsync<String>(
  myEvent,
  qualifier: 'exampleEvent',
  registerIf: () => true,
  allowUnsubscribe: true,
  unsubscribeAfterFire: false,
  runAsIsolate: false,
);
```

#### subscribeIsolate
The subscribeIsolate type runs the callback in a separate isolate, enabling concurrent event handling. This is particularly useful for scenarios where you want to execute the event in isolation, avoiding potential interference with the main application flow.

Parameters are the same as for `subscribe`.

```dart
void myEvent(String message) {
    print('Event received: $message');
}

DDIEvent.instance.subscribeIsolate<String>(
  myEvent,
  qualifier: 'exampleEvent',
  registerIf: () => true,
  allowUnsubscribe: true,
  unsubscribeAfterFire: false,
  runAsIsolate: false,
);
```

### Unsubscribing an Event

To unsubscribe from an event, use the `unsubscribe` function:

```dart
DDIEvent.instance.unsubscribe<String>(
  myEvent,
  qualifier: 'exampleEvent',
);
```

### Firing an Event

To fire an event, use the `fire` function:

```dart
DDIEvent.instance.fire('Hello, Dart DDI!', qualifier: 'exampleEvent');
```

## Events Considerations

When using the Event System, consider the following:

`Async Event Handling:` You will not abble to await an Async event run.

`Possible Problems:` Be cautious of potential issues such as race conditions and excessive use of isolate-based event handling, which may impact performance.

See the considerations about [Qualifiers](#considerations).

## Use Cases

`Cross-State Communication:` Facilitate communication between differents Cubits/Bloc or other State Management in a Flutter application.

`Network Request Handling`: Manage events related to network requests and responses for streamlined communication.

`Background Task`: Coordinate background tasks and events for efficient task execution.

# Stream

The `DDIStream` abstract class in serves as a foundation for managing streams efficiently within the application. This class provides methods for subscribing, closing, and firing events through streams. Below are the key features and usage guidelines for the DDIStream abstract class.

## Subscription

Use `subscribe` to register a callback function that will be invoked when the stream emits a value. This method supports optional qualifiers, conditional registration, and automatic unsubscription after the first invocation.

Subscribes to a stream of type `StreamTypeT`.

- `callback`: A function to be invoked when the stream emits a value.
- `qualifier`: An optional qualifier to distinguish between different streams of the same type.
- `registerIf`: An optional function to conditionally register the subscription.
- `unsubscribeAfterFire`: If true, unsubscribes the callback after it is invoked once.

```dart
void subscribe<StreamTypeT extends Object>({
  required void Function(StreamTypeT) callback,
  Object? qualifier,
  bool Function()? registerIf,
  bool unsubscribeAfterFire = false,
});
```

## Closing Stream

Use `close` to end the subscription to a specific stream, allowing for efficient resource management.

Closes the subscription to a stream of type `StreamTypeT`.
- `qualifier`: An optional qualifier to distinguish between different streams of the same type.

```dart
void close<StreamTypeT extends Object>({Object? qualifier});
```

## Firing Events

Use `fire` to sends a value into the stream, triggering the subscribed callbacks. You can specify the target stream using the optional qualifier.

Fires a value into the stream of type `StreamTypeT`.
- `value`: The value to be emitted into the stream.
- `qualifier`: An optional qualifier to distinguish between different streams of the same type.

```dart
void fire<StreamTypeT extends Object>({
  required StreamTypeT value,
  Object? qualifier,
});
```

## Retrieving Stream

Use `getStream` to obtain a stream, providing access for further interactions. The optional qualifier allows you to retrieve a specific stream.

Retrieves a stream of type `StreamTypeT`.
- `qualifier`: An optional qualifier to distinguish between different streams of the same type.

```dart
Stream<StreamTypeT> getStream<StreamTypeT extends Object>(
    {Object? qualifier});

```

# API Reference

## registerSingleton

Registers a singleton instance. The `clazzRegister` parameter is a factory function to create the instance. Optional parameters allow customization of the instance's behavior and lifecycle.

```dart
FutureOr<void> registerSingleton<BeanT extends Object>(
  FutureOr<BeanT> Function() clazzRegister, {
  Object? qualifier,
  void Function()? postConstruct,
  List<BeanT Function(BeanT)>? decorators,
  List<DDIInterceptor<BeanT> Function()>? interceptors,
  FutureOr<bool> Function()? registerIf,
  bool destroyable = true,
});
```

## registerApplication<BeanT>

Registers an application-scoped instance. The instance is created when first used and reused afterward.

```dart
FutureOr<void> registerApplication<BeanT extends Object>(
  FutureOr<BeanT> Function() clazzRegister, {
  Object? qualifier,
  void Function()? postConstruct,
  List<BeanT Function(BeanT)>? decorators,
  List<DDIInterceptor<BeanT> Function()>? interceptors,
  FutureOr<bool> Function()? registerIf,
  bool destroyable = true,
});
```

## registerDependent

Registers a dependent instance. A new instance is created every time it is used.

```dart
FutureOr<void> registerDependent<BeanT extends Object>(
  FutureOr<BeanT> Function() clazzRegister, {
  Object? qualifier,
  void Function()? postConstruct,
  List<BeanT Function(BeanT)>? decorators,
  List<DDIInterceptor<BeanT> Function()>? interceptors,
  FutureOr<bool> Function()? registerIf,
  bool destroyable = true,
});
```

## registerSession

Registers a session-scoped instance. The instance is tied to a specific session.

```dart
FutureOr<void> registerSession<BeanT extends Object>(
  BeanT Function() clazzRegister, {
  Object? qualifier,
  void Function()? postConstruct,
  List<BeanT Function(BeanT)>? decorators,
  List<DDIInterceptor<BeanT> Function()>? interceptors,
  FutureOr<bool> Function()? registerIf,
  bool destroyable = true,
});
```

## registerObject

Registers an Object values as instance. The `register` parameter is the value shared across de application.

```dart
FutureOr<void> registerObject<BeanT extends Object>(
  BeanT register, {
  required Object qualifier,
  void Function()? postConstruct,
  List<BeanT Function(BeanT)>? decorators,
  List<DDIInterceptor<BeanT> Function()>? interceptors,
  FutureOr<bool> Function()? registerIf,
  bool destroyable = true,
});
```

## get

Retrieves an instance of type `BeanT` from the appropriate scope. You can provide a `qualifier` to distinguish between instances of the same type.

```dart
BeanT get<BeanT extends Object>({Object? qualifier});
```

## getAsync

Retrieves a Future instance of type `BeanT`, making possible to await to get the instances. 

```dart
Future<BeanT> getAsync<BeanT extends Object>({Object? qualifier});
```

## getByType

Retrieves all instance identifiers of type `BeanT`.

```dart
List<Object> getByType<BeanT extends Object>();
```

## call

A shorthand for `get<BeanT>()`, allowing a more concise syntax for obtaining instances.

```dart
BeanT call<BeanT extends Object>();
```

## destroy

Destroy an instance from the container. Useful for manual cleanup.

```dart
void destroy<BeanT>({Object? qualifier});
```

## destroyByType

Destroy all instance with type `BeanT`.

```dart
void destroyByType<BeanT extends Object>();
```

## dispose

Disposes of an instance, invoking any cleanup logic. This is particularly useful for instances with resources that need to be released. Only applied to Application and Session Scopes

```dart
void dispose<BeanT>({Object? qualifier});
```

## disposeByType

Disposes all instance with type `BeanT`. Only applied to Application and Session Scopes

```dart
void disposeByType<BeanT extends Object>();
```

## addDecorator

This provides a dynamic way to enhance the behavior of registered instances by adding decorators. The `addDecorator` method allows you to apply additional functionality to instances managed by the library.
When using the addDecorator method, keep in mind the order of execution, scope considerations, and the fact that instances already obtained remain unaffected. 

```dart
void addDecorator<BeanT extends Object>(List<BeanT Function(BeanT)> decorators, {Object? qualifier});
```

## addInterceptor

This feature allows you to dynamically influence the instantiation, retrieval, destruction, and disposal of instances by adding custom interceptors. The `addInterceptor` method enables you to associate specific interceptors with particular types.
```dart
void addInterceptor<BeanT extends Object>(List<DDIInterceptor<BeanT> Function()> interceptors, {Object? qualifier});
```

## refreshObject

Enables the dynamic refreshing of an object within the Object Scope. Use it to update the existing object without affecting instances already obtained.
```dart
void refreshObject<BeanT extends Object>({required Object qualifier, required BeanT register,
});
```

