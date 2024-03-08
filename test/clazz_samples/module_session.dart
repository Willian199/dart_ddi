import 'package:dart_ddi/dart_ddi.dart';

import 'a.dart';
import 'b.dart';
import 'c.dart';

class ModuleSession with DDIModule {
  @override
  void onPostConstruct() {
    registerSession(C.new);
    registerSession(() => B(ddi()));
    registerSession(() => A(ddi()));
  }
}
