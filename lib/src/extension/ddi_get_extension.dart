import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/features/instance_wrapper.dart';

/// Extension for [DDI] to retrieve instances of registered classes.
///
/// This extension provides convenient methods to retrieve instances,
/// supporting qualifiers, parameters, and asynchronous creation.
extension DDIGetExtension on DDI {
  /// Retrieves an instance of the registered class from [DDI].
  ///
  /// - `qualifier`: (Optional) Qualifier to distinguish between different instances
  ///    of the same type.
  /// - `select`: Optional value to pass to distinguish between different instances of the same type.
  ///
  /// This is a standard method to retrieve instances using type inference.
  /// If multiple instances of the same type exist, the qualifier can be used to
  /// retrieve the correct instance.
  BeanT get<BeanT extends Object>({
    Object? qualifier,
    Object? select,
  }) {
    return getWith<BeanT, Object>(qualifier: qualifier, select: select);
  }

  /// Retrieves an instance of the registered class in [DDI], supporting parameters.
  ///
  /// - `qualifier`: (Optional) Qualifier to distinguish between different instances.
  /// - `parameter`: (Optional) Parameter to pass during instance creation.
  ///
  /// **Note:** If the instance is already created or the constructor does not match
  /// with the provided parameter type, the `parameter` will be ignored.
  BeanT call<BeanT extends Object, ParameterT extends Object>(
      {ParameterT? parameter}) {
    return getWith<BeanT, ParameterT>(parameter: parameter);
  }

  /// Retrieves an instance of the registered class asynchronously.
  ///
  /// - `qualifier`: (Optional) Qualifier to distinguish between different instances.
  /// - `select`: Optional value to pass to distinguish between different instances of the same type.
  ///
  /// This method is particularly useful when instance creation involves asynchronous operations.
  Future<BeanT> getAsync<BeanT extends Object>({
    Object? qualifier,
    Object? select,
  }) {
    return getAsyncWith<BeanT, Object>(qualifier: qualifier, select: select);
  }

  /// Optionally retrieves an instance of the registered class.
  ///
  /// This method safely checks if the class is registered before attempting to retrieve it.
  /// If the class is not registered, it returns `null` instead of throwing an exception.
  /// This is useful for optional dependencies or when you want to handle missing registrations gracefully.
  ///
  /// - `qualifier`: (Optional) Qualifier to distinguish between different instances.
  ///
  /// **Use cases:**
  /// - Optional dependencies that may or may not be registered
  /// - Graceful handling of missing services
  /// - Conditional service usage based on availability
  ///
  /// Example:
  /// ```dart
  /// // Safe retrieval - won't throw if not registered
  /// final service = ddi.getOptional<MyService>();
  /// if (service != null) {
  ///   service.doSomething();
  /// }
  ///
  /// // With qualifier
  /// final service = ddi.getOptional<MyService>(qualifier: 'special');
  /// ```
  BeanT? getOptional<BeanT extends Object>({Object? qualifier}) {
    return isRegistered<BeanT>(qualifier: qualifier)
        ? get<BeanT>(qualifier: qualifier)
        : null;
  }

  /// Optionally retrieves an instance with a parameter of the registered class.
  ///
  /// This method safely checks if the class is registered before attempting to retrieve it with parameters.
  /// If the class is not registered, it returns `null` instead of throwing an exception.
  /// This is useful for optional dependencies that require parameters.
  ///
  /// - `qualifier`: (Optional) Qualifier to distinguish between different instances.
  /// - `parameter`: (Optional) Parameter to pass during instance creation.
  ///
  /// **Use cases:**
  /// - Optional dependencies with parameters
  /// - Safe parameterized service retrieval
  /// - Conditional service usage with parameters
  ///
  /// Example:
  /// ```dart
  /// // Safe retrieval with parameter
  /// final service = ddi.getOptionalWith<MyService, String>(parameter: 'config');
  /// if (service != null) {
  ///   service.doSomething();
  /// }
  ///
  /// // With qualifier and parameter
  /// final service = ddi.getOptionalWith<MyService, String>(
  ///   qualifier: 'special',
  ///   parameter: 'config',
  /// );
  /// ```
  BeanT? getOptionalWith<BeanT extends Object, ParameterT extends Object>({
    ParameterT? parameter,
    Object? qualifier,
  }) {
    return isRegistered<BeanT>(qualifier: qualifier)
        ? getWith<BeanT, ParameterT>(qualifier: qualifier, parameter: parameter)
        : null;
  }

  /// Asynchronously retrieves an optional instance of the registered class.
  ///
  /// - `qualifier`: (Optional) Qualifier to distinguish between different instances.
  ///
  /// This method performs an asynchronous retrieval if the instance is registered.
  Future<BeanT?> getOptionalAsync<BeanT extends Object>(
      {Object? qualifier}) async {
    if (isRegistered<BeanT>(qualifier: qualifier)) {
      return getAsync<BeanT>(qualifier: qualifier);
    }

    return null;
  }

  /// Asynchronously retrieves an optional instance with a parameter.
  ///
  /// - `qualifier`: (Optional) Qualifier to distinguish between different instances.
  /// - `parameter`: (Optional) Parameter to pass during instance creation.
  ///
  /// This method supports asynchronous retrieval with a parameter.
  Future<BeanT?>
      getOptionalAsyncWith<BeanT extends Object, ParameterT extends Object>({
    ParameterT? parameter,
    Object? qualifier,
  }) async {
    if (isRegistered<BeanT>(qualifier: qualifier)) {
      return getAsyncWith<BeanT, ParameterT>(
        qualifier: qualifier,
        parameter: parameter,
      );
    }

    return null;
  }

  /// Gets an [Instance] wrapper for programmatic bean access, similar to CDI's Instance\<BeanT>.
  ///
  /// This method returns an [Instance] object that provides programmatic access to beans,
  /// allowing you to check if a bean is resolvable, get instances, and destroy them.
  ///
  /// - `qualifier`: Optional qualifier to identify a specific bean instance.
  /// - `useWeakReference`: If `true`, maintains a weak reference to the instance.
  ///   This allows the instance to be garbage collected if no other strong references exist.
  ///   Note: If `cache` is `true`, this parameter is ignored (cache takes precedence).
  /// - `cache`: If `true`, maintains a strong reference to the instance (caching).
  ///   This prevents the instance from being garbage collected while the Instance wrapper exists.
  ///   Takes precedence over `useWeakReference`.
  ///
  /// **Important:** If both `useWeakReference` and `cache` are `true`, `cache` takes precedence
  /// (strong reference is maintained). This is useful when you want to ensure the instance
  /// is not garbage collected even if the ApplicationScope uses WeakReference.
  ///
  /// Example:
  /// ```dart
  /// final instance = ddi.getInstance<MyService>();
  /// if (instance.isResolvable()) {
  ///   final service = instance.get();
  ///   service.doSomething();
  /// }
  /// ```
  ///
  /// Example with cache (strong reference):
  /// ```dart
  /// // ApplicationScope with WeakReference, but Instance with cache = true
  /// // This ensures the instance is not garbage collected while Instance exists
  /// final instance = ddi.getInstance<MyService>(cache: true);
  /// final service = instance.get(); // Instance is cached (strong reference)
  /// ```
  Instance<BeanT> getInstance<BeanT extends Object>({
    Object? qualifier,
    bool useWeakReference = false,
    bool cache = false,
  }) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    // Check if bean is registered
    if (!isRegistered<BeanT>(qualifier: qualifier)) {
      throw BeanNotFoundException(effectiveQualifierName.toString());
    }

    // Create a wrapper that uses getWith internally
    // This avoids needing direct access to the private _beans field
    return InstanceWrapper<BeanT>(
      qualifier: effectiveQualifierName,
      ddi: this,
      useWeakReference: useWeakReference,
      cache: cache,
    );
  }
}
