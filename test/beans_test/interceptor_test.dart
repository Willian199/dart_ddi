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

void interceptor() {
  group('DDI Interceptor Tests', () {
    test('ADD Interceptor to a Singleton bean', () {
      ///Where is Singleton, should the register in the correct order
      DDI.instance.registerSingleton<G>(() => H(), interceptors: [() => J()]);

      final G instance = DDI.instance.get<G>();

      expect(instance.area(), 20);
      expect(instance is I, true);

      DDI.instance.destroy<G>();

      expect(() => DDI.instance.get<G>(), throwsA(isA<BeanNotFound>()));
    });

    test('ADD Interceptor to a Application bean', () {
      DDI.instance.registerApplication<G>(() => H(), interceptors: [() => J()]);

      final G instance = DDI.instance.get<G>();

      expect(instance.area(), 20);
      expect(instance is I, true);

      DDI.instance.destroy<G>();

      expect(() => DDI.instance.get<G>(), throwsA(isA<BeanNotFound>()));
    });

    test('ADD Interceptor to a Application bean with qualifier', () {
      DDI.instance.registerApplication<G>(() => H(),
          qualifier: 'qualifier', interceptors: [() => J()]);

      final G instance = DDI.instance.get<G>(qualifier: 'qualifier');

      expect(instance.area(), 20);
      expect(instance is I, true);

      DDI.instance.destroy<G>(qualifier: 'qualifier');

      expect(() => DDI.instance.get<G>(qualifier: 'qualifier'),
          throwsA(isA<BeanNotFound>()));
    });

    test('ADD Interceptor to a Dependent bean', () {
      DDI.instance.registerDependent<G>(() => H(), interceptors: [() => J()]);

      final G instance = DDI.instance.get<G>();

      expect(instance.area(), 20);
      expect(instance is I, true);

      DDI.instance.destroy<G>();

      expect(() => DDI.instance.get<G>(), throwsA(isA<BeanNotFound>()));
    });

    test('ADD Interceptor to a Session bean', () {
      DDI.instance.registerSession<G>(() => H(), interceptors: [() => J()]);

      final G instance = DDI.instance.get<G>();

      expect(instance.area(), 20);
      expect(instance is I, true);

      DDI.instance.destroy<G>();

      expect(() => DDI.instance.get<G>(), throwsA(isA<BeanNotFound>()));
    });

    test('ADD Interceptor after registered a Application bean', () {
      DDI.instance.registerApplication<G>(() => H());

      final G instance = DDI.instance.get<G>();

      expect(instance.area(), 10);
      expect(instance is H, true);

      DDI.instance.dispose<G>();

      DDI.instance.addInterceptor([
        () => J(),
      ]);

      final G instance2 = DDI.instance.get<G>();

      expect(instance2 is I, true);
      expect(instance2.area(), 20);

      DDI.instance.destroy<G>();

      expect(() => DDI.instance.get<G>(), throwsA(isA<BeanNotFound>()));
    });

    test('ADD Decorators and Interceptor to a Singleton bean', () {
      ///Where is Singleton, should the register in the correct order
      DDI.instance.registerSingleton(
        () => D(),
        decorators: [
          (instance) => E(instance),
          (instance) => F(instance),
        ],
        interceptors: [() => K()],
      );

      final instance1 = DDI.instance.get<D>();

      expect(instance1.value, 'bcconsdfghiGET');

      DDI.instance.addDecorator<D>([
        (instance) => E(instance),
      ]);

      final instance2 = DDI.instance.get<D>();

      // Be aware about this behavior. Being apply the `get` everytime
      expect(instance2.value, 'bcconsdfghGETdefGET');
      expect(identical(instance1, instance2), false);

      DDI.instance.destroy<D>();
    });
  });
}
