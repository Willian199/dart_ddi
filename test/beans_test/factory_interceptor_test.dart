import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:test/test.dart';

import '../clazz_samples/d.dart';
import '../clazz_samples/e.dart';
import '../clazz_samples/f.dart';
import '../clazz_samples/g.dart';
import '../clazz_samples/h.dart';
import '../clazz_samples/i.dart';
import '../clazz_samples/j.dart';
import '../clazz_samples/k.dart';

void factoryInterceptor() {
  group('DDI Factory Interceptor Tests', () {
    test('ADD Interceptor to a Factory Singleton bean', () {
      ddi.register<G>(
        factoryClazz: FactoryClazz.singleton(
          clazzFactory: H.new.factory,
          interceptors: [J.new],
        ),
      );

      final G instance = ddi.get<G>();

      expect(instance.area(), 20);
      expect(instance is I, true);

      ddi.destroy<G>();

      expect(() => ddi.get<G>(), throwsA(isA<BeanNotFoundException>()));
    });

    test('ADD Interceptor to a Factory Application bean', () {
      ddi.register<G>(
        factoryClazz: FactoryClazz.application(
          clazzFactory: H.new.factory,
          interceptors: [J.new],
        ),
      );

      final G instance = ddi.get<G>();

      expect(instance.area(), 20);
      expect(instance is I, true);

      ddi.destroy<G>();

      expect(() => ddi.get<G>(), throwsA(isA<BeanNotFoundException>()));
    });

    test('ADD Interceptor to a Factory Application bean with qualifier', () {
      ddi.register<G>(
        qualifier: 'qualifier',
        factoryClazz: FactoryClazz.application(
          clazzFactory: H.new.factory,
          interceptors: [J.new],
        ),
      );

      final G instance = ddi.get<G>(qualifier: 'qualifier');

      expect(instance.area(), 20);
      expect(instance is I, true);

      ddi.destroy<G>(qualifier: 'qualifier');

      expect(() => ddi.get<G>(qualifier: 'qualifier'), throwsA(isA<BeanNotFoundException>()));
    });

    test('ADD Interceptor to a Factory Dependent bean', () {
      ddi.register<G>(
        factoryClazz: FactoryClazz.dependent(
          clazzFactory: H.new.factory,
          interceptors: [J.new],
        ),
      );

      final G instance = ddi.get<G>();

      expect(instance.area(), 20);
      expect(instance is I, true);

      ddi.destroy<G>();

      expect(() => ddi.get<G>(), throwsA(isA<BeanNotFoundException>()));
    });

    test('ADD Interceptor after registered a Factory Application bean', () {
      // Don't use [H.new.factory.asApplication()] with interceptor
      ddi.register(
        factoryClazz: FactoryClazz<G>.application(
          clazzFactory: H.new.factory,
        ),
      );
      final G instance = ddi.get<G>();

      expect(instance.area(), 10);
      expect(instance is H, true);

      ddi.dispose<G>();

      ddi.addInterceptor([
        J.new,
      ]);

      final G instance2 = ddi.get<G>();

      expect(instance2 is I, true);
      expect(instance2.area(), 20);

      ddi.destroy<G>();

      expect(() => ddi.get<G>(), throwsA(isA<BeanNotFoundException>()));
    });

    test('ADD Decorators and Interceptor to a Factory Singleton bean', () {
      ddi.register(
        factoryClazz: FactoryClazz.singleton(
          clazzFactory: D.new.factory,
          decorators: [
            (instance) => E(instance),
            (instance) => F(instance),
          ],
          interceptors: [K.new],
        ),
      );

      final D instance1 = ddi.get<D>();

      expect(instance1.value, 'bcconsdfghiGET');

      ddi.addDecorator<D>([
        (instance) => E(instance),
      ]);

      final D instance2 = ddi.get<D>();

      // Be aware about this behavior. Being apply the `get` everytime
      expect(instance2.value, 'bcconsdfghGETdefGET');
      expect(identical(instance1, instance2), false);

      ddi.destroy<D>();
    });

    test('ADD Decorators and Interceptor to a Factory Application bean', () {
      ddi.register(
        factoryClazz: FactoryClazz.application(
          clazzFactory: D.new.factory,
          decorators: [
            (instance) => E(instance),
            (instance) => F(instance),
          ],
          interceptors: [K.new],
        ),
      );

      final D instance1 = ddi.get<D>();

      expect(instance1.value, 'bcconsdfghiGET');

      ddi.addDecorator<D>([
        (instance) => E(instance),
      ]);

      final D instance2 = ddi.get<D>();

      // Be aware about this behavior. Being apply the `get` everytime
      expect(instance2.value, 'bcconsdfghGETdefGET');
      expect(identical(instance1, instance2), false);

      ddi.destroy<D>();
    });
  });
}
