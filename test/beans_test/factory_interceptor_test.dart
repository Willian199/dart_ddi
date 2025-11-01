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

void main() {
  group('DDI Factory Interceptor Tests', () {
    tearDownAll(() {
      expect(ddi.isEmpty, true);
    });
    test('ADD Interceptor to a Factory Singleton bean', () {
      ddi.register<J>(factory: SingletonFactory(builder: J<G>.new.builder));

      ddi.register<G>(
        factory: SingletonFactory(builder: H.new.builder, interceptors: {J}),
      );

      final G instance = ddi.get<G>();

      expect(instance.area(), 20);
      expect(instance is I, true);

      ddi.destroy<G>();
      ddi.destroy<J>();

      expect(() => ddi.get<G>(), throwsA(isA<BeanNotFoundException>()));
    });

    test('ADD Interceptor to a Factory Application bean', () {
      ddi.register<J>(factory: ApplicationFactory(builder: J<G>.new.builder));

      ddi.register<G>(
        factory: ApplicationFactory(builder: H.new.builder, interceptors: {J}),
      );

      final G instance = ddi.get<G>();

      expect(instance.area(), 20);
      expect(instance is I, true);

      ddi.destroy<G>();
      ddi.destroy<J>();

      expect(() => ddi.get<G>(), throwsA(isA<BeanNotFoundException>()));
    });

    test('ADD Interceptor to a Factory Application bean with qualifier', () {
      ddi.register<J>(factory: ApplicationFactory(builder: J<G>.new.builder));

      ddi.register<G>(
        qualifier: 'qualifier',
        factory: ApplicationFactory(builder: H.new.builder, interceptors: {J}),
      );

      final G instance = ddi.get<G>(qualifier: 'qualifier');

      expect(instance.area(), 20);
      expect(instance is I, true);

      ddi.destroy<G>(qualifier: 'qualifier');
      ddi.destroy<J>();

      expect(
        () => ddi.get<G>(qualifier: 'qualifier'),
        throwsA(isA<BeanNotFoundException>()),
      );
    });

    test('ADD Interceptor to a Factory Dependent bean', () {
      ddi.register<J>(factory: DependentFactory(builder: J<G>.new.builder));

      ddi.register<G>(
        factory: DependentFactory(builder: H.new.builder, interceptors: {J}),
      );

      final G instance = ddi.get<G>();

      expect(instance.area(), 20);
      expect(instance is I, true);

      ddi.destroy<G>();
      ddi.destroy<J>();

      expect(() => ddi.get<G>(), throwsA(isA<BeanNotFoundException>()));
    });

    test('ADD Interceptor after registered a Factory Application bean', () {
      ddi.register<J>(factory: ApplicationFactory(builder: J<G>.new.builder));

      // Don't use [H.new.factory.asApplication()] with interceptor
      ddi.register(factory: ApplicationFactory<G>(builder: H.new.builder));
      final G instance = ddi.get<G>();

      expect(instance.area(), 10);
      expect(instance is H, true);

      ddi.dispose<G>();

      ddi.addInterceptor<G>({J});

      final G instance2 = ddi.get<G>();

      expect(instance2 is I, true);
      expect(instance2.area(), 20);

      ddi.destroy<G>();
      ddi.destroy<J>();

      expect(() => ddi.get<G>(), throwsA(isA<BeanNotFoundException>()));
    });

    test('ADD Decorators and Interceptor to a Factory Singleton bean', () {
      ddi.register<K>(factory: SingletonFactory(builder: K.new.builder));

      ddi.register(
        factory: SingletonFactory(
          builder: D.new.builder,
          decorators: [
            (D instance) => E(instance),
            (D instance) => F(instance),
          ],
          interceptors: {K},
        ),
      );

      final D instance1 = ddi.get<D>();

      expect(instance1.value, 'bcconsdfghiGET');

      ddi.addDecorator<D>([(instance) => E(instance)]);

      final D instance2 = ddi.get<D>();

      // Be aware about this behavior. Being apply the `get` everytime
      expect(instance2.value, 'bcconsdfghGETdefGET');
      expect(identical(instance1, instance2), false);

      ddi.destroy<D>();
      ddi.destroy<K>();
    });

    test('ADD Decorators and Interceptor to a Factory Application bean', () {
      ddi.register<K>(factory: ApplicationFactory(builder: K.new.builder));

      ddi.register(
        factory: ApplicationFactory(
          builder: D.new.builder,
          decorators: [
            (D instance) => E(instance),
            (D instance) => F(instance),
          ],
          interceptors: {K},
        ),
      );

      final D instance1 = ddi.get<D>();

      expect(instance1.value, 'bcconsdfghiGET');

      ddi.addDecorator<D>([(instance) => E(instance)]);

      final D instance2 = ddi.get<D>();

      // Be aware about this behavior. Being apply the `get` everytime
      expect(instance2.value, 'bcconsdfghGETdefGET');
      expect(identical(instance1, instance2), false);

      ddi.destroy<D>();
      ddi.destroy<K>();
    });
  });
}
