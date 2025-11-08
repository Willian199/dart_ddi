## 0.14.0

* Added `Instance<BeanT>` wrapper for programmatic bean access. Also provides methods: `isResolvable()`, `get()`, `getAsync()`, `destroy()`, and `dispose()`.
* Added support for `cache` and `useWeakReference` parameters in `getInstance` method.
* When `Instance.cache = true` or `Instance.useWeakReference = true`, interceptors `onGet` are called only once (when instance is cached/stored).
* When `ApplicationScope.useWeakReference = true`, interceptors `onGet` are called every time (instance may be recreated if GC collected).
* `Instance.cache = true` takes precedence over `Instance.useWeakReference = true` (maintains strong reference).
* `Instance.cache = true` can convert `ApplicationScope` WeakReference to Strong reference.

## 0.13.0

* Performance improvements  
* Fixes state management during bean lifecycle.

* Break changes:
    * Qualifiers now require creating a new DDI instance to support Zone. Use `DDI.newInstance(enableZoneRegistry: true)` for Zone support.

## 0.12.0
* This version brings a major rework to be able to use Custom Scopes.
* Now you can create your own Scopes.
* Added support to Zoned instances with `DDI.instance.runInZone("zone_name", () => factory)`.

* Break changes:
    * Removed the `Session Scope` and correlated methods. Use `Application` instead.
    * Now the `YourClazz.new.builder.asApplication()` shortcut registers directly into ddi. You no longer need to call `.register()`.
    * Now the custom factory requires to specify the Scope Factory and the builder.

## 0.11.0
* Fixed DDIModule not waiting for all children to be destroyed in `destroy`.

* Break changes:
    * Moved events to it's own package `event_ddi`.
    * Removed support for `DDIStream`.

## 0.10.1
* Fixed web and wasm support.

## 0.10.0
* Added support to `undo`, `redo` and clear history on events.
* Added parameter `canReplay` to `fire` and `fireWait` methods. This controls if can `undo` or `redo`.
* Added support to get the last value fired, ignoring the filters.

* Break changes:
    * If the events isn't registered and `canReplay` is true, the `fire` and `fireWait` methods won't throw EventNotFoundException anymore.
    * All `registerIf` parameters have been renamed to `canRegister`.
    * All `destroyable` parameters have been renamed to `canDestroy`.
    * All `allowUnsubscribe` parameters have been renamed to `canUnsubscribe`.

## 0.9.0
* Interceptors reworked to behave like Beans. With now includes support to Decorators, Mixins, Futures and also "Intercept Interceptors".
* Added support to use selectors when getting a Bean.

* Break changes:
    * Everything related to Interceptors.

## 0.8.1

* Fixed Dependent instances where `DDIInterceptor.onGet` was running before `PostConstruct` mixin.

## 0.8.0

* Added support to register custom factories.
* Added support to auto inject `Beans` into factories.
* Added support to get Factory `Beans` with custom parameters.
* Refactored how `Future` and `FutureOr` is handled.

* Warnings:
    * When registering a Factory Future and trying to obtain more than one instance simultaneously, it may cause a race condition and will be blocked. Especially if the instance is Application Scope.
    * When using Interceptors and Factories, you must register your Factory with `ddi.register(factory: ApplicationFactory(builder: ..., interceptors: [...]))`

* Break changes:
    * `DDIInterceptor.aroundConstruct` renamed to `DDIInterceptor.onCreate`.
    * `DDIInterceptor.aroundGet` renamed to `DDIInterceptor.onGet`.
    * `DDIInterceptor.aroundDispose` renamed to `DDIInterceptor.onDispose`.
    * `DDIInterceptor.aroundDestroy` renamed to `DDIInterceptor.onDestroy`.

## 0.7.2

* Fix Singleton and Object behavior when registering with the `register` method.

## 0.7.1

* Added support for registering a custom factory class with the `register` method. Note: Factories with parameters are not yet supported.

## 0.7.0

* Added `registerComponent` and `getComponent` to `DDI`. Making Flutter Widgets components easier to reuse.
* Added `DDIComponentInject` mixin.
* Refactor `children` behavior.
* Removed `setDebugMode` behaviors.
* Bump min dart sdk to 3.4.0

## 0.6.6

* Resolved issue with concurrent modification in events.
* Corrected events with `autoRun` capability, ensuring they can run infinitely as intended.

## 0.6.5

* Added `Packages` and `Projects` information.
* Updated example to make it simpler.
* Fixed and documented the Dependent Scope with dispose and destroy behavior.

## 0.6.3

* Added the ability to retrieve the last fired state from `DDIEventSender` and `DDIStreamSender`.
* Added the ability to retrieve the `StreamController` from `DDIStream`.
* Improved code quality.

## 0.6.2

* Fixed an issue when using await where registering, disposing, and destroying a bean.

## 0.6.1

* Fixed `EventLock`, `DDIEventSender` and `DDIStreamSender` export.

## 0.6.0

* Added support to register locked events.
* Added support for onError and onComplete callbacks on events.
* Added support for events with expiration duration.
* Added support to auto-run events.
* Added support for events with retry interval and maximum retries.
* Added support to filter events based on the value.


## 0.5.1

### New Features

* Introduced a shorthand variable `ddi` for ease of use, replacing the need to use `DDI.instance`. 
* Added the capability to register children instances within module registrations.
* Added ability to enable or disable debugMode behavior.
* Included the `DDIController` mixin, providing a simplified approach to dependency injection usage.


### Breaking Change

* Removed the `inject` variable from `DDIModule`, now using `ddi` directly for more streamlined usage.


## 0.5.0

* Added support for Modules.
* Added Mixin DDIModule to help to use Modules behavior.
* Added Mixin PreDispose with execution before the class is disposed.
* Added methods isRegistered to Stream, Events and Beans instances.
* Future improvements.

## 0.4.0

* Added proper support for register and get Future instances.

## 0.3.1

* Fixed Documentation links.
* Some Futures instances behaviors fix.

## 0.3.0

* Migrating from flutter_test and flutter_lints to test and lints.
* Added support for Streams.
* Refactor Events behavior.
* Exceptions and code improvements.


## 0.2.0

* Added Mixin PostConstruct with execution after class construction.
* Added Mixin PreDestroy with execution before the class is destroyed.
* Added support for Events.
    * Subscribe, unsubscribe and fire events.
    * Conditional subscription.
    * Asynchronous and Isolate events.

## 0.1.0

* Added a new `Object Scope`.
* Added the parameter `destroyable`.
* Renamed `qualifierName` to `qualifier`.
* Removed the `Widget Scope`, as it had the same behavior as `Dependent Scope`.
* Removed the `DDIContext` extension and any Flutter dependecy. In the future there will be an extension with specific features for Flutter.


## 0.0.2

* Add app with example
* Folder structure 


## 0.0.1

* Scopes: Singleton, Application, Dependent, Session and Widget.
* Support register, get, dispose and destroy.
* Qualifiers support.
* Decorators support.
* Interceptors support.
* Conditional register.
* Post Construct support.
* Circular Dependency Injection Detector (Experimental).
