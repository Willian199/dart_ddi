import 'package:flutter_test/flutter_test.dart';

import 'package:dart_di/dart_di.dart';

import '../clazz_test/a.dart';
import '../clazz_test/b.dart';
import '../clazz_test/c.dart';

void application() {
  group('DDI Application Basic Tests', () {
    registerApplicationBeans() {
      DDI.instance.registerApplication(() => A(DDI.instance()));
      DDI.instance.registerApplication(() => B(DDI.instance()));
      DDI.instance.registerApplication(() => C());
    }

    removeApplicationBeans() {
      DDI.instance.remove<A>();
      DDI.instance.remove<B>();
      DDI.instance.remove<C>();
    }

    test('Register and retrieve Application bean', () {
      registerApplicationBeans();

      var instance1 = DDI.instance.get<A>();
      var instance2 = DDI.instance.get<A>();

      expect(instance1, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Application bean after a "child" bean is diposed', () {
      registerApplicationBeans();

      var instance = DDI.instance.get<A>();

      DDI.instance.dispose<C>();
      var instance1 = DDI.instance.get<A>();
      expect(instance1, same(instance));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Application bean after a second "child" bean is diposed', () {
      registerApplicationBeans();

      var instance = DDI.instance.get<A>();

      DDI.instance.dispose<B>();
      var instance1 = DDI.instance.get<A>();
      expect(instance1, same(instance));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Application bean after the last "child" bean is diposed', () {
      registerApplicationBeans();

      var instance1 = DDI.instance.get<A>();

      DDI.instance.dispose<A>();
      var instance2 = DDI.instance.get<A>();

      expect(false, identical(instance1, instance2));
      expect(true, identical(instance1.b, instance2.b));
      expect(true, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Application bean after 2 "child" bean is diposed', () {
      registerApplicationBeans();

      var instance1 = DDI.instance.get<A>();

      DDI.instance.dispose<B>();
      DDI.instance.dispose<A>();
      var instance2 = DDI.instance.get<A>();

      expect(false, identical(instance1, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(true, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Application bean after 3 "child" bean is diposed', () {
      registerApplicationBeans();

      var instance1 = DDI.instance.get<A>();

      DDI.instance.dispose<C>();
      DDI.instance.dispose<B>();
      DDI.instance.dispose<A>();
      var instance2 = DDI.instance.get<A>();

      expect(false, identical(instance1, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(false, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Try to retrieve Application bean after disposed', () {
      DDI.instance.registerApplication(() => C());

      var instance1 = DDI.instance.get<C>();

      DDI.instance.dispose<C>();

      var instance2 = DDI.instance.get<C>();

      expect(false, identical(instance1, instance2));
    });

    test('Try to retrieve Application bean after removed', () {
      DDI.instance.get<C>();

      DDI.instance.remove<C>();

      expect(() => DDI.instance.get<C>(), throwsA(const TypeMatcher<AssertionError>()));
    });

    test('Create, get and remove a qualifier bean', () {
      DDI.instance.registerApplication(() => C(), qualifierName: 'typeC');

      DDI.instance.get(qualifierName: 'typeC');

      DDI.instance.remove(qualifierName: 'typeC');

      expect(() => DDI.instance.get(qualifierName: 'typeC'), throwsA(const TypeMatcher<AssertionError>()));
    });
  });
}
