import 'package:flutter_test/flutter_test.dart';

import 'package:dart_ddi/dart_ddi.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/b.dart';
import '../clazz_samples/c.dart';
import '../clazz_samples/undestroyable/dependent_destroy_get.dart';
import '../clazz_samples/undestroyable/dependent_destroy_register.dart';

void dependent() {
  group('DDI Dependent Basic Tests', () {
    void registerDependentBeans() {
      DDI.instance.registerDependent(() => A(DDI.instance()));
      DDI.instance.registerDependent(() => B(DDI.instance()));
      DDI.instance.registerDependent(() => C());
    }

    void removeDependentBeans() {
      DDI.instance.destroy<A>();
      DDI.instance.destroy<B>();
      DDI.instance.destroy<C>();
    }

    test('Register and retrieve Dependent bean', () {
      registerDependentBeans();

      final instance1 = DDI.instance.get<A>();
      final instance2 = DDI.instance.get<A>();

      expect(false, identical(instance1, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(false, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeDependentBeans();
    });

    test('Retrieve Dependent bean after a "child" bean is diposed', () {
      registerDependentBeans();

      final instance = DDI.instance.get<A>();

      DDI.instance.dispose<C>();
      final instance1 = DDI.instance.get<A>();
      expect(false, identical(instance1, instance));
      expect(false, identical(instance1.b, instance.b));
      expect(false, identical(instance1.b.c, instance.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeDependentBeans();
    });

    test('Retrieve Dependent bean after a second "child" bean is diposed', () {
      registerDependentBeans();

      final instance = DDI.instance.get<A>();

      DDI.instance.dispose<B>();
      final instance1 = DDI.instance.get<A>();
      expect(false, identical(instance1, instance));
      expect(false, identical(instance1.b, instance.b));
      expect(false, identical(instance1.b.c, instance.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeDependentBeans();
    });

    test('Try to retrieve Dependent bean after disposed', () {
      DDI.instance.registerDependent(() => C());

      final instance1 = DDI.instance.get<C>();

      DDI.instance.dispose<C>();

      final instance2 = DDI.instance.get<C>();

      expect(false, identical(instance1, instance2));
    });

    test('Try to retrieve Dependent bean after removed', () {
      DDI.instance.get<C>();

      DDI.instance.destroy<C>();

      expect(() => DDI.instance.get<C>(),
          throwsA(const TypeMatcher<AssertionError>()));
    });

    test('Create, get and remove a qualifier bean', () {
      DDI.instance.registerDependent(() => C(), qualifier: 'typeC');

      final instance1 = DDI.instance.get(qualifier: 'typeC');
      final instance2 = DDI.instance.get(qualifier: 'typeC');

      expect(false, identical(instance1, instance2));

      DDI.instance.destroy(qualifier: 'typeC');

      expect(() => DDI.instance.get(qualifier: 'typeC'),
          throwsA(const TypeMatcher<AssertionError>()));
    });

    test('Try to destroy a undestroyable Dependent bean', () {
      DDI.instance
          .registerDependent(() => DependentDestroyGet(), destroyable: false);

      final instance1 = DDI.instance.get<DependentDestroyGet>();

      DDI.instance.destroy<DependentDestroyGet>();

      final instance2 = DDI.instance.get<DependentDestroyGet>();

      expect(instance2, isNotNull);
      expect(false, identical(instance1, instance2));
    });

    test('Try to register again a undestroyable Dependent bean', () {
      DDI.instance.registerDependent(() => DependentDestroyRegister(),
          destroyable: false);

      DDI.instance.get<DependentDestroyRegister>();

      DDI.instance.destroy<DependentDestroyRegister>();

      expect(
          () =>
              DDI.instance.registerDependent(() => DependentDestroyRegister()),
          throwsA(const TypeMatcher<AssertionError>()));
    });
  });
}
