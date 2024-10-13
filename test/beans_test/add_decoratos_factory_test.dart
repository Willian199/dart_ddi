import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/d.dart';
import '../clazz_samples/e.dart';
import '../clazz_samples/f.dart';

void addDecoratorFactory() {
  group('DDI ADD Decorators Factory Tests', () {
    void regraSoma() {
      final instance1 = DDI.instance.get<D>();

      expect(instance1.value, 'bcdfghi');

      DDI.instance.addDecorator<D>([
        (instance) => E(instance),
      ]);

      final instance2 = DDI.instance.get<D>();

      expect(instance2.value, 'bcdfghdef');
      expect(identical(instance1, instance2), false);
    }

    Future<void> regraSomaAsync() async {
      final instance1 = await DDI.instance.getAsync<D>();

      expect(instance1.value, 'bcdfghi');

      DDI.instance.addDecorator<D>([
        (instance) => E(instance),
      ]);

      final instance2 = await DDI.instance.getAsync<D>();

      expect(instance2.value, 'bcdfghdef');
      expect(identical(instance1, instance2), false);
    }

    test('ADD Decorators to a Factory Singleton bean', () {
      DDI.instance.register(
        factoryClazz: D.new.factory.asSingleton(
          decorators: [
            (instance) => E(instance),
            (instance) => F(instance),
          ],
        ),
      );

      regraSoma();

      DDI.instance.destroy<D>();
    });

    test('ADD Decorators to a Factory Application bean', () {
      DDI.instance.register(
        factoryClazz: D.new.factory.asApplication(
          decorators: [
            (instance) => E(instance),
            (instance) => F(instance),
          ],
        ),
      );

      regraSoma();

      DDI.instance.destroy<D>();
    });

    test('ADD Decorators to a Session bean', () {
      DDI.instance.register(
        factoryClazz: D.new.factory.asSession(
          decorators: [
            (instance) => E(instance),
            (instance) => F(instance),
          ],
        ),
      );

      regraSoma();

      DDI.instance.destroy<D>();
    });

    test('ADD Decorators to a Dependent bean', () {
      DDI.instance.register(
        factoryClazz: D.new.factory.asDependent(
          decorators: [
            (instance) => E(instance),
            (instance) => F(instance),
          ],
        ),
      );

      regraSoma();

      DDI.instance.destroy<D>();
    });

    test('ADD Decorators to a Future Factory Singleton bean', () async {
      await DDI.instance.register(
        factoryClazz: () async {
          await Future.delayed(const Duration(milliseconds: 10));
          return Future.value(D());
        }.factory.asSingleton(
          decorators: [
            (instance) => E(instance),
            (instance) => F(instance),
          ],
        ),
      );

      await regraSomaAsync();

      DDI.instance.destroy<D>();
    });

    test('ADD Decorators to a Future Factory Application bean', () async {
      DDI.instance.register(
        factoryClazz: () async {
          await Future.delayed(const Duration(milliseconds: 10));
          return Future.value(D());
        }.factory.asApplication(
          decorators: [
            (instance) => E(instance),
            (instance) => F(instance),
          ],
        ),
      );

      await regraSomaAsync();

      DDI.instance.destroy<D>();
    });

    test('ADD Decorators to a Future Factory Session bean', () async {
      DDI.instance.register(
        factoryClazz: () async {
          await Future.delayed(const Duration(milliseconds: 10));
          return Future.value(D());
        }.factory.asSession(
          decorators: [
            (instance) => E(instance),
            (instance) => F(instance),
          ],
        ),
      );

      await regraSomaAsync();

      DDI.instance.destroy<D>();
    });

    test('ADD Decorators to a Future Factory Dependent bean', () async {
      DDI.instance.register(
        factoryClazz: () async {
          await Future.delayed(const Duration(milliseconds: 10));
          return Future.value(D());
        }.factory.asDependent(
          decorators: [
            (instance) => E(instance),
            (instance) => F(instance),
          ],
        ),
      );

      await regraSomaAsync();

      DDI.instance.destroy<D>();
    });
  });
}
