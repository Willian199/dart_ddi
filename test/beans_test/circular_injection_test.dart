import 'package:dart_ddi/dart_ddi.dart';
import 'package:flutter_test/flutter_test.dart';

import '../clazz_samples/c.dart';
import '../clazz_samples/father.dart';
import '../clazz_samples/mother.dart';

void circularDetection() {
  group('DDI Circular Injection Detection tests', () {
    test('Inject a Singleton bean depending from a bean that not exists yet',
        () {
      expect(
          () => DDI.instance
              .registerSingleton(() => Father(mother: DDI.instance())),
          throwsA(const TypeMatcher<AssertionError>()));
    });

    test('Inject a Application bean depending from a bean that not exists yet',
        () {
      DDI.instance.registerApplication(() => Father(mother: DDI.instance()));
      DDI.instance.registerApplication(() => Mother(father: DDI.instance()));

      DDI.instance.destroy<Mother>();
      DDI.instance.destroy<Father>();
    });

    test('Inject a Application bean with circular dependency', () {
      DDI.instance.registerApplication(() => Father(mother: DDI.instance()));
      DDI.instance.registerApplication(() => Mother(father: DDI.instance()));

      expect(() => DDI.instance<Mother>(),
          throwsA(const TypeMatcher<AssertionError>()));

      DDI.instance.destroy<Mother>();
      DDI.instance.destroy<Father>();
    });

    test('Inject a Dependent bean with circular dependency', () {
      DDI.instance.registerDependent(() => Father(mother: DDI.instance()));
      DDI.instance.registerDependent(() => Mother(father: DDI.instance()));

      expect(() => DDI.instance<Mother>(),
          throwsA(const TypeMatcher<AssertionError>()));

      DDI.instance.destroy<Mother>();
      DDI.instance.destroy<Father>();
    });

    test('Inject a Session bean with circular dependency', () {
      DDI.instance.registerSession(() => Father(mother: DDI.instance()));
      DDI.instance.registerSession(() => Mother(father: DDI.instance()));

      expect(() => DDI.instance<Mother>(),
          throwsA(const TypeMatcher<AssertionError>()));

      DDI.instance.destroy<Mother>();
      DDI.instance.destroy<Father>();
    });

    test('Get the same Singleton bean 100 times', () {
      DDI.instance.registerSingleton(() => C());

      for (int i = 0; i < 100; i++) {
        DDI.instance<C>();
      }

      DDI.instance.destroy<C>();
    });

    test('Get the same Application bean 100 times', () {
      DDI.instance.registerApplication(() => C());

      for (int i = 0; i < 100; i++) {
        DDI.instance<C>();
      }

      DDI.instance.destroy<C>();
    });

    test('Get the same Session bean 100 times', () {
      DDI.instance.registerSession(() => C());

      for (int i = 0; i < 100; i++) {
        DDI.instance<C>();
      }

      DDI.instance.destroy<C>();
    });

    test('Get the same Dependent bean 100 times', () {
      DDI.instance.registerDependent(() => C());

      for (int i = 0; i < 100; i++) {
        DDI.instance<C>();
      }

      DDI.instance.destroy<C>();
    });
  });
}
