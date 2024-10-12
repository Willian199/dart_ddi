import 'package:dart_ddi/dart_ddi.dart';

import 'a.dart';
import 'b.dart';
import 'c.dart';

class ModuleSingleton with DDIModule {
  @override
  void onPostConstruct() {
    registerSingleton(clazzRegister: C.new);
    registerSingleton(clazzRegister: () => B(ddi()));
    registerSingleton(clazzRegister: () => A(ddi()));
  }
}
