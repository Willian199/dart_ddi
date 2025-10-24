import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:dart_ddi/src/exception/bean_not_ready.dart';
import 'package:dart_ddi/src/exception/duplicated_bean.dart';
import 'package:dart_ddi/src/exception/factory_already_created.dart';
import 'package:test/test.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/b.dart';
import '../clazz_samples/c.dart';
import '../clazz_samples/undestroyable/singleton_destroy_get.dart';
import '../clazz_samples/undestroyable/singleton_destroy_register.dart';

void main() {
  group('DDI Singleton Basic Tests', () {
    tearDownAll(
      () {
        // Still having 2 Bean, because [canDestroy] is false
        expect(ddi.isEmpty, false);
        // SingletonDestroyGet, SingletonDestroyRegister
        expect(ddi.length, 2);
      },
    );

    void registerSingletonBeans() {
      ddi.singleton(C.new);
      ddi.singleton(() => B(ddi()));
      ddi.singleton(() => A(ddi()));
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
      ddi.singleton(() => C());

      ddi.get<C>();

      ddi.destroy<C>();

      expect(() => ddi.get<C>(), throwsA(isA<BeanNotFoundException>()));
    });

    test('Create, get and remove a qualifier bean', () {
      ddi.singleton(() => C(), qualifier: 'typeC');

      ddi.get(qualifier: 'typeC');

      ddi.destroy(qualifier: 'typeC');

      expect(() => ddi.get(qualifier: 'typeC'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Try to destroy a undestroyable Singleton bean', () {
      ddi.singleton(() => SingletonDestroyGet(), canDestroy: false);

      final instance1 = ddi.get<SingletonDestroyGet>();

      ddi.destroy<SingletonDestroyGet>();

      final instance2 = ddi.get<SingletonDestroyGet>();

      expect(instance1, same(instance2));
    });

    test('Try to register again a undestroyable Singleton bean', () {
      ddi.singleton(() => SingletonDestroyRegister(), canDestroy: false);

      ddi.get<SingletonDestroyRegister>();

      ddi.destroy<SingletonDestroyRegister>();

      expect(() => ddi.singleton(() => SingletonDestroyRegister()),
          throwsA(isA<DuplicatedBeanException>()));
    });

    test('Verify if a Bean not registered is Future', () {
      expect(
          () => ddi.isFuture<Object>(), throwsA(isA<BeanNotFoundException>()));
    });

    test('Verify if a Bean not registered is Ready', () {
      expect(
          () => ddi.isReady<Object>(), throwsA(isA<BeanNotFoundException>()));
    });

    test('Disponse a Bean not registered', () {
      expect(() => ddi.dispose<A>(), throwsA(isA<BeanNotFoundException>()));
    });

    test('Call register before passing to DDI', () {
      final c = SingletonFactory(builder: C.new.builder)
        ..register(qualifier: C, apply: (_) {});

      expect(() => ddi.register<C>(factory: c),
          throwsA(isA<FactoryAlreadyCreatedException>()));
    });

    test('Try to get a Bean using a list Future wait', () async {
      await expectLater(
          () => Future.wait<dynamic>([
                ddi.singleton<C>(() async {
                  return C();
                }),
                Future.value(ddi.get<C>()),
              ], eagerError: true),
          throwsA(isA<BeanNotReadyException>()));

      await ddi.destroy<C>();

      expect(ddi.isRegistered<C>(), false);
    });
  });
}
