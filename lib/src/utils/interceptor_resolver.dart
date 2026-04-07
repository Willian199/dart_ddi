import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/core/ddi_internal.dart';

final class InterceptorResolver {
  const InterceptorResolver._();

  @pragma('vm:prefer-inline')
  static DDIInterceptor resolveSync({
    required DDI ddiInstance,
    required Object qualifier,
  }) {
    return (ddiInstance as DDIInternal).getInterceptor(qualifier);
  }

  @pragma('vm:prefer-inline')
  static Future<DDIInterceptor> resolveAsync({
    required DDI ddiInstance,
    required Object qualifier,
  }) {
    return (ddiInstance as DDIInternal).getInterceptorAsync(qualifier);
  }
}
