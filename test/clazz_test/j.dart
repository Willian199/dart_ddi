import 'package:dart_ddi/src/features/ddi_interceptor.dart';

import 'g.dart';
import 'i.dart';

class J extends DDIInterceptor<G> {
  @override
  I aroundConstruct(G instance) {
    return I();
  }
}
