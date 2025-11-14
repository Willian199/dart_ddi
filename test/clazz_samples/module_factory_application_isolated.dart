import 'package:dart_ddi/dart_ddi.dart';

import 'a.dart';
import 'b.dart';
import 'c.dart';
import 'multi_inject.dart';

/// Module that uses an isolated DDI container by overriding the ddi getter.
/// This is used for testing isolated container behavior.
class ModuleFactoryApplicationIsolated with DDIModule {
  ModuleFactoryApplicationIsolated(this._customDdi);
  final DDI _customDdi;

  @override
  DDI get ddiContainer => _customDdi;

  @override
  void onPostConstruct() {
    register(factory: ApplicationFactory(builder: B.new.builder));
    register(factory: ApplicationFactory(builder: A.new.builder));
    register(factory: ApplicationFactory(builder: C.new.builder));
    register(factory: ApplicationFactory(builder: MultiInject.new.builder));
  }
}
