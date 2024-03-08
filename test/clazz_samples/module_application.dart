import 'package:dart_ddi/dart_ddi.dart';

import 'a.dart';
import 'b.dart';
import 'c.dart';

class ModuleApplication with DDIModule {
  @override
  void onPostConstruct() {
    registerApplication(() => B(ddi()));
    registerApplication(() => A(ddi()));
    registerApplication(C.new);
  }
}
