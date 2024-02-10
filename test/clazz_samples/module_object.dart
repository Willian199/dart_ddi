import 'package:dart_ddi/src/mixin/ddi_module_mixin.dart';

class ModuleObject with DDIModule {
  @override
  void onPostConstruct() {
    registerObject('Willian', qualifier: 'authored');
    registerObject(true, qualifier: 'enabled');
  }
}
