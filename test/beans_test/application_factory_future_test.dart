import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:test/test.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/b.dart';
import '../clazz_samples/c.dart';
import '../clazz_samples/multi_inject.dart';
import '../clazz_samples/undestroyable/future_application_factory_destroy_get.dart';

void applicationFactoryFuture() {
  group('DDI Factory Application Future Basic Tests', () {
    void registerApplicationBeans() {
      DDI.instance.register(factoryClazz: MultiInject.new.factory.asApplication());

      DDI.instance.register<A>(
        factoryClazz: FactoryClazz.application(
          clazzFactory: () async {
            return A(await DDI.instance.getAsync<B>());
          }.factory,
        ),
      );

      DDI.instance.register<B>(
        factoryClazz: FactoryClazz.application(
          clazzFactory: () async {
            await Future.delayed(const Duration(milliseconds: 200));
            return B(DDI.instance());
          }.factory,
        ),
      );
      DDI.instance.register(
        factoryClazz: C.new.factory.asApplication(),
      );
    }

    void removeApplicationBeans() {
      DDI.instance.destroy<MultiInject>();
      DDI.instance.destroy<A>();
      DDI.instance.destroy<B>();
      DDI.instance.destroy<C>();
    }

    test('Register and retrieve Factory Application bean', () async {
      registerApplicationBeans();

      final instance1 = await DDI.instance.getAsync<MultiInject>();
      final instance2 = await DDI.instance.getAsync<A>();

      expect(instance1.a, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Factory Application bean after a "child" bean is diposed', () async {
      registerApplicationBeans();

      final instance = await DDI.instance.getAsync<MultiInject>();

      DDI.instance.dispose<C>();
      final instance1 = await DDI.instance.getAsync<A>();
      expect(instance1, same(instance.a));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Factory Application bean after a second "child" bean is diposed', () async {
      registerApplicationBeans();

      final instance = await DDI.instance.getAsync<MultiInject>();

      DDI.instance.dispose<B>();
      final instance1 = await DDI.instance.getAsync<A>();
      expect(instance1, same(instance.a));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Factory Application bean after the last "child" bean is diposed', () async {
      registerApplicationBeans();

      final instance1 = await DDI.instance.getAsync<MultiInject>();

      DDI.instance.dispose<A>();
      final instance2 = await DDI.instance.getAsync<A>();

      expect(false, identical(instance1.a, instance2));
      expect(true, identical(instance1.b, instance2.b));
      expect(true, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Factory Application bean after 2 "child" bean is diposed', () async {
      registerApplicationBeans();

      final instance1 = await DDI.instance.getAsync<MultiInject>();

      DDI.instance.dispose<B>();
      DDI.instance.dispose<A>();
      final instance2 = await DDI.instance.getAsync<A>();

      expect(false, identical(instance1.a, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(true, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Factory Application bean after 3 "child" bean is diposed', () async {
      registerApplicationBeans();

      final instance1 = await DDI.instance.getAsync<MultiInject>();

      DDI.instance.dispose<C>();
      DDI.instance.dispose<B>();
      DDI.instance.dispose<A>();
      final instance2 = await DDI.instance.getAsync<A>();

      expect(false, identical(instance1.a, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(false, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Try to retrieve Factory Application bean after disposed', () async {
      DDI.instance.register(
        factoryClazz: () {
          return Future.value(C());
        }.factory.asApplication(),
      );

      final instance1 = await DDI.instance.getAsync<C>();

      DDI.instance.dispose<C>();

      final instance2 = DDI.instance.getAsync<C>();

      expect(false, identical(instance1, instance2));

      DDI.instance.destroy<C>();
    });

    test('Try to retrieve Factory Application bean after removed', () {
      DDI.instance.register(
        factoryClazz: () {
          return Future.value(C());
        }.factory.asApplication(),
      );

      DDI.instance.getAsync<C>();

      DDI.instance.destroy<C>();

      expect(() => DDI.instance.getAsync<C>(), throwsA(isA<BeanNotFoundException>()));
    });

    test('Create, get and remove a Factory qualifier bean', () {
      DDI.instance.register(
        qualifier: 'typeC',
        factoryClazz: () {
          return Future.value(C());
        }.factory.asApplication(),
      );

      DDI.instance.getAsync(qualifier: 'typeC');

      DDI.instance.destroy(qualifier: 'typeC');

      expect(() => DDI.instance.getAsync(qualifier: 'typeC'), throwsA(isA<BeanNotFoundException>()));
    });

    test('Try to destroy a undestroyable Factory Application bean', () async {
      DDI.instance.register(
        factoryClazz: FactoryClazz.application(
          destroyable: false,
          clazzFactory: () {
            return Future.value(FutureApplicationFactoryDestroyGet());
          }.factory,
        ),
      );

      final instance1 = await DDI.instance.getAsync<FutureApplicationFactoryDestroyGet>();

      DDI.instance.destroy<FutureApplicationFactoryDestroyGet>();

      final instance2 = await DDI.instance.getAsync<FutureApplicationFactoryDestroyGet>();

      expect(instance1, same(instance2));
    });
    test('Register and retrieve Future Factory Application', () async {
      DDI.instance.register<A>(
        factoryClazz: FactoryClazz.application(
          clazzFactory: () async {
            return A(await DDI.instance.getAsync<B>());
          }.factory,
        ),
      );

      DDI.instance.register<B>(
        factoryClazz: FactoryClazz.application(
          clazzFactory: () async {
            await Future.delayed(const Duration(milliseconds: 200));
            return B(DDI.instance());
          }.factory,
        ),
      );
      DDI.instance.register(factoryClazz: C.new.factory.asApplication());

      final instance1 = await DDI.instance.getAsync<A>();
      final instance2 = await DDI.instance.getAsync<A>();

      expect(instance1, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      DDI.instance.destroy<A>();
      DDI.instance.destroy<B>();
      DDI.instance.destroy<C>();
    });

    test('Register and retrieve Future delayed Factory Application bean', () async {
      DDI.instance.register<C>(
        factoryClazz: FactoryClazz.application(
          clazzFactory: () async {
            final C value = await Future.delayed(const Duration(seconds: 2), C.new);
            return value;
          }.factory,
        ),
      );

      final C intance = await DDI.instance.getAsync<C>();

      DDI.instance.destroy<C>();

      await expectLater(intance.value, 1);
    });

    test('Try to retrieve Factory Application bean using Future', () async {
      DDI.instance.register(
        factoryClazz: FactoryClazz.application(
          clazzFactory: () async {
            return A(await DDI.instance.getAsync<B>());
          }.factory,
        ),
      );

      DDI.instance.register(
        factoryClazz: FactoryClazz.application(
          clazzFactory: () async {
            await Future.delayed(const Duration(milliseconds: 200));
            return B(DDI.instance());
          }.factory,
        ),
      );
      DDI.instance.register(factoryClazz: C.new.factory.asApplication());
      //This happens because A(await DDI.instance()) transform to A(await DDI.instance<FutureOr<B>>())
      expect(() => DDI.instance.getAsync<A>(), throwsA(isA<BeanNotFoundException>()));

      DDI.instance.destroy<A>();
      DDI.instance.destroy<B>();
      DDI.instance.destroy<C>();
    });

    test('Register and retrieve Factory Application bean using FutureOr', () async {
      DDI.instance.register(
        factoryClazz: FactoryClazz.application(
          clazzFactory: () async {
            return A(await DDI.instance.getAsync());
          }.factory,
        ),
      );

      DDI.instance.register<B>(
        factoryClazz: FactoryClazz.application(
          clazzFactory: () async {
            await Future.delayed(const Duration(milliseconds: 200));
            return B(DDI.instance());
          }.factory,
        ),
      );

      DDI.instance.register(factoryClazz: C.new.factory.asApplication());

      final instance1 = await DDI.instance.getAsync<A>();
      final instance2 = await DDI.instance.getAsync<A>();

      expect(instance1, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      DDI.instance.destroy<A>();
      DDI.instance.destroy<B>();
      DDI.instance.destroy<C>();
    });
    test('Retrieve Factory Application bean after a "child" bean is disposed using Future', () async {
      DDI.instance.register(
        factoryClazz: FactoryClazz.application(
          clazzFactory: () async {
            return A(await DDI.instance.getAsync());
          }.factory,
        ),
      );

      DDI.instance.register<B>(
        factoryClazz: FactoryClazz.application(
          clazzFactory: () async {
            await Future.delayed(const Duration(milliseconds: 200));
            return B(DDI.instance());
          }.factory,
        ),
      );

      DDI.instance.register(factoryClazz: C.new.factory.asApplication());

      final instance1 = await DDI.instance.getAsync<A>();

      DDI.instance.dispose<C>();
      final instance2 = await DDI.instance.getAsync<A>();

      expect(instance1, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      DDI.instance.destroy<A>();
      DDI.instance.destroy<B>();
      DDI.instance.destroy<C>();
    });

    test('Retrieve Factory Application bean Stream', () async {
      DDI.instance.register(factoryClazz: StreamController<C>.new.factory.asApplication());

      final StreamController<C> streamController = DDI.instance();

      streamController.add(C());
      streamController.close();

      final instance = await streamController.stream.first;

      expect(instance, isA<C>());

      DDI.instance.destroy<StreamController<C>>();
    });
  });
}
