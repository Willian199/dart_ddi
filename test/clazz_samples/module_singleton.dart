import 'package:dart_ddi/src/mixin/ddi_module_mixin.dart';

import 'a.dart';
import 'b.dart';
import 'c.dart';

class ModuleSingleton with DDIModule {
  @override
  void onPostConstruct() {
    registerSingleton(C.new);
    registerSingleton(() => B(inject()));
    registerSingleton(() => A(inject()));
  }
}
