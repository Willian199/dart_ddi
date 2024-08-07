import 'package:dart_ddi/dart_ddi.dart';

import 'child_module.dart';
import 'component.dart';

class ParentModule with DDIModule {
  @override
  void onPostConstruct() {
    registerComponent(() => const Component('parent'));
    registerApplication(ChildModule.new);
  }
}
