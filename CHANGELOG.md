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
