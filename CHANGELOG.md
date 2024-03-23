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
