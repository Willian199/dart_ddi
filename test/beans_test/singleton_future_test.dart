import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:test/test.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/b.dart';
import '../clazz_samples/c.dart';
import '../clazz_samples/future_post_construct.dart';
import '../clazz_samples/undestroyable/future_singleton_destroy_get.dart';

void main() {
  group('DDI Singleton Future Basic Tests', () {
    Future<void> registerSingletonBeans() async {
      DDI.instance.singleton(C.new);
      await DDI.instance.singleton<B>(() => Future.value(B(DDI.instance())));
      await DDI.instance
          .singleton(() async => A(await DDI.instance.getAsync()));
    }

    void removeSingletonBeans() {
      DDI.instance.destroy<A>();
      DDI.instance.destroy<B>();
      DDI.instance.destroy<C>();
    }

    test('Register and retrieve singleton bean', () async {
      ///Where is Singleton, should the register in the correct order
      await registerSingletonBeans();

      final instance1 = await DDI.instance.getAsync<A>();
      final instance2 = await DDI.instance.getAsync<A>();

      expect(instance1, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeSingletonBeans();
    });

    test('Retrieve singleton bean after a "child" bean is diposed', () async {
      await registerSingletonBeans();

      final instance = await DDI.instance.getAsync<A>();

      DDI.instance.destroy<C>();
      final instance1 = await DDI.instance.getAsync<A>();
      expect(instance1, same(instance));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      DDI.instance.destroy<A>();
      DDI.instance.destroy<B>();
    });

    test('Retrieve singleton bean after a second "child" bean is diposed',
        () async {
      await registerSingletonBeans();

      final instance = await DDI.instance.getAsync<A>();

      DDI.instance.destroy<B>();
      DDI.instance.destroy<C>();
      final instance1 = await DDI.instance.getAsync<A>();
      expect(instance1, same(instance));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      DDI.instance.destroy<A>();
    });

    test('Try to retrieve singleton bean after removed', () async {
      await DDI.instance.singleton(() => Future.value(C()));

      DDI.instance.getAsync<C>();

      DDI.instance.destroy<C>();

      expect(() => DDI.instance.getAsync<C>(),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Create, get and remove a qualifier bean', () async {
      await DDI.instance.singleton(() => Future.value(C()), qualifier: 'typeC');

      DDI.instance.getAsync(qualifier: 'typeC');

      DDI.instance.destroy(qualifier: 'typeC');

      expect(() => DDI.instance.getAsync(qualifier: 'typeC'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Try to destroy a undestroyable Singleton bean', () async {
      await DDI.instance.singleton(
          () => Future.value(FutureSingletonDestroyGet()),
          canDestroy: false);

      final instance1 =
          await DDI.instance.getAsync<FutureSingletonDestroyGet>();

      DDI.instance.destroy<FutureSingletonDestroyGet>();

      final instance2 =
          await DDI.instance.getAsync<FutureSingletonDestroyGet>();

      expect(instance1, same(instance2));
    });

    test('Register and retrieve Future delayed Singleton bean', () async {
      await DDI.instance.singleton<C>(() async {
        final C value = await Future.delayed(const Duration(seconds: 1), C.new);
        return value;
      });

      final C intance = await DDI.instance.getAsync<C>();

      DDI.instance.destroy<C>();

      await expectLater(intance.value, 1);
    });

    test(
        'Retrieve Singleton bean after a "child" bean is disposed using Future',
        () async {
      DDI.instance.singleton(C.new);
      await DDI.instance.singleton<B>(() => B(DDI.instance()));
      await DDI.instance
          .singleton(() async => A(await DDI.instance.getAsync()));

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

    test('Retrieve Singleton bean Stream', () async {
      DDI.instance.singleton(StreamController<C>.new);

      final StreamController<C> streamController = DDI.instance();

      streamController.add(C());
      streamController.close();

      final instance = await streamController.stream.first;

      expect(instance, isA<C>());

      DDI.instance.destroy<StreamController<C>>();
    });

    test('Register a Singleton bean with Future Post Construct', () async {
      await ddi.singleton<FuturePostConstruct>(() async {
        await Future.delayed(const Duration(milliseconds: 10));

        return Future.value(FuturePostConstruct());
      });

      final FuturePostConstruct instance = ddi.get();

      expect(instance.value, 10);

      ddi.destroy<FuturePostConstruct>();
    });

    test('Register a Singleton class with PostConstruct mixin', () async {
      Future<FuturePostConstruct> localTest() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return FuturePostConstruct();
      }

      await DDI.instance.register<FuturePostConstruct>(
        factory: SingletonFactory(builder: localTest.builder),
        qualifier: 'FuturePostConstruct',
      );

      final FuturePostConstruct instance =
          await DDI.instance.getAsync(qualifier: 'FuturePostConstruct');

      expect(instance.value, 10);

      DDI.instance.destroy(qualifier: 'FuturePostConstruct');

      expect(() => DDI.instance.get(qualifier: 'FuturePostConstruct'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Register a Singleton class with Future PostConstruct mixin',
        () async {
      Future<FuturePostConstruct> localTest() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return FuturePostConstruct();
      }

      await DDI.instance.register<FuturePostConstruct>(
        factory: SingletonFactory(
          builder: CustomBuilder(
            producer: localTest,
            parametersType: [],
            returnType: FuturePostConstruct,
            isFuture: true,
          ),
        ),
      );

      expect(DDI.instance.isFuture<FuturePostConstruct>(), true);
      expect(DDI.instance.getByType<FuturePostConstruct>().length, 1);

      final FuturePostConstruct instance = await DDI.instance.getAsync();

      expect(instance.value, 10);

      DDI.instance.destroy<FuturePostConstruct>();

      expect(DDI.instance.isRegistered<FuturePostConstruct>(), false);
    });

    test(
        'Register a Singleton class with Future PostConstruct mixin and qualifier',
        () async {
      Future<FuturePostConstruct> localTest() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return FuturePostConstruct();
      }

      await DDI.instance.register<Future<FuturePostConstruct>>(
        factory: SingletonFactory(
          builder: CustomBuilder(
            producer: localTest,
            parametersType: [],
            returnType: FuturePostConstruct,
            isFuture: true,
          ),
        ),
        qualifier: 'FuturePostConstruct',
      );

      expect(DDI.instance.isFuture(qualifier: 'FuturePostConstruct'), true);

      expect(DDI.instance.getByType<Future<FuturePostConstruct>>().length, 1);

      final FuturePostConstruct instance =
          await DDI.instance.getAsync(qualifier: 'FuturePostConstruct');

      expect(instance.value, 10);

      DDI.instance.destroy(qualifier: 'FuturePostConstruct');

      expect(
          DDI.instance.isRegistered(qualifier: 'FuturePostConstruct'), false);
    });

    test(
        'Register a Singleton Future class with Future PostConstruct mixin and qualifier',
        () async {
      Future<FuturePostConstruct> localTest() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return FuturePostConstruct();
      }

      await DDI.instance.register<Future<FuturePostConstruct>>(
        factory: SingletonFactory(
          builder: CustomBuilder(
            producer: localTest,
            parametersType: [],
            returnType: FuturePostConstruct,
            isFuture: true,
          ),
        ),
        qualifier: 'FuturePostConstruct',
      );

      expect(DDI.instance.isFuture(qualifier: 'FuturePostConstruct'), true);

      expect(DDI.instance.getByType<Future<FuturePostConstruct>>().length, 1);

      final FuturePostConstruct futureInstance =
          await DDI.instance.get(qualifier: 'FuturePostConstruct');

      expect(futureInstance.value, 10);

      final FuturePostConstruct cachedInstance = await DDI.instance
          .get<Future<FuturePostConstruct>>(qualifier: 'FuturePostConstruct');

      expect(cachedInstance.value, 10);

      expect(identical(cachedInstance, futureInstance), true);

      DDI.instance.destroy(qualifier: 'FuturePostConstruct');

      expect(
          DDI.instance.isRegistered(qualifier: 'FuturePostConstruct'), false);
    });
  });
}
