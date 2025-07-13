import 'package:dart_ddi/dart_ddi.dart';

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
}
