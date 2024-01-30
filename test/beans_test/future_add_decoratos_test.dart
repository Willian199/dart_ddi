import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/d.dart';
import '../clazz_samples/e.dart';
import '../clazz_samples/f.dart';

void futureAddDecorator() {
  group('DDI Future ADD Decorators Tests', () {
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
      await DDI.instance.registerSingleton<D>(
        () => Future.value(D()),
        decorators: [
          (instance) => E(instance),
          (instance) => F(instance),
        ],
      );

      await regraSoma();

      DDI.instance.destroy<D>();
    });

    test('ADD Decorators to a Application bean', () async {
      DDI.instance.registerApplication<D>(
        () => Future.value(D()),
        decorators: [
          (instance) => E(instance),
          (instance) => F(instance),
        ],
      );

      await regraSoma();

      DDI.instance.destroy<D>();
    });

    test('ADD Decorators to a Session bean', () async {
      DDI.instance.registerSession<D>(
        () => Future.value(D()),
        decorators: [
          (instance) => E(instance),
          (instance) => F(instance),
        ],
      );

      await regraSoma();

      DDI.instance.destroy<D>();
    });

    test('ADD Decorators to a Dependent bean', () async {
      DDI.instance.registerDependent<D>(
        () => Future.value(D()),
        decorators: [
          (instance) => E(instance),
          (instance) => F(instance),
        ],
      );

      await regraSoma();

      DDI.instance.destroy<D>();
    });
  });
}
