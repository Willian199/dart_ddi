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
  /// - `qualifier`: (Optional) Qualifier to distinguish between different instances.
  ///
  /// This method checks if the class is registered before retrieving the instance.
  BeanT? getOptional<BeanT extends Object>({Object? qualifier}) {
    return isRegistered<BeanT>(qualifier: qualifier)
        ? get<BeanT>(qualifier: qualifier)
        : null;
  }

  /// Optionally retrieves an instance with a parameter of the registered class.
  ///
  /// - `qualifier`: (Optional) Qualifier to distinguish between different instances.
  /// - `parameter`: (Optional) Parameter to pass during instance creation.
  ///
  /// This method allows optional retrieval of instances with parameters.
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
      getOptionalWithAsync<BeanT extends Object, ParameterT extends Object>({
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
