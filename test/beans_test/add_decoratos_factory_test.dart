import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/d.dart';
import '../clazz_samples/e.dart';
import '../clazz_samples/f.dart';

void main() {
  group('DDI ADD Decorators Factory Tests', () {
    tearDownAll(
      () {
        expect(ddi.isEmpty, true);
      },
    );

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

    test('ADD Decorators to a Factory Singleton bean', () async {
      D.new.builder.asSingleton(
        decorators: [
          (instance) => E(instance),
          (instance) => F(instance),
        ],
      );

      regraSoma();

      await DDI.instance.destroy<D>();

      expect(ddi.isRegistered<D>(), false);
    });

    test('ADD Decorators to a Factory Application bean', () async {
      D.new.builder.asApplication(
        decorators: [
          (instance) => E(instance),
          (instance) => F(instance),
        ],
      );

      regraSoma();

      await DDI.instance.destroy<D>();

      expect(ddi.isRegistered<D>(), false);
    });

    test('ADD Decorators to a Dependent bean', () async {
      D.new.builder.asDependent(
        decorators: [
          (instance) => E(instance),
          (instance) => F(instance),
        ],
      );

      regraSoma();

      await DDI.instance.destroy<D>();

      expect(ddi.isRegistered<D>(), false);
    });

    // This test sometimes crash, without destroying the bean
    test('ADD Decorators to a Future Factory Singleton bean', () async {
      expect(ddi.isRegistered<D>(), false);
      await () async {
        await Future.delayed(const Duration(milliseconds: 10));
        return D();
      }.builder.asSingleton(
        decorators: [
          (D instance) => E(instance),
          (D instance) => F(instance),
        ],
      );

      final instance1 = await DDI.instance.getAsync<D>();

      expect(instance1.value, 'bcdfghi');

      DDI.instance.addDecorator<D>([
        (instance) => E(instance),
      ]);

      final instance2 = await DDI.instance.getAsync<D>();

      expect(instance2.value, 'bcdfghdef');
      expect(identical(instance1, instance2), false);

      await DDI.instance.destroy<D>();

      expect(ddi.isRegistered<D>(), false);
    });

    test('ADD Decorators to a Future Factory Application bean', () async {
      expect(ddi.isRegistered<D>(), false);

      () async {
        await Future.delayed(const Duration(milliseconds: 10));
        return D();
      }.builder.asApplication(
        decorators: [
          (instance) => E(instance),
          (instance) => F(instance),
        ],
      );

      await regraSomaAsync();

      await DDI.instance.destroy<D>();

      expect(ddi.isRegistered<D>(), false);
    });

    test('ADD Decorators to a Future Factory Dependent bean', () async {
      expect(ddi.isRegistered<D>(), false);

      () async {
        await Future.delayed(const Duration(milliseconds: 10));
        return D();
      }.builder.asDependent(
        decorators: [
          (instance) => E(instance),
          (instance) => F(instance),
        ],
      );

      await regraSomaAsync();

      await DDI.instance.destroy<D>();

      expect(ddi.isRegistered<D>(), false);
    });
  });
}
