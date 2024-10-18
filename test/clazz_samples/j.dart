import 'package:dart_ddi/src/features/ddi_interceptor.dart';

import 'i.dart';

class J<T extends Object> extends DDIInterceptor<T> {
  @override
  T onCreate(T instance) {
    return I() as T;
  }
}
