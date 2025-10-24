import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:dart_ddi/src/exception/duplicated_bean.dart';
import 'package:test/test.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/b.dart';
import '../clazz_samples/c.dart';
import '../clazz_samples/undestroyable/dependent_destroy_get.dart';
import '../clazz_samples/undestroyable/dependent_destroy_register.dart';

void main() {
  group('DDI Dependent Basic Tests', () {
    tearDownAll(
      () {
        // Still having 2 Bean, because [canDestroy] is false
        expect(ddi.isEmpty, false);
        // DependentDestroyGet, DependentDestroyRegister
        expect(ddi.length, 2);
      },
    );

    void registerDependentBeans() {
      DDI.instance.dependent(() => A(DDI.instance()));
      DDI.instance.dependent(() => B(DDI.instance()));
      DDI.instance.dependent(() => C());
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
      DDI.instance.dependent(() => C());

      final instance1 = DDI.instance.get<C>();

      DDI.instance.dispose<C>();

      final instance2 = DDI.instance.get<C>();

      expect(false, identical(instance1, instance2));
    });

    test('Try to retrieve Dependent bean after removed', () {
      DDI.instance.get<C>();

      DDI.instance.destroy<C>();

      expect(
          () => DDI.instance.get<C>(), throwsA(isA<BeanNotFoundException>()));
    });

    test('Create, get and remove a qualifier bean', () {
      DDI.instance.dependent(() => C(), qualifier: 'typeC');

      final instance1 = DDI.instance.get(qualifier: 'typeC');
      final instance2 = DDI.instance.get(qualifier: 'typeC');

      expect(false, identical(instance1, instance2));

      DDI.instance.destroy(qualifier: 'typeC');

      expect(() => DDI.instance.get(qualifier: 'typeC'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Try to destroy a undestroyable Dependent bean', () {
      DDI.instance.dependent(() => DependentDestroyGet(), canDestroy: false);

      final instance1 = DDI.instance.get<DependentDestroyGet>();

      DDI.instance.destroy<DependentDestroyGet>();

      final instance2 = DDI.instance.get<DependentDestroyGet>();

      expect(instance2, isNotNull);
      expect(false, identical(instance1, instance2));
    });

    test('Try to register again a undestroyable Dependent bean', () {
      DDI.instance
          .dependent(() => DependentDestroyRegister(), canDestroy: false);

      DDI.instance.get<DependentDestroyRegister>();

      DDI.instance.destroy<DependentDestroyRegister>();

      expect(() => DDI.instance.dependent(() => DependentDestroyRegister()),
          throwsA(isA<DuplicatedBeanException>()));
    });
  });
}
