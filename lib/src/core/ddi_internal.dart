import 'dart:async';

import 'package:dart_ddi/src/features/ddi_interceptor.dart';
import 'package:meta/meta.dart';

@internal
abstract interface class DDIInternal {
  @internal
  DDIInterceptor getInterceptor(Object qualifier);

  @internal
  FutureOr<DDIInterceptor> getInterceptorAsync(Object qualifier);
}
