import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:test/test.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/b.dart';
import '../clazz_samples/c.dart';

void disposeDestroyAllSession() {
  group('DDI Dispose Destroy All Session Tests', () {
    void registerSessionBeans() {
      DDI.instance.registerSession(() => A(DDI.instance()));
      DDI.instance.registerSession(() => B(DDI.instance()));
      DDI.instance.registerSession(() => C());
    }

    test('Register and retrieve Session bean', () {
      registerSessionBeans();

      DDI.instance.get<A>();

      DDI.instance.destroyAllSession();

      expect(() => DDI.instance.get<A>(), throwsA(isA<BeanNotFound>()));
      expect(() => DDI.instance.get<B>(), throwsA(isA<BeanNotFound>()));
      expect(() => DDI.instance.get<C>(), throwsA(isA<BeanNotFound>()));
    });

    test('Register, get, dispose and destroy Session bean', () {
      registerSessionBeans();

      final instance1 = DDI.instance.get<A>();
      final instance2 = DDI.instance.get<A>();

      expect(instance1, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      DDI.instance.disposeAllSession();

      final instance3 = DDI.instance.get<A>();

      expect(false, identical(instance1, instance3));
      expect(false, identical(instance1.b, instance3.b));
      expect(false, identical(instance1.b.c, instance3.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      DDI.instance.destroyAllSession();

      expect(() => DDI.instance.get<A>(), throwsA(isA<BeanNotFound>()));
      expect(() => DDI.instance.get<B>(), throwsA(isA<BeanNotFound>()));
      expect(() => DDI.instance.get<C>(), throwsA(isA<BeanNotFound>()));
    });

    test('Register, get, dispose and destroy Session bean', () async {
      DDI.instance.registerSession(() async => A(await DDI.instance()));
      DDI.instance
          .registerSession<FutureOr<B>>(() => Future.value(B(DDI.instance())));
      DDI.instance.registerSession(C.new);

      final instance1 = await DDI.instance.get<Future<A>>();
      final instance2 = await DDI.instance.get<Future<A>>();

      expect(instance1, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      DDI.instance.disposeAllSession();

      final instance3 = await DDI.instance.get<Future<A>>();

      expect(false, identical(instance1, instance3));
      expect(false, identical(instance1.b, instance3.b));
      expect(false, identical(instance1.b.c, instance3.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      DDI.instance.destroyAllSession();

      expect(() => DDI.instance.get<Future<A>>(), throwsA(isA<BeanNotFound>()));
      expect(
          () => DDI.instance.get<FutureOr<B>>(), throwsA(isA<BeanNotFound>()));
      expect(() => DDI.instance.get<C>(), throwsA(isA<BeanNotFound>()));
    });
  });
}
