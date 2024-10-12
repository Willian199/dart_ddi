import 'package:dart_ddi/dart_ddi.dart';

import 'a.dart';
import 'b.dart';
import 'c.dart';

class ModuleDependent with DDIModule {
  @override
  void onPostConstruct() {
    registerDependent(clazzRegister: C.new);
    registerDependent(clazzRegister: () => B(ddi()));
    registerDependent(clazzRegister: () => A(ddi()));
  }
}
