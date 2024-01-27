import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:test/test.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/b.dart';
import '../clazz_samples/c.dart';
import '../clazz_samples/undestroyable/application_destroy_get.dart';

void applicationFuture() {
  group('DDI Application Future Basic Tests', () {
    void registerApplicationBeans() {
      DDI.instance.registerApplication(() async => A(await DDI.instance()));
      DDI.instance.registerApplication<FutureOr<B>>(() => Future.value(B(DDI.instance())));
      DDI.instance.registerApplication(C.new);
    }

    void removeApplicationBeans() {
      DDI.instance.destroy<Future<A>>();
      DDI.instance.destroy<FutureOr<B>>();
      DDI.instance.destroy<C>();
    }

    test('Register and retrieve Application bean', () async {
      registerApplicationBeans();

      final instance1 = await DDI.instance.get<Future<A>>();
      final instance2 = await DDI.instance.get<Future<A>>();

      expect(instance1, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Application bean after a "child" bean is diposed', () async {
      registerApplicationBeans();

      final instance = await DDI.instance.get<Future<A>>();

      DDI.instance.dispose<C>();
      final instance1 = await DDI.instance.get<Future<A>>();
      expect(instance1, same(instance));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Application bean after a second "child" bean is diposed', () async {
      registerApplicationBeans();

      final instance = await DDI.instance.get<Future<A>>();

      DDI.instance.dispose<FutureOr<B>>();
      final instance1 = await DDI.instance.get<Future<A>>();
      expect(instance1, same(instance));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Application bean after the last "child" bean is diposed', () async {
      registerApplicationBeans();

      final instance1 = await DDI.instance.get<Future<A>>();

      DDI.instance.dispose<Future<A>>();
      final instance2 = await DDI.instance.get<Future<A>>();

      expect(false, identical(instance1, instance2));
      expect(true, identical(instance1.b, instance2.b));
      expect(true, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Application bean after 2 "child" bean is diposed', () async {
      registerApplicationBeans();

      final instance1 = await DDI.instance.get<Future<A>>();

      DDI.instance.dispose<FutureOr<B>>();
      DDI.instance.dispose<Future<A>>();
      final instance2 = await DDI.instance.get<Future<A>>();

      expect(false, identical(instance1, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(true, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Application bean after 3 "child" bean is diposed', () async {
      registerApplicationBeans();

      final instance1 = await DDI.instance.get<Future<A>>();

      DDI.instance.dispose<C>();
      DDI.instance.dispose<FutureOr<B>>();
      DDI.instance.dispose<Future<A>>();
      final instance2 = await DDI.instance.get<Future<A>>();

      expect(false, identical(instance1, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(false, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Try to retrieve Application bean after disposed', () {
      DDI.instance.registerApplication(() => Future.value(C()));

      final instance1 = DDI.instance.get<Future<C>>();

      DDI.instance.dispose<Future<C>>();

      final instance2 = DDI.instance.get<Future<C>>();

      expect(false, identical(instance1, instance2));

      DDI.instance.destroy<Future<C>>();
    });

    test('Try to retrieve Application bean after removed', () {
      DDI.instance.registerApplication(() => Future.value(C()));

      DDI.instance.get<Future<C>>();

      DDI.instance.destroy<Future<C>>();

      expect(() => DDI.instance.get<Future<C>>(), throwsA(isA<BeanNotFound>()));
    });

    test('Create, get and remove a qualifier bean', () {
      DDI.instance.registerApplication(() => Future.value(C()), qualifier: 'typeC');

      DDI.instance.get(qualifier: 'typeC');

      DDI.instance.destroy(qualifier: 'typeC');

      expect(() => DDI.instance.get(qualifier: 'typeC'), throwsA(isA<BeanNotFound>()));
    });

    test('Try to destroy a undestroyable Application bean', () {
      DDI.instance.registerApplication(() => Future.value(ApplicationDestroyGet()), destroyable: false);

      final instance1 = DDI.instance.get<Future<ApplicationDestroyGet>>();

      DDI.instance.destroy<Future<ApplicationDestroyGet>>();

      final instance2 = DDI.instance.get<Future<ApplicationDestroyGet>>();

      expect(instance1, same(instance2));
    });
    test('Register and retrieve Future Application', () async {
      DDI.instance.registerApplication(() async => A(await DDI.instance<Future<B>>()));
      DDI.instance.registerApplication(() async => B(DDI.instance()));
      DDI.instance.registerApplication(C.new);

      final instance1 = await DDI.instance.get<Future<A>>();
      final instance2 = await DDI.instance.get<Future<A>>();

      expect(instance1, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      DDI.instance.destroy<Future<A>>();
      DDI.instance.destroy<Future<B>>();
      DDI.instance.destroy<C>();
    });

    test('Register and retrieve Future delayed Application bean', () async {
      DDI.instance.registerApplication(() async {
        final C value = await Future.delayed(const Duration(seconds: 2), C.new);
        return value;
      });

      final C intance = await DDI.instance.get<Future<C>>();

      DDI.instance.destroy<Future<C>>(qualifier: 'typeC');

      await expectLater(intance.value, 1);
    });

    test('Try to retrieve Application bean using Future', () async {
      DDI.instance.registerApplication(() async => A(await DDI.instance()));
      DDI.instance.registerApplication(() async => B(DDI.instance()));
      DDI.instance.registerApplication(C.new);

      //This happens because A(await DDI.instance()) transform to A(await DDI.instance<FutureOr<B>>())
      expect(() => DDI.instance.get<Future<A>>(), throwsA(isA<BeanNotFound>()));

      DDI.instance.destroy<Future<A>>();
      DDI.instance.destroy<Future<B>>();
      DDI.instance.destroy<C>();
    });

    test('Register and retrieve Application bean using FutureOr', () async {
      DDI.instance.registerApplication(() async => A(await DDI.instance()));
      DDI.instance.registerApplication<FutureOr<B>>(() async => B(DDI.instance()));
      DDI.instance.registerApplication(C.new);

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
    test('Retrieve Application bean after a "child" bean is disposed using Future', () async {
      DDI.instance.registerApplication(() async => A(await DDI.instance()));
      DDI.instance.registerApplication<FutureOr<B>>(() async => B(DDI.instance()));
      DDI.instance.registerApplication(C.new);

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

    test('Retrieve Application bean Stream', () async {
      DDI.instance.registerApplication(StreamController<C>.new);

      final StreamController<C> streamController = DDI.instance();

      streamController.add(C());
      streamController.close();

      final instance = await streamController.stream.first;

      expect(instance, isA<C>());

      DDI.instance.destroy<StreamController<C>>();
    });
  });
}
