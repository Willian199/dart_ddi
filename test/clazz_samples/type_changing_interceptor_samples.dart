import 'package:dart_ddi/dart_ddi.dart';

import 'g.dart';
import 'i.dart';

final class ReplaceWithIOnGetInterceptor extends DDIInterceptor<G> {
  @override
  G onGet(G instance) {
    return I();
  }
}
