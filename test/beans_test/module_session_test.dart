import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:test/test.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/c.dart';
import '../clazz_samples/module_session.dart';

void moduleSessionTest() {
  group('DDI Modules Session Basic Tests', () {
    test('Register a Session Module', () {
      DDI.instance.registerSession(ModuleSession.new);

      DDI.instance.get<ModuleSession>();
      final instance1 = DDI.instance.get<A>();
      final instance2 = DDI.instance.get<A>();

      expect(instance1, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      DDI.instance.destroy<ModuleSession>();

      expect(
          () => DDI.instance.get<C>(), throwsA(isA<BeanNotFoundException>()));
    });
  });
}
