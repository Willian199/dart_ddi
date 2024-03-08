import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:dart_ddi/src/exception/duplicated_bean.dart';
import 'package:test/test.dart';

import 'package:dart_ddi/dart_ddi.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/b.dart';
import '../clazz_samples/c.dart';
import '../clazz_samples/undestroyable/singleton_destroy_get.dart';
import '../clazz_samples/undestroyable/singleton_destroy_register.dart';

void singleton() {
  group('DDI Singleton Basic Tests', () {
    void registerSingletonBeans() {
      ddi.registerSingleton(C.new);
      ddi.registerSingleton(() => B(ddi()));
      ddi.registerSingleton(() => A(ddi()));
    }

    void removeSingletonBeans() {
      ddi.destroy<A>();
      ddi.destroy<B>();
      ddi.destroy<C>();
    }

    test('Register and retrieve singleton bean', () {
      ///Where is Singleton, should the register in the correct order
      registerSingletonBeans();

      final instance1 = ddi.get<A>();
      final instance2 = ddi.get<A>();

      expect(instance1, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeSingletonBeans();
    });

    test('Retrieve singleton bean after a "child" bean is destroyed', () {
      registerSingletonBeans();

      final instance = ddi.get<A>();

      ddi.destroy<C>();
      final instance1 = ddi.get<A>();
      expect(instance1, same(instance));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      ddi.destroy<A>();
      ddi.destroy<B>();
    });

    test('Retrieve singleton bean after a second "child" bean is destroyed',
        () {
      registerSingletonBeans();

      final instance = ddi.get<A>();

      ddi.destroy<B>();
      ddi.destroy<C>();
      final instance1 = ddi.get<A>();
      expect(instance1, same(instance));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      ddi.destroy<A>();
    });

    test('Try to retrieve singleton bean after removed', () {
      ddi.registerSingleton(() => C());

      ddi.get<C>();

      ddi.destroy<C>();

      expect(() => ddi.get<C>(), throwsA(isA<BeanNotFound>()));
    });

    test('Create, get and remove a qualifier bean', () {
      ddi.registerSingleton(() => C(), qualifier: 'typeC');

      ddi.get(qualifier: 'typeC');

      ddi.destroy(qualifier: 'typeC');

      expect(() => ddi.get(qualifier: 'typeC'), throwsA(isA<BeanNotFound>()));
    });

    test('Try to destroy a undestroyable Singleton bean', () {
      ddi.registerSingleton(() => SingletonDestroyGet(), destroyable: false);

      final instance1 = ddi.get<SingletonDestroyGet>();

      ddi.destroy<SingletonDestroyGet>();

      final instance2 = ddi.get<SingletonDestroyGet>();

      expect(instance1, same(instance2));
    });

    test('Try to register again a undestroyable Singleton bean', () {
      ddi.registerSingleton(() => SingletonDestroyRegister(),
          destroyable: false);

      ddi.get<SingletonDestroyRegister>();

      ddi.destroy<SingletonDestroyRegister>();

      expect(() => ddi.registerSingleton(() => SingletonDestroyRegister()),
          throwsA(isA<DuplicatedBean>()));
    });
  });
}
