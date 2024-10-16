import 'package:dart_ddi/dart_ddi.dart';

/// Extension for [DDI] to get instances
extension DDIGetExtension on DDI {
  /// Gets an instance of the registered class in [DDI].
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  BeanT get<BeanT extends Object>({Object? qualifier}) {
    return getWith<BeanT, Object>(qualifier: qualifier);
  }

  /// Gets an instance of the registered class in [DDI].
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `parameter`: Optional parameter to pass during the instance creation.
  ///
  /// **Note:** The `parameter` will be ignored: If the instance is already created or the constructor doesn't match with the parameter type.
  BeanT call<BeanT extends Object, ParameterT extends Object>(
      {ParameterT? parameter}) {
    return getWith<BeanT, ParameterT>(parameter: parameter);
  }

  /// Gets an instance of the registered class in [DDI].
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  Future<BeanT> getAsync<BeanT extends Object>({Object? qualifier}) {
    return getAsyncWith<BeanT, Object>(qualifier: qualifier);
  }

  BeanT? getOptional<BeanT extends Object>({Object? qualifier}) {
    return isRegistered<BeanT>(qualifier: qualifier)
        ? get<BeanT>(qualifier: qualifier)
        : null;
  }

  BeanT? getOptionalWith<BeanT extends Object, ParameterT extends Object>({
    ParameterT? parameter,
    Object? qualifier,
  }) {
    return isRegistered<BeanT>(qualifier: qualifier)
        ? getWith<BeanT, ParameterT>(qualifier: qualifier, parameter: parameter)
        : null;
  }

  Future<BeanT?> getOptionalAsync<BeanT extends Object>(
      {Object? qualifier}) async {
    if (isRegistered<BeanT>(qualifier: qualifier)) {
      return getAsync<BeanT>(qualifier: qualifier);
    }

    return null;
  }

  Future<BeanT?>
      getOptionalWithAsync<BeanT extends Object, ParameterT extends Object>({
    ParameterT? parameter,
    Object? qualifier,
  }) async {
    if (isRegistered<BeanT>(qualifier: qualifier)) {
      return getAsync<BeanT>(qualifier: qualifier);
    }

    return null;
  }
}
