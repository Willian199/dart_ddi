import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:test/test.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/c.dart';
import '../clazz_samples/module_dependent.dart';

void moduleDependentTest() {
  group('DDI Modules Dependent Basic Tests', () {
    test('Register a Dependent Module', () {
      DDI.instance.registerDependent(ModuleDependent.new);

      DDI.instance.get<ModuleDependent>();
      final instance1 = DDI.instance.get<A>();
      final instance2 = DDI.instance.get<A>();

      expect(false, identical(instance1, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(false, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      DDI.instance.destroy<ModuleDependent>();

      expect(() => DDI.instance.get<C>(), throwsA(isA<BeanNotFoundException>()));
    });
  });
}
