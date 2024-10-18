import 'package:dart_ddi/dart_ddi.dart';

import 'a.dart';
import 'b.dart';
import 'c.dart';
import 'multi_inject.dart';

class ModuleFactoryApplication with DDIModule {
  @override
  void onPostConstruct() {
    register(factory: B.new.builder.asApplication());
    register(factory: A.new.builder.asApplication());
    register(factory: C.new.builder.asApplication());
    register(factory: MultiInject.new.builder.asApplication());
  }
}
