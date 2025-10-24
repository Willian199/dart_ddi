import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_ready.dart';
import 'package:test/test.dart';

import '../clazz_samples/d.dart';
import '../clazz_samples/e.dart';
import '../clazz_samples/f.dart';

void main() {
  group('DDI Future ADD Decorators Tests', () {
    tearDownAll(
      () {
        expect(ddi.isEmpty, true);
      },
    );
    Future<void> regraSoma() async {
      final instance1 = await DDI.instance.getAsync<D>();

      expect(instance1.value, 'bcdfghi');

      DDI.instance.addDecorator<D>([
        (instance) => E(instance),
      ]);

      final instance2 = await DDI.instance.getAsync<D>();

      expect(instance2.value, 'bcdfghdef');
      expect(identical(instance1, instance2), false);
    }

    test('ADD Decorators to a Singleton bean', () async {
      await DDI.instance.singleton<D>(
        () => Future.value(D()),
        decorators: [
          (instance) => E(instance),
          (instance) => F(instance),
        ],
      );

      await regraSoma();

      await DDI.instance.destroy<D>();

      expect(ddi.isRegistered<D>(), false);
    });

    test('ADD Decorators to a Application bean', () async {
      DDI.instance.application<D>(
        () => Future.value(D()),
        decorators: [
          (instance) => E(instance),
          (instance) => F(instance),
        ],
      );

      await regraSoma();

      await DDI.instance.destroy<D>();

      expect(ddi.isRegistered<D>(), false);
    });

    test('ADD Decorators to a Dependent bean', () async {
      DDI.instance.dependent<D>(
        () => Future.value(D()),
        decorators: [
          (instance) => E(instance),
          (instance) => F(instance),
        ],
      );

      await regraSoma();

      await DDI.instance.destroy<D>();

      expect(ddi.isRegistered<D>(), false);
    });

    test('ADD Decorators when the Singleton bean is not ready', () async {
      DDI.instance.singleton<D>(
        () async {
          await Future.delayed(const Duration(milliseconds: 20));
          return D();
        },
        decorators: [
          (instance) => E(instance),
          (instance) => F(instance),
        ],
      );

      expect(
          () => DDI.instance.addDecorator<D>([
                (instance) => E(instance),
              ]),
          throwsA(isA<BeanNotReadyException>()));

      await DDI.instance.destroy<D>();

      expect(ddi.isRegistered<D>(), false);
    });
  });
}
