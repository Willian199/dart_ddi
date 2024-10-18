import 'package:dart_ddi/dart_ddi.dart';

import 'a.dart';
import 'b.dart';
import 'c.dart';
import 'multi_inject.dart';

class ModuleFactoryDependent with DDIModule {
  @override
  void onPostConstruct() {
    register(factory: B.new.builder.asDependent());
    register(factory: A.new.builder.asDependent());
    register(factory: C.new.builder.asDependent());
    register(factory: MultiInject.new.builder.asDependent());
  }
}
