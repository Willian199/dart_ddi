import 'package:dart_ddi/dart_ddi.dart';

import 'a.dart';
import 'b.dart';
import 'c.dart';

class ModuleDependent with DDIModule {
  @override
  Future<void> onPostConstruct() async {
    await registerDependent(C.new);
    registerDependent(() => B(ddi()));
    registerDependent(() => A(ddi()));
  }
}
