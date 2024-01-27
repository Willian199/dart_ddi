import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:test/test.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/b.dart';
import '../clazz_samples/c.dart';
import '../clazz_samples/undestroyable/session_destroy_get.dart';

void sessionFuture() {
  group('DDI Session Future Basic Tests', () {
    void registerSessionBeans() {
      DDI.instance.registerSession(() async => A(await DDI.instance()));
      DDI.instance.registerSession<FutureOr<B>>(() => Future.value(B(DDI.instance())));
      DDI.instance.registerSession(C.new);
    }

    void removeSessionBeans() {
      DDI.instance.destroy<Future<A>>();
      DDI.instance.destroy<FutureOr<B>>();
      DDI.instance.destroy<C>();
    }

    test('Register and retrieve Session bean', () async {
      registerSessionBeans();

      final instance1 = await DDI.instance.get<Future<A>>();
      final instance2 = await DDI.instance.get<Future<A>>();

      expect(instance1, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeSessionBeans();
    });

    test('Retrieve Session bean after a "child" bean is diposed', () async {
      registerSessionBeans();

      final instance = await DDI.instance.get<Future<A>>();

      DDI.instance.dispose<C>();
      final instance1 = await DDI.instance.get<Future<A>>();
      expect(instance1, same(instance));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeSessionBeans();
    });

    test('Retrieve Session bean after a second "child" bean is diposed', () async {
      registerSessionBeans();

      final instance = await DDI.instance.get<Future<A>>();

      DDI.instance.dispose<C>();
      DDI.instance.dispose<FutureOr<B>>();
      final instance1 = await DDI.instance.get<Future<A>>();
      expect(instance1, same(instance));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeSessionBeans();
    });

    test('Retrieve Session bean after the last "child" bean is diposed', () async {
      registerSessionBeans();

      final instance1 = await DDI.instance.get<Future<A>>();

      DDI.instance.dispose<Future<A>>();
      final instance2 = await DDI.instance.get<Future<A>>();

      expect(false, identical(instance1, instance2));
      expect(true, identical(instance1.b, instance2.b));
      expect(true, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeSessionBeans();
    });

    test('Retrieve Session bean after 2 "child" bean is diposed', () async {
      registerSessionBeans();

      final instance1 = await DDI.instance.get<Future<A>>();

      DDI.instance.dispose<FutureOr<B>>();
      DDI.instance.dispose<Future<A>>();
      final instance2 = await DDI.instance.get<Future<A>>();

      expect(false, identical(instance1, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(true, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeSessionBeans();
    });

    test('Retrieve Session bean after 3 "child" bean is diposed', () async {
      registerSessionBeans();

      final instance1 = await DDI.instance.get<Future<A>>();

      DDI.instance.dispose<C>();
      DDI.instance.dispose<FutureOr<B>>();
      DDI.instance.dispose<Future<A>>();
      final instance2 = await DDI.instance.get<Future<A>>();

      expect(false, identical(instance1, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(false, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeSessionBeans();
    });

    test('Try to retrieve Session bean after disposed', () {
      DDI.instance.destroy<Future<C>>();

      DDI.instance.registerSession(() => Future.value(C()));

      final instance1 = DDI.instance.get<Future<C>>();

      DDI.instance.dispose<Future<C>>();

      final instance2 = DDI.instance.get<Future<C>>();

      expect(false, identical(instance1, instance2));
      DDI.instance.destroy<Future<C>>();
    });

    test('Try to retrieve Session bean after removed', () {
      DDI.instance.registerSession(() => Future.value(C()));

      DDI.instance.get<Future<C>>();

      DDI.instance.destroy<Future<C>>();

      expect(() => DDI.instance.get<Future<C>>(), throwsA(isA<BeanNotFound>()));
    });

    test('Create, get and remove a qualifier bean', () {
      DDI.instance.registerSession(() => Future.value(C()), qualifier: 'typeC');

      DDI.instance.get(qualifier: 'typeC');

      DDI.instance.destroy(qualifier: 'typeC');

      expect(() => DDI.instance.get(qualifier: 'typeC'), throwsA(isA<BeanNotFound>()));
    });

    test('Try to destroy a undestroyable Session bean', () {
      DDI.instance.registerSession(() => Future.value(SessionDestroyGet()), destroyable: false);

      final instance1 = DDI.instance.get<Future<SessionDestroyGet>>();

      DDI.instance.destroy<Future<SessionDestroyGet>>();

      final instance2 = DDI.instance.get<Future<SessionDestroyGet>>();

      expect(instance1, same(instance2));
    });

    test('Register and retrieve Future delayed Session bean', () async {
      DDI.instance.registerSession(() async {
        final C value = await Future.delayed(const Duration(seconds: 2), C.new);
        return value;
      });

      final C intance = await DDI.instance.get<Future<C>>();

      DDI.instance.destroy<Future<C>>(qualifier: 'typeC');

      await expectLater(intance.value, 1);
    });

    test('Try to retrieve Session bean using Future', () async {
      DDI.instance.registerSession(() async => A(await DDI.instance()));
      DDI.instance.registerSession(() async => B(DDI.instance()));
      DDI.instance.registerSession(C.new);

      //This happens because A(await DDI.instance()) transform to A(await DDI.instance<FutureOr<B>>())
      expect(() => DDI.instance.get<Future<A>>(), throwsA(isA<BeanNotFound>()));

      DDI.instance.destroy<Future<A>>();
      DDI.instance.destroy<Future<B>>();
      DDI.instance.destroy<C>();
    });

    test('Register and retrieve Session bean using FutureOr', () async {
      DDI.instance.registerSession(() async => A(await DDI.instance()));
      DDI.instance.registerSession<FutureOr<B>>(() async => B(DDI.instance()));
      DDI.instance.registerSession(C.new);

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
    test('Retrieve Session bean after a "child" bean is disposed using Future', () async {
      DDI.instance.registerSession(() async => A(await DDI.instance()));
      DDI.instance.registerSession<FutureOr<B>>(() async => B(DDI.instance()));
      DDI.instance.registerSession(C.new);

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

    test('Retrieve Session bean Stream', () async {
      DDI.instance.registerSession(StreamController<C>.new);

      final StreamController<C> streamController = DDI.instance();

      streamController.add(C());
      streamController.close();

      final instance = await streamController.stream.first;

      expect(instance, isA<C>());

      DDI.instance.destroy<StreamController<C>>();
    });
  });
}
