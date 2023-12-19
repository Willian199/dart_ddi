import 'package:dart_di/dart_di.dart';
import 'package:flutter_test/flutter_test.dart';

import '../clazz_test/a.dart';
import '../clazz_test/b.dart';
import '../clazz_test/c.dart';

void widget() {
  group('DDI Widget Basic Tests', () {
    registerWidgetBeans() {
      DDI.instance.registerWidget(() => A(DDI.instance()));
      DDI.instance.registerWidget(() => B(DDI.instance()));
      DDI.instance.registerWidget(() => C());
    }

    removeWidgetBeans() {
      DDI.instance.remove<A>();
      DDI.instance.remove<B>();
      DDI.instance.remove<C>();
    }

    test('Register and retrieve Widget bean', () {
      registerWidgetBeans();

      var instance1 = DDI.instance.get<A>();
      var instance2 = DDI.instance.get<A>();

      expect(false, identical(instance1, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(false, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeWidgetBeans();
    });

    test('Retrieve Widget bean after a "child" bean is diposed', () {
      registerWidgetBeans();

      var instance = DDI.instance.get<A>();

      DDI.instance.dispose<C>();
      var instance1 = DDI.instance.get<A>();
      expect(false, identical(instance1, instance));
      expect(false, identical(instance1.b, instance.b));
      expect(false, identical(instance1.b.c, instance.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeWidgetBeans();
    });

    test('Retrieve Widget bean after a second "child" bean is diposed', () {
      registerWidgetBeans();

      var instance = DDI.instance.get<A>();

      DDI.instance.dispose<B>();
      var instance1 = DDI.instance.get<A>();
      expect(false, identical(instance1, instance));
      expect(false, identical(instance1.b, instance.b));
      expect(false, identical(instance1.b.c, instance.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeWidgetBeans();
    });

    test('Try to retrieve Widget bean after disposed', () {
      DDI.instance.registerWidget(() => C());

      var instance1 = DDI.instance.get<C>();

      DDI.instance.dispose<C>();

      var instance2 = DDI.instance.get<C>();

      expect(false, identical(instance1, instance2));
    });

    test('Try to retrieve Widget bean after removed', () {
      DDI.instance.get<C>();

      DDI.instance.remove<C>();

      expect(() => DDI.instance.get<C>(), throwsA(const TypeMatcher<AssertionError>()));
    });

    test('Create, get and remove a qualifier bean', () {
      DDI.instance.registerWidget(() => C(), qualifierName: 'typeC');

      var instance1 = DDI.instance.get(qualifierName: 'typeC');
      var instance2 = DDI.instance.get(qualifierName: 'typeC');

      expect(false, identical(instance1, instance2));

      DDI.instance.remove(qualifierName: 'typeC');

      expect(() => DDI.instance.get(qualifierName: 'typeC'), throwsA(const TypeMatcher<AssertionError>()));
    });
  });
}
