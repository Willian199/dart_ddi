import 'package:dart_ddi/dart_ddi.dart';

/// Extension for [DDI] to get an optional instance
extension DDIOptional<BeanT extends Object> on DDI {
  BeanT? getOptional({Object? qualifier}) {
    return isRegistered<BeanT>(qualifier: qualifier)
        ? get<BeanT>(qualifier: qualifier)
        : null;
  }

  Future<BeanT?> getOptionalAsync({Object? qualifier}) async {
    if (isRegistered<BeanT>(qualifier: qualifier)) {
      return getAsync<BeanT>(qualifier: qualifier);
    }

    return null;
  }
}
