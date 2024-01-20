import 'package:flutter_test/flutter_test.dart';

import 'package:dart_ddi/dart_ddi.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/b.dart';
import '../clazz_samples/c.dart';

void disposeDestroyAllSession() {
  group('DDI Dispose Destroy ALl Session Tests', () {
    void registerSessionBeans() {
      DDI.instance.registerSession(() => A(DDI.instance()));
      DDI.instance.registerSession(() => B(DDI.instance()));
      DDI.instance.registerSession(() => C());
    }

    test('Register and retrieve Session bean', () {
      registerSessionBeans();

      DDI.instance.get<A>();

      DDI.instance.destroyAllSession();

      expect(() => DDI.instance.get<A>(),
          throwsA(const TypeMatcher<AssertionError>()));
      expect(() => DDI.instance.get<B>(),
          throwsA(const TypeMatcher<AssertionError>()));
      expect(() => DDI.instance.get<C>(),
          throwsA(const TypeMatcher<AssertionError>()));
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

      expect(() => DDI.instance.get<A>(),
          throwsA(const TypeMatcher<AssertionError>()));
      expect(() => DDI.instance.get<B>(),
          throwsA(const TypeMatcher<AssertionError>()));
      expect(() => DDI.instance.get<C>(),
          throwsA(const TypeMatcher<AssertionError>()));
    });
  });
}
