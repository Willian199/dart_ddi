import 'package:dart_ddi/dart_ddi.dart';

import 'a.dart';
import 'b.dart';
import 'c.dart';
import 'multi_inject.dart';

class ModuleFactoryApplication with DDIModule {
  @override
  void onPostConstruct() {
    register(factory: ApplicationFactory(builder: B.new.builder));
    register(factory: ApplicationFactory(builder: A.new.builder));
    register(factory: ApplicationFactory(builder: C.new.builder));
    register(factory: ApplicationFactory(builder: MultiInject.new.builder));
  }
}
