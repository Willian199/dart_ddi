import 'package:dart_ddi/src/mixin/ddi_module_mixin.dart';

import 'a.dart';
import 'b.dart';
import 'c.dart';

class ModuleSession with DDIModule {
  @override
  void onPostConstruct() {
    registerSession(C.new);
    registerSession(() => B(inject()));
    registerSession(() => A(inject()));
  }
}
