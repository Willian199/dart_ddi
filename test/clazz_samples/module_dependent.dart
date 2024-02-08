import 'package:dart_ddi/src/mixin/ddi_module_mixin.dart';

import 'a.dart';
import 'b.dart';
import 'c.dart';

class ModuleDependent with DDIModule {
  @override
  void onPostConstruct() {
    registerDependent(C.new);
    registerDependent(() => B(inject()));
    registerDependent(() => A(inject()));
  }
}
