import 'package:dart_ddi/dart_ddi.dart';

import 'a.dart';
import 'b.dart';
import 'c.dart';
import 'multi_inject.dart';

class ModuleFactorySingleton with DDIModule {
  @override
  void onPostConstruct() {
    register(factory: SingletonFactory(builder: C.new.builder));
    register(factory: SingletonFactory(builder: B.new.builder));
    register(factory: SingletonFactory(builder: A.new.builder));
    register(factory: SingletonFactory(builder: MultiInject.new.builder));
  }
}

class ModuleAsyncFactorySingleton with DDIModule {
  @override
  Future<void> onPostConstruct() async {
    await register(factory: SingletonFactory(builder: C.new.builder));
    await Future.wait([
      register(factory: SingletonFactory(builder: B.new.builder)),
      register(factory: SingletonFactory(builder: A.new.builder)),
      register(factory: SingletonFactory(builder: MultiInject.new.builder)),
    ]);
  }
}
