import 'package:dart_ddi/src/features/ddi_interceptor.dart';
import 'package:meta/meta.dart';

@internal
abstract interface class DDIInternal {
  @internal
  DDIInterceptor getInterceptor(Object qualifier);

  @internal
  Future<DDIInterceptor> getInterceptorAsync(Object qualifier);
}
