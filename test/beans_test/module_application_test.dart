import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:test/test.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/c.dart';
import '../clazz_samples/future_module_application.dart';
import '../clazz_samples/module_application.dart';

void main() {
  group('DDI Modules Application Basic Tests', () {
    test('Register an Application Module', () {
      DDI.instance.application(ModuleApplication.new);

      DDI.instance.get<ModuleApplication>();
      final instance1 = DDI.instance.get<A>();
      final instance2 = DDI.instance.get<A>();

      expect(DDI.instance.isReady<A>(), true);

      expect(instance1, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      DDI.instance.dispose<ModuleApplication>();

      expect(DDI.instance.isReady<A>(), false);

      DDI.instance.destroy<ModuleApplication>();

      expect(
          () => DDI.instance.get<C>(), throwsA(isA<BeanNotFoundException>()));
    });

    test('Register a Future Application Module', () async {
      DDI.instance.application(FutureModuleApplication.new);

      await DDI.instance.getAsync<FutureModuleApplication>();
      final instance1 = DDI.instance.get<A>();
      final instance2 = DDI.instance.get<A>();

      expect(instance1, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      await DDI.instance.destroy<FutureModuleApplication>();

      expect(
          () => DDI.instance.get<C>(), throwsA(isA<BeanNotFoundException>()));
      expect(DDI.instance.isRegistered<A>(), false);
    });

    test('Add ChildrenModules to a Bean not Registered', () {
      expect(() => ddi.addChildrenModules<C>(child: {A}),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Get Children from a Bean not Registered', () {
      expect(ddi.getChildren<C>(), Set.of({}));
    });

    test('Register an Application Module and dispose async', () async {
      DDI.instance.application(FutureModuleApplication.new);

      final module = await DDI.instance.getAsync<FutureModuleApplication>();
      expect(module.children.length, 3);

      final instance1 = DDI.instance.get<A>();
      final instance2 = DDI.instance.get<A>();

      expect(instance1, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      await DDI.instance.dispose<FutureModuleApplication>();

      expect(DDI.instance.isRegistered<A>(), true);
      expect(DDI.instance.isReady<FutureModuleApplication>(), false);

      await DDI.instance.destroy<FutureModuleApplication>();

      expect(
          () => DDI.instance.get<C>(), throwsA(isA<BeanNotFoundException>()));
      expect(DDI.instance.isRegistered<A>(), false);
    });
  });
}
