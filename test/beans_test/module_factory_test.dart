import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:test/test.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/c.dart';
import '../clazz_samples/module_factory_application.dart';
import '../clazz_samples/module_factory_dependent.dart';
import '../clazz_samples/module_factory_singleton.dart';

void main() {
  group('DDI Factory Modules Application Basic Tests', () {
    tearDownAll(() {
      expect(ddi.isEmpty, true);
    });
    test('Register a Factory Application Module', () {
      ModuleFactoryApplication.new.builder.asApplication();

      DDI.instance.get<ModuleFactoryApplication>();
      final instance1 = DDI.instance.get<A>();
      final instance2 = DDI.instance.get<A>();

      expect(instance1, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      DDI.instance.destroy<ModuleFactoryApplication>();

      expect(
        () => DDI.instance.get<C>(),
        throwsA(isA<BeanNotFoundException>()),
      );
    });

    test('Register a Factory Dependent Module', () {
      ModuleFactoryDependent.new.builder.asDependent();

      DDI.instance.get<ModuleFactoryDependent>();
      final instance1 = DDI.instance.get<A>();
      final instance2 = DDI.instance.get<A>();

      expect(false, identical(instance1, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(false, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      DDI.instance.destroy<ModuleFactoryDependent>();

      expect(
        () => DDI.instance.get<C>(),
        throwsA(isA<BeanNotFoundException>()),
      );
    });

    test('Register a Factory Singleton Module', () {
      ModuleFactorySingleton.new.builder.asSingleton();

      final instance1 = DDI.instance.get<A>();
      final instance2 = DDI.instance.get<A>();

      expect(instance1, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      DDI.instance.destroy<ModuleFactorySingleton>();

      expect(
        () => DDI.instance.get<C>(),
        throwsA(isA<BeanNotFoundException>()),
      );
    });
  });
}
