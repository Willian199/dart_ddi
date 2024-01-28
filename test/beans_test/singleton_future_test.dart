import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:test/test.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/b.dart';
import '../clazz_samples/c.dart';
import '../clazz_samples/undestroyable/singleton_destroy_get.dart';

void singletonFuture() {
  group('DDI Singleton Future Basic Tests', () {
    void registerSingletonBeans() {
      DDI.instance.registerApplication(C.new);
      DDI.instance.registerApplication<FutureOr<B>>(
          () => Future.value(B(DDI.instance())));
      DDI.instance.registerApplication(() async => A(await DDI.instance()));
    }

    void removeSingletonBeans() {
      DDI.instance.destroy<Future<A>>();
      DDI.instance.destroy<FutureOr<B>>();
      DDI.instance.destroy<C>();
    }

    test('Register and retrieve singleton bean', () async {
      ///Where is Singleton, should the register in the correct order
      registerSingletonBeans();

      final instance1 = await DDI.instance.get<Future<A>>();
      final instance2 = await DDI.instance.get<Future<A>>();

      expect(instance1, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeSingletonBeans();
    });

    test('Retrieve singleton bean after a "child" bean is diposed', () async {
      registerSingletonBeans();

      final instance = await DDI.instance.get<Future<A>>();

      DDI.instance.destroy<C>();
      final instance1 = await DDI.instance.get<Future<A>>();
      expect(instance1, same(instance));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeSingletonBeans();
    });

    test('Retrieve singleton bean after a second "child" bean is diposed',
        () async {
      registerSingletonBeans();

      final instance = await DDI.instance.get<Future<A>>();

      DDI.instance.destroy<FutureOr<B>>();
      final instance1 = await DDI.instance.get<Future<A>>();
      expect(instance1, same(instance));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeSingletonBeans();
    });

    test('Try to retrieve singleton bean after removed', () {
      DDI.instance.registerSingleton(() => Future.value(C()));

      DDI.instance.get<Future<C>>();

      DDI.instance.destroy<Future<C>>();

      expect(() => DDI.instance.get<Future<C>>(), throwsA(isA<BeanNotFound>()));
    });

    test('Create, get and remove a qualifier bean', () {
      DDI.instance
          .registerSingleton(() => Future.value(C()), qualifier: 'typeC');

      DDI.instance.get(qualifier: 'typeC');

      DDI.instance.destroy(qualifier: 'typeC');

      expect(() => DDI.instance.get(qualifier: 'typeC'),
          throwsA(isA<BeanNotFound>()));
    });

    test('Try to destroy a undestroyable Singleton bean', () {
      DDI.instance.registerSingleton(() => Future.value(SingletonDestroyGet()),
          destroyable: false);

      final instance1 = DDI.instance.get<Future<SingletonDestroyGet>>();

      DDI.instance.destroy<Future<SingletonDestroyGet>>();

      final instance2 = DDI.instance.get<Future<SingletonDestroyGet>>();

      expect(instance1, same(instance2));
    });

    test('Register and retrieve Future delayed Singleton bean', () async {
      DDI.instance.registerSingleton(() async {
        final C value = await Future.delayed(const Duration(seconds: 2), C.new);
        return value;
      });

      final C intance = await DDI.instance.get<Future<C>>();

      DDI.instance.destroy<Future<C>>(qualifier: 'typeC');

      await expectLater(intance.value, 1);
    });

    test('Try to retrieve Singleton bean using Future', () async {
      DDI.instance.registerSingleton(C.new);
      DDI.instance.registerSingleton(() async => B(DDI.instance()));
      DDI.instance.registerSingleton(() async => A(await DDI.instance()));

      //This happens because A(await DDI.instance()) transform to A(await DDI.instance<FutureOr<B>>())
      expect(() => DDI.instance.get<Future<A>>(), throwsA(isA<BeanNotFound>()));

      DDI.instance.destroy<Future<A>>();
      DDI.instance.destroy<Future<B>>();
      DDI.instance.destroy<C>();
    });

    test('Register and retrieve Singleton bean using FutureOr', () async {
      DDI.instance.registerSingleton(C.new);
      DDI.instance
          .registerSingleton<FutureOr<B>>(() async => B(DDI.instance()));
      DDI.instance.registerSingleton(() async => A(await DDI.instance()));

      final instance1 = await DDI.instance.get<Future<A>>();
      final instance2 = await DDI.instance.get<Future<A>>();

      expect(instance1, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      DDI.instance.destroy<Future<A>>();
      DDI.instance.destroy<FutureOr<B>>();
      DDI.instance.destroy<C>();
    });
    test(
        'Retrieve Singleton bean after a "child" bean is disposed using Future',
        () async {
      DDI.instance.registerSingleton(C.new);
      DDI.instance
          .registerSingleton<FutureOr<B>>(() async => B(DDI.instance()));
      DDI.instance.registerSingleton(() async => A(await DDI.instance()));

      final instance1 = await DDI.instance.get<Future<A>>();

      DDI.instance.dispose<C>();
      final instance2 = await DDI.instance.get<Future<A>>();

      expect(instance1, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      DDI.instance.destroy<Future<A>>();
      DDI.instance.destroy<FutureOr<B>>();
      DDI.instance.destroy<C>();
    });

    test('Retrieve Singleton bean Stream', () async {
      DDI.instance.registerSingleton(StreamController<C>.new);

      final StreamController<C> streamController = DDI.instance();

      streamController.add(C());
      streamController.close();

      final instance = await streamController.stream.first;

      expect(instance, isA<C>());

      DDI.instance.destroy<StreamController<C>>();
    });
  });
}
