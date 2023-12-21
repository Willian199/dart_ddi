import 'package:dart_di/core/dart_di.dart';
import 'package:flutter_test/flutter_test.dart';

import '../clazz_test/d.dart';
import '../clazz_test/e.dart';
import '../clazz_test/f.dart';
import '../clazz_test/g.dart';
import '../clazz_test/h.dart';
import '../clazz_test/i.dart';
import '../clazz_test/j.dart';
import '../clazz_test/k.dart';

void interceptor() {
  group('DDI Interceptor Tests', () {
    test('ADD Interceptor to a Singleton bean', () {
      ///Where is Singleton, should the register in the correct order
      DDI.instance.registerSingleton<G>(() => H(), interceptors: [() => J()]);

      final G instance = DDI.instance.get<G>();

      expect(instance.area(), 20);
      expect(instance is I, true);

      DDI.instance.destroy<G>();

      expect(() => DDI.instance.get<G>(),
          throwsA(const TypeMatcher<AssertionError>()));
    });

    test('ADD Interceptor to a Application bean', () {
      DDI.instance.registerApplication<G>(() => H(), interceptors: [() => J()]);

      final G instance = DDI.instance.get<G>();

      expect(instance.area(), 20);
      expect(instance is I, true);

      DDI.instance.destroy<G>();

      expect(() => DDI.instance.get<G>(),
          throwsA(const TypeMatcher<AssertionError>()));
    });

    test('ADD Interceptor to a Application bean with qualifier', () {
      DDI.instance.registerApplication<G>(() => H(),
          qualifierName: 'qualifier', interceptors: [() => J()]);

      final G instance = DDI.instance.get<G>(qualifierName: 'qualifier');

      expect(instance.area(), 20);
      expect(instance is I, true);

      DDI.instance.destroy<G>(qualifierName: 'qualifier');

      expect(() => DDI.instance.get<G>(qualifierName: 'qualifier'),
          throwsA(const TypeMatcher<AssertionError>()));
    });

    test('ADD Interceptor to a Dependent bean', () {
      DDI.instance.registerDependent<G>(() => H(), interceptors: [() => J()]);

      final G instance = DDI.instance.get<G>();

      expect(instance.area(), 20);
      expect(instance is I, true);

      DDI.instance.destroy<G>();

      expect(() => DDI.instance.get<G>(),
          throwsA(const TypeMatcher<AssertionError>()));
    });

    test('ADD Interceptor to a Session bean', () {
      DDI.instance.registerSession<G>(() => H(), interceptors: [() => J()]);

      final G instance = DDI.instance.get<G>();

      expect(instance.area(), 20);
      expect(instance is I, true);

      DDI.instance.destroy<G>();

      expect(() => DDI.instance.get<G>(),
          throwsA(const TypeMatcher<AssertionError>()));
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

      expect(() => DDI.instance.get<G>(),
          throwsA(const TypeMatcher<AssertionError>()));
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
