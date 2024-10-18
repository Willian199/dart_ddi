import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:dart_ddi/src/exception/duplicated_bean.dart';
import 'package:test/test.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/b.dart';
import '../clazz_samples/c.dart';
import '../clazz_samples/factory_parameter.dart';
import '../clazz_samples/multi_inject.dart';
import '../clazz_samples/undestroyable/singleton_factory_destroy_get.dart';
import '../clazz_samples/undestroyable/singleton_factory_destroy_register.dart';

void singletonFactory() {
  group('DDI Singleton Factory Basic Tests', () {
    void registerBeans() {
      ddi.register(factory: C.new.builder.asSingleton());
      ddi.register(factory: B.new.builder.asSingleton());
      ddi.register(factory: A.new.builder.asSingleton());
      ddi.register(factory: MultiInject.new.builder.asSingleton());
    }

    void removeSingletonBeans() {
      ddi.destroy<MultiInject>();
      ddi.destroy<A>();
      ddi.destroy<B>();
      ddi.destroy<C>();
    }

    test('Register and retrieve a Factory Singleton bean', () {
      ///Where is Singleton, should register in the correct order
      registerBeans();

      final instance1 = ddi.get<MultiInject>();
      final instance2 = ddi.get<A>();

      expect(instance1.a, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeSingletonBeans();
    });

    test('Retrieve a Factory singleton bean after a "child" bean is destroyed',
        () {
      registerBeans();

      final instance = ddi.get<MultiInject>();

      ddi.destroy<C>();
      final instance1 = ddi.get<A>();
      expect(instance1, same(instance.a));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      ddi.destroy<A>();
      ddi.destroy<B>();
      ddi.destroy<MultiInject>();
    });

    test(
        'Retrieve a Factory singleton bean after a second "child" bean is destroyed',
        () {
      registerBeans();

      final instance = ddi.get<MultiInject>();

      ddi.destroy<B>();
      ddi.destroy<C>();
      final instance1 = ddi.get<A>();
      expect(instance1, same(instance.a));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      ddi.destroy<A>();
      ddi.destroy<MultiInject>();
    });

    test('Try to retrieve a Factory singleton bean after removed', () {
      ddi.register(factory: C.new.builder.asSingleton());

      ddi.get<C>();

      ddi.destroy<C>();

      expect(() => ddi.get<C>(), throwsA(isA<BeanNotFoundException>()));
    });

    test('Create, get and remove a Factory qualifier bean', () {
      ddi.register(factory: C.new.builder.asSingleton(), qualifier: 'typeC');

      ddi.get(qualifier: 'typeC');

      ddi.destroy(qualifier: 'typeC');

      expect(() => ddi.get(qualifier: 'typeC'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Try to destroy a undestroyable Factory Singleton bean', () {
      ddi.register(
          factory: SingletonFactoryDestroyGet.new.builder
              .asSingleton(destroyable: false));

      final instance1 = ddi.get<SingletonFactoryDestroyGet>();

      ddi.destroy<SingletonFactoryDestroyGet>();

      final instance2 = ddi.get<SingletonFactoryDestroyGet>();

      expect(instance1, same(instance2));
    });

    test('Try to register again a undestroyable Factory Singleton bean', () {
      ddi.register(
          factory: SingletonFactoryDestroyRegister.new.builder
              .asSingleton(destroyable: false));

      ddi.get<SingletonFactoryDestroyRegister>();

      ddi.destroy<SingletonFactoryDestroyRegister>();

      expect(
          () => ddi.register(
              factory:
                  SingletonFactoryDestroyRegister.new.builder.asSingleton()),
          throwsA(isA<DuplicatedBeanException>()));
    });

    test('Retrieve Factory Singleton with Custom Parameter', () {
      expect(() => FactoryParameter.new.builder.asSingleton().register(),
          throwsA(isA<BeanNotFoundException>()));
    });
  });
}
