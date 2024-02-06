import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/features/ddi_modules.dart';

import 'a.dart';
import 'b.dart';
import 'c.dart';

class ModuleSingleton with PostConstruct, DDIModules {
  @override
  void onPostConstruct() {
    registerSingleton(C.new);
    registerSingleton(() => B(inject()));
    registerSingleton(() => A(inject()));
  }
}
