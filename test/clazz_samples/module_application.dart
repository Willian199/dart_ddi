import 'package:dart_ddi/src/mixin/ddi_module_mixin.dart';

import 'a.dart';
import 'b.dart';
import 'c.dart';

class ModuleApplication with DDIModule {
  @override
  void onPostConstruct() {
    registerApplication(() => B(inject()));
    registerApplication(() => A(inject()));
    registerApplication(C.new);
  }
}
