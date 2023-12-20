import 'package:dart_di/core/dart_di.dart';
import 'package:flutter_test/flutter_test.dart';

import '../clazz_test/d.dart';
import '../clazz_test/e.dart';
import '../clazz_test/f.dart';

void addDecorator() {
  group('DDI ADD Decorators Tests', () {
    regraSoma() {
      var instance1 = DDI.instance.get<D>();

      expect(instance1.value, 'bcdfghi');

      DDI.instance.addDecorator<D>([
        (instance) => E(instance),
      ]);

      var instance2 = DDI.instance.get<D>();

      expect(instance2.value, 'bcdfghdef');
      expect(identical(instance1, instance2), false);
    }

    test('ADD Decorators to a Singleton bean', () {
      ///Where is Singleton, should the register in the correct order
      DDI.instance.registerSingleton(
        () => D(),
        decorators: [
          (instance) => E(instance),
          (instance) => F(instance),
        ],
      );

      regraSoma();

      DDI.instance.destroy<D>();
    });

    test('ADD Decorators to a Application bean', () {
      ///Where is Singleton, should the register in the correct order
      DDI.instance.registerApplication(
        () => D(),
        decorators: [
          (instance) => E(instance),
          (instance) => F(instance),
        ],
      );

      regraSoma();

      DDI.instance.destroy<D>();
    });

    test('ADD Decorators to a Session bean', () {
      ///Where is Singleton, should the register in the correct order
      DDI.instance.registerSession(
        () => D(),
        decorators: [
          (instance) => E(instance),
          (instance) => F(instance),
        ],
      );

      regraSoma();

      DDI.instance.destroy<D>();
    });

    test('ADD Decorators to a Dependent bean', () {
      ///Where is Singleton, should the register in the correct order
      DDI.instance.registerDependent(
        () => D(),
        decorators: [
          (instance) => E(instance),
          (instance) => F(instance),
        ],
      );

      regraSoma();

      DDI.instance.destroy<D>();
    });
  });
}
