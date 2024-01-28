import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/d.dart';
import '../clazz_samples/e.dart';
import '../clazz_samples/f.dart';

void futureAddDecorator() {
  group('DDI Future ADD Decorators Tests', () {
    Future<void> regraSoma() async {
      final instance1 = await DDI.instance.get<Future<D>>();

      expect(instance1.value, 'bcdfghi');

      await DDI.instance.addDecorator<Future<D>>([
        (instance) async => E(await instance),
      ]);

      final instance2 = await DDI.instance.get<Future<D>>();

      expect(instance2.value, 'bcdfghdef');
      expect(identical(instance1, instance2), false);
    }

    test('ADD Decorators to a Singleton bean', () async {
      DDI.instance.registerSingleton<Future<D>>(
        () => Future.value(D()),
        decorators: [
          (instance) async => E(await instance),
          (instance) async => F(await instance),
        ],
      );

      await regraSoma();

      DDI.instance.destroy<Future<D>>();
    });

    test('ADD Decorators to a Application bean', () async {
      DDI.instance.registerApplication<Future<D>>(
        () => Future.value(D()),
        decorators: [
          (instance) async => E(await instance),
          (instance) async => F(await instance),
        ],
      );

      await regraSoma();

      DDI.instance.destroy<Future<D>>();
    });

    test('ADD Decorators to a Session bean', () async {
      DDI.instance.registerSession<Future<D>>(
        () => Future.value(D()),
        decorators: [
          (instance) async => E(await instance),
          (instance) async => F(await instance),
        ],
      );

      await regraSoma();

      DDI.instance.destroy<Future<D>>();
    });

    test('ADD Decorators to a Dependent bean', () async {
      DDI.instance.registerDependent<Future<D>>(
        () => Future.value(D()),
        decorators: [
          (instance) async => E(await instance),
          (instance) async => F(await instance),
        ],
      );

      await regraSoma();

      DDI.instance.destroy<Future<D>>();
    });
  });
}
