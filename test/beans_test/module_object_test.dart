import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:test/test.dart';

import '../clazz_samples/module_object.dart';

void moduleObjectTest() {
  group('DDI Modules Object Basic Tests', () {
    test('Register a Object Module', () {
      DDI.instance.registerObject(ModuleObject());

      final author = DDI.instance.get(qualifier: 'authored');
      final enabled = DDI.instance.get(qualifier: 'enabled');

      expect(author, 'Willian');
      expect(enabled, true);

      DDI.instance.destroy<ModuleObject>();

      expect(() => DDI.instance.get(qualifier: 'authored'),
          throwsA(isA<BeanNotFoundException>()));
    });
  });
}
