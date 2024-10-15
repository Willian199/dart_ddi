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

See this basic [example](https://github.com/Willian199/dart_ddi/blob/master/example/main.dart) to get started with DDI.

## Packages

- [Flutter DDI](https://pub.dev/packages/flutter_ddi) - This package is designed to facilitate the dependency injection process in your Flutter application.

## Projects

- [Perfumei](https://github.com/Willian199/Perfumei) - A simple mobile app about perfumes. Built using DDI and Cubit.
- [Clinicas](https://github.com/Willian199/lab_clinicas_fe) - A mobile, desktop and web application about Attendance Rank. Built using Signal and Flutter DDI to enable route-based dependency injection management.

Summary

1. [Core Concepts](#core-concepts)
   1. [Singleton](#singleton)
   2. [Application](#application)
   3. [Session](#session)
   4. [Dependent](#dependent)
   5. [Object](#object)
   6. [Common Considerations](#common-considerations)
2. [Qualifiers](#qualifiers)
   1. [How Qualifiers Work](#how-qualifiers-work)
   2. [Use Cases for Qualifiers](#use-cases-for-qualifiers)
   3. [Considerations](#considerations)
3. [Extra Customization](#extra-customization)
   1. [PostConstruct](#postconstruct)
   2. [Decorators](#decorators)
   3. [Interceptor](#interceptor)
   4. [RegisterIf](#registerif)
   5. [Destroyable](#destroyable)
4. [Modules](#modules)
   1. [Adding a Class](#adding-a-class)
   2. [Adding Multiple Class](#adding-multiple-class)
5. [Mixins](#mixins)
   1. [Post Construct](#post-construct-mixin)
   2. [Pre Destroy](#pre-destroy-mixin)
   3. [Pre Dispose](#pre-dispose-mixin)
   4. [DDIModule Mixin](#ddimodule-mixin)
   5. [DDIInject, DDIInjectAsync and DDIComponentInject Mixins](#ddiinject-ddiinjectasync-and-ddicomponentinject-mixins)
   6. [DDIEventSender and DDIStreamSender Mixins](#ddieventsender-and-ddistreamsender-mixins)
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

# Core Concepts
## Scopes

The Dart Dependency Injection (DDI) Library supports various scopes for efficient management of object instances. Each scope determines how instances are created, reused, and destroyed throughout the application lifecycle. Below are detailed characteristics of each scope, along with recommendations, use cases, and considerations for potential issues.

## Singleton
`Description`: This scope creates a single instance during registration and reuses it in all subsequent requests.

`Recommendation`: Suitable for objects that need to be globally shared across the application, maintaining a single instance.

`Use Case`: Sharing a configuration manager, a logging service, or a global state manager.

`Note`: 
        - `Interceptor.onDipose` and `PreDispose` mixin are not supported. You can just destroy the instance. 
        - If you call dispose, only the Application or Session childrens will be disposed.      

## Application
`Description`: Generates an instance when first used and reuses it for all subsequent requests during the application's execution.

`Recommendation`: Indicated for objects that need to be created only once per application and shared across different parts of the code.

`Use Case`: Managing application-level resources, such as a network client or a global configuration.

`Note`: `PreDispose` and `PreDestroy` mixins will only be called if the instance is in use. Use `Interceptor` if you want to call them regardless.

## Session
`Description`: Ties an instance to a specific session, persisting throughout the session's lifespan.

`Recommendation`: Suitable for objects that need to be retained while a session is active, such as user-specific data or state.

`Use Case`: Managing user authentication state or caching user-specific preferences.

`Note`: `PreDispose` and `PreDestroy` mixins will only be called if the instance is in use. Use `Interceptor` if you want to call them regardless.

## Dependent
`Description`: Produces a new instance every time it is requested, ensuring independence and uniqueness.

`Recommendation`: Useful for objects that should remain independent and different in each context or request.

`Use Case`: Creating instances of transient objects like data repositories or request handlers.

`Note`: 
        - `Dispose` functions, `Interceptor.onDipose` and `PreDispose` mixin are not supported.
        - `PreDestroy` mixins are not supported. Use `Interceptor.onDestroy` instead. 

## Object
`Description`: Registers an Object in the Object Scope, ensuring it is created once and shared throughout the entire application, working like Singleton.

`Recommendation`: Suitable for objects that are stateless or have shared state across the entire application.

`Use Case`: Application or device properties, like platform or dark mode settings, where the object's state needs to be consistent across the entire application.

`Note`: 
        - `Interceptor.onDipose` and `PreDispose` mixin are not supported. You can just destroy the instance. 
        - If you call dispose, only the Application or Session childrens will be disposed.

## Common Considerations:
`Single Registration`: Ensure that the instance to be registered is unique for a specific type or use qualifiers to enable the registration of multiple instances of the same type.

`Memory Management`: Be aware of memory implications for long-lived objects, especially in the Singleton and Object scopes.

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
The `postConstruct` callback allows to perform additional setup or initialization after an instance is created. This is particularly useful for executing logic that should run once the instance is ready for use.

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

### onCreate
- Invoked during the instance creation process.
- Customize or replace the instance creation logic by returning a modified instance.

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

### Adding Multiple Class
To add multiple class to a module at once, you can utilize the `addChildrenModules` method.

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

The `children` parameter is designed to receive types or qualifiers. This parameter allows you to register multiple classes under a single parent module, enhancing the organization and management of your dependency injection configuration.

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

### Pre Dipose Mixin

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
    registerSingleton(() => Database('main_database'), qualifier: 'mainDatabase');
    registerApplication(() => Logger(), qualifier: 'appLogger');
    registerObject('https://api.example.com', qualifier: 'apiUrl');
    registerDependent(() => ApiService(inject.get(qualifier: 'apiUrl')), qualifier: 'dependentApiService');
  }
}
```

### `DDIInject`, `DDIInjectAsync` and `DDIComponentInject` Mixins

The `DDIInject`, `DDIInjectAsync` and `DDIComponentInject` mixins are designed to facilitate dependency injection of an instance into your classes. They provide a convenient method to obtain an instance of a specific type from the dependency injection container.

The `DDIInject` mixin allows for synchronous injection of an instance and `DDIInjectAsync` mixin allows for asynchronous injection. Both defines a `instance` property that will be initialized with the `InjectType` instance obtained.

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

class MyController with DDIComponentInject<MyComponent, MyModule> {

  void businessLogic() {
    instance.runSomething();
  }
}
```	

### `DDIEventSender` and `DDIStreamSender` Mixins

The `DDIEventSender` and `DDIStreamSender` mixins are designed to simplify the process of sending events and stream values to listeners. They provide a convenient method fire to send the specified value to an event or stream.

The `DDIEventSender` mixin is used to send events to all registered listeners and the `DDIStreamSender` mixin is to send stream values. Both defines a fire method that takes the value as a parameter and sends it to all registered listeners.

#### Example Usage:
```dart
class MyEvent with DDIEventSender<String> {
  void businessLogic() {
    fire('Hello World');
  }
}

class MyStreamEvent with DDIStreamSender<int> {
  void businessLogic() {
    fire(42);
  }
}
```

# Events
Designed for flexibility and efficiency, this system empowers you to seamlessly manage, subscribe to, and respond to events, making it a crucial asset for building reactive and scalable Dart applications.

## Creating and Managing Events
The Events follow a straightforward flow. Functions or methods `subscribe` to specific events using the subscribe method of the `DDIEvent` class. Events are fired using the `fire` or `fireWait` methods, triggering the execution of all subscribed callbacks. Subscribed callbacks are then executed, handling the event data and performing any specified tasks. Subscriptions can be removed using the `unsubscribe` function.

### Subscribing an Event
When subscribing to an event, you have the option to choose from three different types of subscriptions:

- `DDIEvent.instance.subscribe` It's the common type, working as a simples callback.
- `DDIEvent.instance.subscribeAsync` Runs the callback as a Future.
- `DDIEvent.instance.subscribeIsolate` Runs as a Isolate.

#### subscribe
The common subscription type, subscribe, functions as a simple callback. It allows you to respond to events in a synchronous manner, making it suitable for most scenarios.

Obs: If you register an event that uses async and await, it will not be possible to wait even using `fireWait`. For this scenario, use `subscribeAsync`.

Parameters:

- `event:` The callback function to be executed when the event is fired.
- `qualifier:` Optional qualifier name to distinguish between different events of the same type.
- `registerIf:` A FutureOr<bool> function that if returns true, allows the subscription to proceed.
- `allowUnsubscribe:` Indicates if the event can be unsubscribe. Ignored if `autoRun` is used.
- `priority:` Priority of the subscription relative to other subscriptions (lower values indicate higher priority). Ignored if `autoRun` is used.
- `unsubscribeAfterFire:` If true, the subscription will be automatically removed after the first time the event is fired. Ignored if `autoRun` is used.
- `lock`: Indicates if the event should be locked. Running only one event simultaneously. Cannot be used in combination with `autoRun`.
- `onError`: The callback function to be executed when an error occurs.
- `onComplete`: The callback function to be executed when the event is completed. It's called even if an error occurs.
- `expirationDuration`: The duration after which the subscription will be automatically removed.
- `retryInterval`: Adds the ability to automatically retry the event after the interval specified.
- `defaultValue`: The default value to be used when the event is fired. Required if `retryInterval` is used.
- `maxRetry`: The maximum number of times the subscription will be automatically fired if `retryInterval` is used.
     * Can be used in combination with `autoRun` and `onError`.
     * If `maxRetry` is 0 and `autoRun` is true, will run forever.
     * If `maxRetry` is greater than 0 and `autoRun` is true, the subscription will be removed when the maximum number of retries is reached.
     * If `maxRetry` is greater than 0, `autoRun` is false and `onError` is used, the subscription will stop retrying when the maximum number is reached.
     * If `expirationDuration` is used, the subscription will be removed when the first rule is met, either when the expiration duration is reached or when the maximum number of retries is reached.
- `autoRun`: If true, the event will run automatically when the subscription is created.
     * Only one event is allowed.
     * `allowUnsubscribe` is ignored.
     * `unsubscribeAfterFire` is ignored.
     * `priority` is ignored.
     * Cannot be used in combination with `lock`.
     * Requires the `defaultValue` parameter.
     * If `maxRetry` is 0, will run forever.
- `filter`: Allows you to filter events based on their value. Only events when the filter returns true will be fired.

```dart
void myEvent(String message) {
    print('Event received: $message');
}

DDIEvent.instance.subscribe<String>(
  myEvent,
  qualifier: 'exampleEvent',
  registerIf: () => true,
  allowUnsubscribe: true,
  priority: 0
  unsubscribeAfterFire: false,
  lock: false,
  onError: (Object? error, StackTrace stacktrace, String valor){},
  onComplete: (){},
  expirationDuration: const Duration(seconds: 5),
  retryInterval: const Duration(seconds: 4),
  defaultValue: 'defaultValue',
  maxRetry: 1,
  autoRun: false,
  filter: (value) => true,
);
```

#### subscribeAsync
The subscribeAsync type runs the callback as a Future, allowing for asynchronous event handling. Making it suitable for scenarios where asynchronous execution is needed without waiting for completion.
Note that it not be possible to await this type of subscription.

Obs: If you want to await for the event to be completed, fire it using `fireWait`.

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
  lock: false,
  onError: (Object? error, StackTrace stacktrace, String valor){},
  onComplete: (){},
  expirationDuration: const Duration(seconds: 5),
  retryInterval: const Duration(seconds: 4),
  defaultValue: 'defaultValue',
  maxRetry: 1,
  autoRun: false,
  filter: (value) => true,
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
  lock: false,
  onError: (Object? error, StackTrace stacktrace, String valor){},
  onComplete: (){},
  expirationDuration: const Duration(seconds: 5),
  retryInterval: const Duration(seconds: 4),
  defaultValue: 'defaultValue',
  maxRetry: 1,
  autoRun: false,
  filter: (value) => true,
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

To fire an event, use the `fire` or `fireWait` function. Using `fireWait` makes it possible to wait for all events to complete.

```dart
DDIEvent.instance.fire('Hello, Dart DDI!', qualifier: 'exampleEvent');

await DDIEvent.instance.fireWait('Hello, Dart DDI!', qualifier: 'exampleEvent');
```

## Events Considerations

When using the Event System, consider the following:

`Event Granularity`: Design events with appropriate granularity to ensure they represent meaningful actions or states in the application.

`Modularity`: Keep events and their handlers modular and self-contained.

`Single Responsibility`: Ensure each event and its handler have a single responsibility.

`Possible Problems`: Be cautious of potential issues such as race conditions and excessive use of isolate-based event handling, which may impact performance.

`Unnecessary Locking`: Applying locks to events unnecessarily may hinder the application's responsiveness. Use locking only when essential to prevent conflicting event executions.

`Event Looping`: Carefully manage scenarios where events trigger further events, as this can lead to infinite loops or excessive event cascades.

See the considerations about [Qualifiers](#considerations).

## Use Cases

`Application Lifecycle`: Manage events related to the application's lifecycle.

`Data Synchronization`: Handle data synchronization events between local and remote data sources.

`Background Task`: Coordinate background tasks and events for efficient task execution.

`Custom Event Bus`: Build a custom event bus for inter-component communication, allowing different parts of the application to communicate without tight coupling.

`Notifications`: Implement notifications for updates in various parts of the application, such as new messages, alerts, or data changes.

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
