import 'package:dart_ddi/dart_ddi.dart';

import 'a.dart';
import 'b.dart';
import 'c.dart';

class ModuleDependent with DDIModule {
  @override
  void onPostConstruct() {
    registerDependent(C.new);
    registerDependent(() => B(ddi()));
    registerDependent(() => A(ddi()));
  }
}
