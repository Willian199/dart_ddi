import 'package:flutter_test/flutter_test.dart';

import 'package:dart_di/dart_di.dart';

import '../clazz_test/a.dart';
import '../clazz_test/b.dart';
import '../clazz_test/c.dart';

void singleton() {
  group('DDI Singleton Basic Tests', () {
    registerSingletonBeans() {
      DDI.instance.registerSingleton(() => C());
      DDI.instance.registerSingleton(() => B(DDI.instance()));
      DDI.instance.registerSingleton(() => A(DDI.instance()));
    }

    removeSingletonBeans() {
      DDI.instance.destroy<A>();
      DDI.instance.destroy<B>();
      DDI.instance.destroy<C>();
    }

    test('Register and retrieve singleton bean', () {
      ///Where is Singleton, should the register in the correct order
      registerSingletonBeans();

      var instance1 = DDI.instance.get<A>();
      var instance2 = DDI.instance.get<A>();

      expect(instance1, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeSingletonBeans();
    });

    test('Retrieve singleton bean after a "child" bean is diposed', () {
      registerSingletonBeans();

      var instance = DDI.instance.get<A>();

      DDI.instance.dispose<C>();
      var instance1 = DDI.instance.get<A>();
      expect(instance1, same(instance));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeSingletonBeans();
    });

    test('Retrieve singleton bean after a second "child" bean is diposed', () {
      registerSingletonBeans();

      var instance = DDI.instance.get<A>();

      DDI.instance.dispose<B>();
      var instance1 = DDI.instance.get<A>();
      expect(instance1, same(instance));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeSingletonBeans();
    });

    test('Try to retrieve singleton bean after removed', () {
      DDI.instance.registerSingleton(() => C());

      DDI.instance.get<C>();

      DDI.instance.destroy<C>();

      expect(() => DDI.instance.get<C>(), throwsA(const TypeMatcher<AssertionError>()));
    });

    ///Remove or Dispose a Singleton, has the same effect
    test('Try to retrieve singleton bean after disposed', () {
      DDI.instance.registerSingleton(() => C());

      DDI.instance.get<C>();

      DDI.instance.dispose<C>();

      expect(() => DDI.instance.get<C>(), throwsA(const TypeMatcher<AssertionError>()));
    });

    test('Create, get and remove a qualifier bean', () {
      DDI.instance.registerSingleton(() => C(), qualifierName: 'typeC');

      DDI.instance.get(qualifierName: 'typeC');

      DDI.instance.destroy(qualifierName: 'typeC');

      expect(() => DDI.instance.get(qualifierName: 'typeC'), throwsA(const TypeMatcher<AssertionError>()));
    });
  });
}
