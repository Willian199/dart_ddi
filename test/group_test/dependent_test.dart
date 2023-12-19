import 'package:flutter_test/flutter_test.dart';

import 'package:dart_di/dart_di.dart';

import '../clazz_test/a.dart';
import '../clazz_test/b.dart';
import '../clazz_test/c.dart';

void dependent() {
  group('DDI Dependent Basic Tests', () {
    registerDependentBeans() {
      DDI.instance.registerDependent(() => A(DDI.instance()));
      DDI.instance.registerDependent(() => B(DDI.instance()));
      DDI.instance.registerDependent(() => C());
    }

    removeDependentBeans() {
      DDI.instance.destroy<A>();
      DDI.instance.destroy<B>();
      DDI.instance.destroy<C>();
    }

    test('Register and retrieve Dependent bean', () {
      registerDependentBeans();

      var instance1 = DDI.instance.get<A>();
      var instance2 = DDI.instance.get<A>();

      expect(false, identical(instance1, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(false, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeDependentBeans();
    });

    test('Retrieve Dependent bean after a "child" bean is diposed', () {
      registerDependentBeans();

      var instance = DDI.instance.get<A>();

      DDI.instance.dispose<C>();
      var instance1 = DDI.instance.get<A>();
      expect(false, identical(instance1, instance));
      expect(false, identical(instance1.b, instance.b));
      expect(false, identical(instance1.b.c, instance.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeDependentBeans();
    });

    test('Retrieve Dependent bean after a second "child" bean is diposed', () {
      registerDependentBeans();

      var instance = DDI.instance.get<A>();

      DDI.instance.dispose<B>();
      var instance1 = DDI.instance.get<A>();
      expect(false, identical(instance1, instance));
      expect(false, identical(instance1.b, instance.b));
      expect(false, identical(instance1.b.c, instance.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeDependentBeans();
    });

    test('Try to retrieve Dependent bean after disposed', () {
      DDI.instance.registerDependent(() => C());

      var instance1 = DDI.instance.get<C>();

      DDI.instance.dispose<C>();

      var instance2 = DDI.instance.get<C>();

      expect(false, identical(instance1, instance2));
    });

    test('Try to retrieve Dependent bean after removed', () {
      DDI.instance.get<C>();

      DDI.instance.destroy<C>();

      expect(() => DDI.instance.get<C>(), throwsA(const TypeMatcher<AssertionError>()));
    });

    test('Create, get and remove a qualifier bean', () {
      DDI.instance.registerDependent(() => C(), qualifierName: 'typeC');

      var instance1 = DDI.instance.get(qualifierName: 'typeC');
      var instance2 = DDI.instance.get(qualifierName: 'typeC');

      expect(false, identical(instance1, instance2));

      DDI.instance.destroy(qualifierName: 'typeC');

      expect(() => DDI.instance.get(qualifierName: 'typeC'), throwsA(const TypeMatcher<AssertionError>()));
    });
  });
}
