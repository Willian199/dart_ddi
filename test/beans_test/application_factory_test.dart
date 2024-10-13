import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:dart_ddi/src/exception/duplicated_bean.dart';
import 'package:test/test.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/b.dart';
import '../clazz_samples/c.dart';
import '../clazz_samples/multi_inject.dart';
import '../clazz_samples/undestroyable/application_factory_destroy_get.dart';
import '../clazz_samples/undestroyable/application_factory_destroy_register.dart';

void applicationFactory() {
  group('DDI Factory Application Basic Tests', () {
    void registerApplicationBeans() {
      DDI.instance
          .register(factoryClazz: MultiInject.new.factory.asApplication());
      DDI.instance.register(factoryClazz: A.new.factory.asApplication());
      DDI.instance.register(factoryClazz: B.new.factory.asApplication());
      DDI.instance.register(factoryClazz: C.new.factory.asApplication());
    }

    void removeApplicationBeans() {
      DDI.instance.destroy<MultiInject>();
      DDI.instance.destroy<A>();
      DDI.instance.destroy<B>();
      DDI.instance.destroy<C>();
    }

    test('Register and retrieve Factory Application bean', () {
      registerApplicationBeans();

      final instance1 = DDI.instance.get<MultiInject>();
      final instance2 = DDI.instance.get<A>();

      expect(instance1.a, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Factory Application bean after a "child" bean is diposed',
        () {
      registerApplicationBeans();

      final instance = DDI.instance.get<MultiInject>();

      DDI.instance.dispose<C>();
      final instance1 = DDI.instance.get<A>();
      expect(instance1, same(instance.a));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeApplicationBeans();
    });

    test(
        'Retrieve Factory Application bean after a second "child" bean is diposed',
        () {
      registerApplicationBeans();

      final instance = DDI.instance.get<MultiInject>();

      DDI.instance.dispose<B>();
      final instance1 = DDI.instance.get<A>();
      expect(instance1, same(instance.a));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeApplicationBeans();
    });

    test(
        'Retrieve Factory Application bean after the last "child" bean is diposed',
        () {
      registerApplicationBeans();

      final instance1 = DDI.instance.get<MultiInject>();

      DDI.instance.dispose<A>();
      final instance2 = DDI.instance.get<A>();

      expect(false, identical(instance1.a, instance2));
      expect(true, identical(instance1.b, instance2.b));
      expect(true, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Factory Application bean after 2 "child" bean is diposed',
        () {
      registerApplicationBeans();

      final instance1 = DDI.instance.get<MultiInject>();

      DDI.instance.dispose<B>();
      DDI.instance.dispose<A>();
      final instance2 = DDI.instance.get<A>();

      expect(false, identical(instance1, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(true, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Factory Application bean after 3 "child" bean is diposed',
        () {
      registerApplicationBeans();

      final instance1 = DDI.instance.get<MultiInject>();

      DDI.instance.dispose<C>();
      DDI.instance.dispose<B>();
      DDI.instance.dispose<A>();
      final instance2 = DDI.instance.get<A>();

      expect(false, identical(instance1, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(false, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Try to retrieve a Factory Application bean after disposed', () {
      DDI.instance.register(
          factoryClazz: FactoryClazz.application(clazzFactory: C.new.factory));

      final instance1 = DDI.instance.get<C>();

      DDI.instance.dispose<C>();

      final instance2 = DDI.instance.get<C>();

      expect(false, identical(instance1, instance2));

      DDI.instance.destroy<C>();
    });

    test('Try to retrieve Application bean after removed', () {
      DDI.instance.register(
          factoryClazz: FactoryClazz.application(clazzFactory: C.new.factory));

      DDI.instance.get<C>();

      DDI.instance.destroy<C>();

      expect(
          () => DDI.instance.get<C>(), throwsA(isA<BeanNotFoundException>()));
    });

    test('Create, get and remove a qualifier bean', () {
      DDI.instance.register(
          factoryClazz: FactoryClazz.application(clazzFactory: C.new.factory),
          qualifier: 'typeC');

      DDI.instance.get(qualifier: 'typeC');

      DDI.instance.destroy(qualifier: 'typeC');

      expect(() => DDI.instance.get(qualifier: 'typeC'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Try to destroy a undestroyable Application bean', () {
      DDI.instance.register(
        factoryClazz: FactoryClazz.application(
          clazzFactory: ApplicationFactoryDestroyGet.new.factory,
          destroyable: false,
        ),
      );

      final instance1 = DDI.instance.get<ApplicationFactoryDestroyGet>();

      DDI.instance.destroy<ApplicationFactoryDestroyGet>();

      final instance2 = DDI.instance.get<ApplicationFactoryDestroyGet>();

      expect(instance1, same(instance2));
    });

    test('Try to register again a undestroyable Application bean', () {
      DDI.instance.register(
          factoryClazz: FactoryClazz.application(
        clazzFactory: ApplicationFactoryDestroyRegister.new.factory,
        destroyable: false,
      ));

      DDI.instance.get<ApplicationFactoryDestroyRegister>();

      DDI.instance.destroy<ApplicationFactoryDestroyRegister>();

      expect(
          () => DDI.instance.register(
                factoryClazz: FactoryClazz.application(
                  clazzFactory: ApplicationFactoryDestroyRegister.new.factory,
                  destroyable: false,
                ),
              ),
          throwsA(isA<DuplicatedBeanException>()));
    });
  });
}
