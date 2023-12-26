import 'package:flutter_test/flutter_test.dart';

import 'package:dart_ddi/dart_ddi.dart';

import '../clazz_test/a.dart';
import '../clazz_test/b.dart';
import '../clazz_test/c.dart';
import '../clazz_test/undestroyable/application_destroy_get.dart';
import '../clazz_test/undestroyable/application_destroy_register.dart';

void application() {
  group('DDI Application Basic Tests', () {
    void registerApplicationBeans() {
      DDI.instance.registerApplication(() => A(DDI.instance()));
      DDI.instance.registerApplication(() => B(DDI.instance()));
      DDI.instance.registerApplication(() => C());
    }

    void removeApplicationBeans() {
      DDI.instance.destroy<A>();
      DDI.instance.destroy<B>();
      DDI.instance.destroy<C>();
    }

    test('Register and retrieve Application bean', () {
      registerApplicationBeans();

      final instance1 = DDI.instance.get<A>();
      final instance2 = DDI.instance.get<A>();

      expect(instance1, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Application bean after a "child" bean is diposed', () {
      registerApplicationBeans();

      final instance = DDI.instance.get<A>();

      DDI.instance.dispose<C>();
      final instance1 = DDI.instance.get<A>();
      expect(instance1, same(instance));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Application bean after a second "child" bean is diposed',
        () {
      registerApplicationBeans();

      final instance = DDI.instance.get<A>();

      DDI.instance.dispose<B>();
      final instance1 = DDI.instance.get<A>();
      expect(instance1, same(instance));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Application bean after the last "child" bean is diposed',
        () {
      registerApplicationBeans();

      final instance1 = DDI.instance.get<A>();

      DDI.instance.dispose<A>();
      final instance2 = DDI.instance.get<A>();

      expect(false, identical(instance1, instance2));
      expect(true, identical(instance1.b, instance2.b));
      expect(true, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Application bean after 2 "child" bean is diposed', () {
      registerApplicationBeans();

      final instance1 = DDI.instance.get<A>();

      DDI.instance.dispose<B>();
      DDI.instance.dispose<A>();
      final instance2 = DDI.instance.get<A>();

      expect(false, identical(instance1, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(true, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Application bean after 3 "child" bean is diposed', () {
      registerApplicationBeans();

      final instance1 = DDI.instance.get<A>();

      DDI.instance.dispose<C>();
      DDI.instance.dispose<B>();
      DDI.instance.dispose<A>();
      final instance2 = DDI.instance.get<A>();

      expect(false, identical(instance1, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(false, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Try to retrieve Application bean after disposed', () {
      DDI.instance.registerApplication(() => C());

      final instance1 = DDI.instance.get<C>();

      DDI.instance.dispose<C>();

      final instance2 = DDI.instance.get<C>();

      expect(false, identical(instance1, instance2));
    });

    test('Try to retrieve Application bean after removed', () {
      DDI.instance.get<C>();

      DDI.instance.destroy<C>();

      expect(() => DDI.instance.get<C>(),
          throwsA(const TypeMatcher<AssertionError>()));
    });

    test('Create, get and remove a qualifier bean', () {
      DDI.instance.registerApplication(() => C(), qualifierName: 'typeC');

      DDI.instance.get(qualifierName: 'typeC');

      DDI.instance.destroy(qualifierName: 'typeC');

      expect(() => DDI.instance.get(qualifierName: 'typeC'),
          throwsA(const TypeMatcher<AssertionError>()));
    });

    test('Try to destroy a undestroyable Application bean', () {
      DDI.instance.registerApplication(() => ApplicationDestroyGet(),
          destroyable: false);

      final instance1 = DDI.instance.get<ApplicationDestroyGet>();

      DDI.instance.destroy<ApplicationDestroyGet>();

      final instance2 = DDI.instance.get<ApplicationDestroyGet>();

      expect(instance1, same(instance2));
    });

    test('Try to register again a undestroyable Application bean', () {
      DDI.instance.registerApplication(() => ApplicationDestroyRegister(),
          destroyable: false);

      DDI.instance.get<ApplicationDestroyRegister>();

      DDI.instance.destroy<ApplicationDestroyRegister>();

      expect(
          () => DDI.instance
              .registerApplication(() => ApplicationDestroyRegister()),
          throwsA(const TypeMatcher<AssertionError>()));
    });
  });
}
