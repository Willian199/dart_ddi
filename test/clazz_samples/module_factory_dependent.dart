import 'package:dart_ddi/dart_ddi.dart';

import 'a.dart';
import 'b.dart';
import 'c.dart';
import 'multi_inject.dart';

class ModuleFactoryDependent with DDIModule {
  @override
  void onPostConstruct() {
    register(factory: DependentFactory(builder: B.new.builder));
    register(factory: DependentFactory(builder: A.new.builder));
    register(factory: DependentFactory(builder: C.new.builder));
    register(factory: DependentFactory(builder: MultiInject.new.builder));
  }
}
