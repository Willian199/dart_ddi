import 'package:dart_ddi/dart_ddi.dart';

import 'a.dart';
import 'b.dart';
import 'c.dart';
import 'multi_inject.dart';

class ModuleFactorySingleton with DDIModule {
  @override
  void onPostConstruct() {
    register(factory: C.new.builder.asSingleton());
    register(factory: B.new.builder.asSingleton());
    register(factory: A.new.builder.asSingleton());
    register(factory: MultiInject.new.builder.asSingleton());
  }
}
