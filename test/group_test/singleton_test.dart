import 'package:flutter_test/flutter_test.dart';

import 'package:dart_ddi/dart_ddi.dart';

import '../clazz_test/a.dart';
import '../clazz_test/b.dart';
import '../clazz_test/c.dart';
import '../clazz_test/undestroyable/singleton_destroy_get.dart';
import '../clazz_test/undestroyable/singleton_destroy_register.dart';

void singleton() {
  group('DDI Singleton Basic Tests', () {
    void registerSingletonBeans() {
      DDI.instance.registerSingleton(() => C());
      DDI.instance.registerSingleton(() => B(DDI.instance()));
      DDI.instance.registerSingleton(() => A(DDI.instance()));
    }

    void removeSingletonBeans() {
      DDI.instance.destroy<A>();
      DDI.instance.destroy<B>();
      DDI.instance.destroy<C>();
    }

    test('Register and retrieve singleton bean', () {
      ///Where is Singleton, should the register in the correct order
      registerSingletonBeans();

      final instance1 = DDI.instance.get<A>();
      final instance2 = DDI.instance.get<A>();

      expect(instance1, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeSingletonBeans();
    });

    test('Retrieve singleton bean after a "child" bean is diposed', () {
      registerSingletonBeans();

      final instance = DDI.instance.get<A>();

      DDI.instance.destroy<C>();
      final instance1 = DDI.instance.get<A>();
      expect(instance1, same(instance));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeSingletonBeans();
    });

    test('Retrieve singleton bean after a second "child" bean is diposed', () {
      registerSingletonBeans();

      final instance = DDI.instance.get<A>();

      DDI.instance.destroy<B>();
      final instance1 = DDI.instance.get<A>();
      expect(instance1, same(instance));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeSingletonBeans();
    });

    test('Try to retrieve singleton bean after removed', () {
      DDI.instance.registerSingleton(() => C());

      DDI.instance.get<C>();

      DDI.instance.destroy<C>();

      expect(() => DDI.instance.get<C>(),
          throwsA(const TypeMatcher<AssertionError>()));
    });

    test('Create, get and remove a qualifier bean', () {
      DDI.instance.registerSingleton(() => C(), qualifier: 'typeC');

      DDI.instance.get(qualifier: 'typeC');

      DDI.instance.destroy(qualifier: 'typeC');

      expect(() => DDI.instance.get(qualifier: 'typeC'),
          throwsA(const TypeMatcher<AssertionError>()));
    });

    test('Try to destroy a undestroyable Singleton bean', () {
      DDI.instance
          .registerSingleton(() => SingletonDestroyGet(), destroyable: false);

      final instance1 = DDI.instance.get<SingletonDestroyGet>();

      DDI.instance.destroy<SingletonDestroyGet>();

      final instance2 = DDI.instance.get<SingletonDestroyGet>();

      expect(instance1, same(instance2));
    });

    test('Try to register again a undestroyable Singleton bean', () {
      DDI.instance.registerSingleton(() => SingletonDestroyRegister(),
          destroyable: false);

      DDI.instance.get<SingletonDestroyRegister>();

      DDI.instance.destroy<SingletonDestroyRegister>();

      expect(
          () =>
              DDI.instance.registerSingleton(() => SingletonDestroyRegister()),
          throwsA(const TypeMatcher<AssertionError>()));
    });
  });
}
