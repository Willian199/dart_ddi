import 'package:dart_ddi/dart_ddi.dart';

import 'a.dart';
import 'b.dart';
import 'c.dart';

class ModuleApplication with DDIModule {
  @override
  void onPostConstruct() {
    registerApplication(clazzRegister: () => B(ddi()));
    registerApplication(clazzRegister: () => A(ddi()));
    registerApplication(clazzRegister: C.new);
  }
}
