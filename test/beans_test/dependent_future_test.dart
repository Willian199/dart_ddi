import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:test/test.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/b.dart';
import '../clazz_samples/c.dart';
import '../clazz_samples/future_post_construct.dart';
import '../clazz_samples/undestroyable/future_dependent_destroy_get.dart';

void main() {
  group('DDI Dependent Future Basic Tests', () {
    tearDownAll(
      () {
        // Still having 1 Bean, because [canDestroy] is false
        expect(ddi.isEmpty, false);
        // FutureDependentDestroyGet
        expect(ddi.length, 1);
      },
    );

    void registerDependentBeans() {
      DDI.instance.dependent(() async => A(await DDI.instance.getAsync()));
      DDI.instance.dependent<B>(() => Future.value(B(DDI.instance())));
      DDI.instance.dependent(C.new);
    }

    void removeDependentBeans() {
      DDI.instance.destroy<A>();
      DDI.instance.destroy<B>();
      DDI.instance.destroy<C>();
    }

    test('Register and retrieve Dependent bean', () async {
      registerDependentBeans();

      final instance1 = await DDI.instance.getAsync<A>();
      final instance2 = await DDI.instance.getAsync<A>();

      expect(false, identical(instance1, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(false, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeDependentBeans();
    });

    test('Retrieve Dependent bean after a "child" bean is diposed', () async {
      registerDependentBeans();

      final instance = await DDI.instance.getAsync<A>();

      DDI.instance.dispose<C>();
      final instance1 = await DDI.instance.getAsync<A>();
      expect(false, identical(instance1, instance));
      expect(false, identical(instance1.b, instance.b));
      expect(false, identical(instance1.b.c, instance.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeDependentBeans();
    });

    test('Retrieve Dependent bean after a second "child" bean is diposed',
        () async {
      registerDependentBeans();

      final instance = await DDI.instance.getAsync<A>();

      DDI.instance.dispose<B>();
      final instance1 = await DDI.instance.getAsync<A>();
      expect(false, identical(instance1, instance));
      expect(false, identical(instance1.b, instance.b));
      expect(false, identical(instance1.b.c, instance.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeDependentBeans();
    });

    test('Try to retrieve Dependent bean after disposed', () async {
      DDI.instance.dependent(() => Future.value(C()));

      final instance1 = await DDI.instance.getAsync<C>();

      DDI.instance.dispose<C>();

      final instance2 = await DDI.instance.getAsync<C>();

      expect(false, identical(instance1, instance2));

      DDI.instance.destroy<C>();
    });

    test('Try to retrieve Dependent bean after removed', () async {
      DDI.instance.dependent(() => Future.value(C()));

      await DDI.instance.getAsync<C>();

      DDI.instance.destroy<C>();

      expect(
          () => DDI.instance.get<C>(), throwsA(isA<BeanNotFoundException>()));
    });

    test('Create, get and remove a qualifier bean', () async {
      DDI.instance.dependent(() => Future.value(C()), qualifier: 'typeC');

      final instance1 = await DDI.instance.getAsync(qualifier: 'typeC');
      final instance2 = DDI.instance.getAsync(qualifier: 'typeC');

      expect(false, identical(instance1, instance2));

      DDI.instance.destroy(qualifier: 'typeC');

      expect(() => DDI.instance.get(qualifier: 'typeC'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Try to destroy a undestroyable Dependent bean', () async {
      DDI.instance.dependent(() => Future.value(FutureDependentDestroyGet()),
          canDestroy: false);

      final FutureDependentDestroyGet instance1 = await DDI.instance.getAsync();

      DDI.instance.destroy<FutureDependentDestroyGet>();

      final instance2 =
          await DDI.instance.getAsync<FutureDependentDestroyGet>();

      expect(instance2, isNotNull);
      expect(false, identical(instance1, instance2));
    });

    test('Register and retrieve Future delayed Dependent bean', () async {
      DDI.instance.dependent(() async {
        final C value = await Future.delayed(const Duration(seconds: 2), C.new);
        return value;
      });

      final C intance = await DDI.instance.getAsync<C>();

      await expectLater(intance.value, 1);

      DDI.instance.destroy<C>();
    });

    test(
        'Retrieve Dependent bean after a "child" bean is disposed using Future',
        () async {
      DDI.instance.dependent(() async => A(await DDI.instance.getAsync()));
      DDI.instance.dependent<B>(() => B(DDI.instance()));
      DDI.instance.dependent(C.new);

      final instance1 = await DDI.instance.getAsync<A>();

      DDI.instance.dispose<C>();
      final instance2 = await DDI.instance.getAsync<A>();

      expect(false, identical(instance1, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(false, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance1.b.c.value));

      DDI.instance.destroy<A>();
      DDI.instance.destroy<B>();
      DDI.instance.destroy<C>();
    });

    test('Retrieve Dependent bean Stream', () async {
      DDI.instance.dependent(StreamController<C>.new);

      final StreamController<C> streamController = DDI.instance();

      streamController.add(C());
      streamController.close();

      final instance = await streamController.stream.first;

      expect(instance, isA<C>());

      DDI.instance.destroy<StreamController<C>>();
    });

    test('Register a Dependent class with Future PostConstruct mixin',
        () async {
      Future<FuturePostConstruct> localTest() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return FuturePostConstruct();
      }

      DDI.instance.register<FuturePostConstruct>(
        factory: DependentFactory(
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
        'Register a Dependent class with Future PostConstruct mixin and qualifier',
        () async {
      Future<FuturePostConstruct> localTest() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return FuturePostConstruct();
      }

      DDI.instance.register<FuturePostConstruct>(
        factory: DependentFactory(
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

      expect(DDI.instance.getByType<FuturePostConstruct>().length, 1);

      final FuturePostConstruct instance =
          await DDI.instance.getAsync(qualifier: 'FuturePostConstruct');

      expect(instance.value, 10);

      DDI.instance.destroy(qualifier: 'FuturePostConstruct');

      expect(
          DDI.instance.isRegistered(qualifier: 'FuturePostConstruct'), false);
    });

    test(
        'Register a Dependent Future class with Future PostConstruct mixin and qualifier',
        () async {
      Future<FuturePostConstruct> localTest() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return FuturePostConstruct();
      }

      DDI.instance.register<Future<FuturePostConstruct>>(
        factory: DependentFactory(
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
  });
}
