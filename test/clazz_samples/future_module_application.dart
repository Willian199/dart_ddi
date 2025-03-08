import 'package:dart_ddi/dart_ddi.dart';

import 'a.dart';
import 'b.dart';
import 'c.dart';

class FutureModuleApplication with DDIModule {
  @override
  Future<void> onPostConstruct() async {
    await Future.delayed(const Duration(milliseconds: 10));
    registerApplication(() => B(ddi()));
    registerApplication(() => A(ddi()));
    registerApplication(C.new);
  }
}
