import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';

import 'a.dart';
import 'b.dart';
import 'c.dart';

class ModuleSingleton with DDIModule, PreDestroy {
  @override
  void onPostConstruct() {
    registerSingleton(C.new);
    registerSingleton(() => B(ddi()));
    ddi.registerSingleton(() => A(ddi()));
  }

  @override
  FutureOr<void> onPreDestroy() {
    ddi.destroy<A>();
  }
}
