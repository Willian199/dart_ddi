import 'package:dart_ddi/src/mixin/ddi_module_mixin.dart';

class ModuleObject with DDIModule {
  @override
  void onPostConstruct() {
    object('Willian', qualifier: 'authored');
    object(true, qualifier: 'enabled');
  }
}
