import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:dart_ddi/src/exception/duplicated_bean.dart';
import 'package:test/test.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/c.dart';
import '../clazz_samples/module_dependent.dart';

void main() {
  group('DDI Modules Dependent Basic Tests', () {
    tearDownAll(
      () {
        expect(ddi.isEmpty, true);
      },
    );
    test('Register a Dependent Module', () async {
      DDI.instance.dependent(ModuleDependent.new);

      DDI.instance.get<ModuleDependent>();

      await expectLater(() async => DDI.instance.getAsync<ModuleDependent>(),
          throwsA(isA<DuplicatedBeanException>()));

      DDI.instance.destroy<ModuleDependent>();

      DDI.instance.dependent(ModuleDependent.new);

      await DDI.instance.getAsync<ModuleDependent>();

      final instance1 = DDI.instance.get<A>();
      final instance2 = DDI.instance.get<A>();

      expect(false, identical(instance1, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(false, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      DDI.instance.dispose<ModuleDependent>();

      DDI.instance.destroy<ModuleDependent>();

      expect(
          () => DDI.instance.get<C>(), throwsA(isA<BeanNotFoundException>()));
    });
  });
}
