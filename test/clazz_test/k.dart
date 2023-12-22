import 'package:dart_ddi/features/ddi_interceptor.dart';

import 'd.dart';

class K extends DDIInterceptor<D> {
  @override
  D aroundConstruct(D instance) {
    instance.value = '${instance.value}cons';
    return instance;
  }

  @override
  D aroundGet(D instance) {
    instance.value = '${instance.value}GET';
    return instance;
  }
}
