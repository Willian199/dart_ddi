import 'package:dart_di/dart_di.dart';
import 'package:flutter_test/flutter_test.dart';

import '../clazz_test/widget_a.dart';
import '../clazz_test/widget_b.dart';
import '../clazz_test/widget_c.dart';

void widget() {
  group('DDI Widget Basic Tests', () {
    void registerWidgetBeans() {
      DDI.instance.registerWidget(() => WidgetA(widgetB: DDI.instance()));
      DDI.instance.registerWidget(() => WidgetB(widgetC: DDI.instance()));
      DDI.instance.registerWidget(() => WidgetC());
    }

    void removeWidgetBeans() {
      DDI.instance.destroy<WidgetA>();
      DDI.instance.destroy<WidgetB>();
      DDI.instance.destroy<WidgetC>();
    }

    test('Register and retrieve Widget bean', () {
      registerWidgetBeans();

      final instance1 = DDI.instance.get<WidgetA>();
      final instance2 = DDI.instance.get<WidgetA>();

      expect(identical(instance1, instance2), false);
      expect(identical(instance1.widgetB, instance2.widgetB), false);
      expect(identical(instance1.widgetB.widgetC, instance2.widgetB.widgetC), false);

      removeWidgetBeans();
    });

    test('Retrieve Widget bean after a "child" bean is diposed', () {
      registerWidgetBeans();

      final instance1 = DDI.instance.get<WidgetA>();

      DDI.instance.dispose<WidgetC>();
      final instance2 = DDI.instance.get<WidgetA>();
      expect(identical(instance1, instance2), false);
      expect(identical(instance1.widgetB, instance2.widgetB), false);
      expect(identical(instance1.widgetB.widgetC, instance2.widgetB.widgetC), false);

      removeWidgetBeans();
    });

    test('Retrieve Widget bean after a second "child" bean is diposed', () {
      registerWidgetBeans();

      final instance1 = DDI.instance.get<WidgetA>();

      DDI.instance.dispose<WidgetB>();
      final instance2 = DDI.instance.get<WidgetA>();
      expect(identical(instance1, instance2), false);
      expect(identical(instance1.widgetB, instance2.widgetB), false);
      expect(identical(instance1.widgetB.widgetC, instance2.widgetB.widgetC), false);

      removeWidgetBeans();
    });

    test('Retrieve Widget bean without const', () {
      DDI.instance.registerWidget(() => WidgetC());

      final instance1 = DDI.instance.get<WidgetC>();

      final instance2 = DDI.instance.get<WidgetC>();

      expect(identical(instance1, instance2), false);

      DDI.instance.destroy<WidgetC>();
    });

    test('Retrieve Widget bean with const', () {
      DDI.instance.registerWidget(() => const WidgetC());

      final instance1 = DDI.instance.get<WidgetC>();

      final instance2 = DDI.instance.get<WidgetC>();

      expect(instance1, same(instance2));

      DDI.instance.destroy<WidgetC>();
    });

    test('Try to retrieve Widget bean after disposed', () {
      DDI.instance.registerWidget(() => WidgetC());

      final instance1 = DDI.instance.get<WidgetC>();

      DDI.instance.dispose<WidgetC>();

      final instance2 = DDI.instance.get<WidgetC>();

      expect(identical(instance1, instance2), false);
    });

    test('Try to retrieve Widget bean after removed', () {
      DDI.instance.get<WidgetC>();

      DDI.instance.destroy<WidgetC>();

      expect(() => DDI.instance.get<WidgetC>(), throwsA(const TypeMatcher<AssertionError>()));
    });

    test('Create, get and remove a qualifier bean', () {
      DDI.instance.registerWidget(() => WidgetC(), qualifierName: 'typeC');

      final instance1 = DDI.instance.get(qualifierName: 'typeC');
      final instance2 = DDI.instance.get(qualifierName: 'typeC');

      expect(identical(instance1, instance2), false);

      DDI.instance.destroy(qualifierName: 'typeC');

      expect(() => DDI.instance.get(qualifierName: 'typeC'), throwsA(const TypeMatcher<AssertionError>()));
    });
  });
}
