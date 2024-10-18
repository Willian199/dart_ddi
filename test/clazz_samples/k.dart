import 'package:dart_ddi/src/features/ddi_interceptor.dart';

import 'd.dart';

class K extends DDIInterceptor<D> {
  @override
  D onCreate(D instance) {
    instance.value = '${instance.value}cons';
    return instance;
  }

  @override
  D onGet(D instance) {
    instance.value = '${instance.value}GET';
    return instance;
  }
}
