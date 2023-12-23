import 'package:dart_ddi/dart_di.dart';
import 'package:flutter_test/flutter_test.dart';

import '../clazz_test/c.dart';

void registerIf() {
  group('DDI Register If tests', () {
    test('Regsiter a Singleton bean with registerIf true', () {
      DDI.instance.registerSingleton(() => C(),
          registerIf: () => true, qualifierName: 'typeC');

      DDI.instance.get(qualifierName: 'typeC');

      DDI.instance.destroy(qualifierName: 'typeC');

      expect(() => DDI.instance.get(qualifierName: 'typeC'),
          throwsA(const TypeMatcher<AssertionError>()));
    });

    test('Regsiter a Singleton bean with registerIf false', () {
      DDI.instance.registerSingleton(() => C(),
          registerIf: () => false, qualifierName: 'typeC');

      expect(() => DDI.instance.get(qualifierName: 'typeC'),
          throwsA(const TypeMatcher<AssertionError>()));
    });

    test('Regsiter a Application bean with registerIf true', () {
      DDI.instance.registerApplication(() => C(),
          registerIf: () => true, qualifierName: 'typeC');

      DDI.instance.get(qualifierName: 'typeC');

      DDI.instance.destroy(qualifierName: 'typeC');

      expect(() => DDI.instance.get(qualifierName: 'typeC'),
          throwsA(const TypeMatcher<AssertionError>()));
    });

    test('Regsiter a Application bean with registerIf false', () {
      DDI.instance.registerApplication(() => C(),
          registerIf: () => false, qualifierName: 'typeC');

      expect(() => DDI.instance.get(qualifierName: 'typeC'),
          throwsA(const TypeMatcher<AssertionError>()));
    });

    test('Regsiter a Session bean with registerIf true', () {
      DDI.instance.registerSession(() => C(),
          registerIf: () => true, qualifierName: 'typeC');

      DDI.instance.get(qualifierName: 'typeC');

      DDI.instance.destroy(qualifierName: 'typeC');

      expect(() => DDI.instance.get(qualifierName: 'typeC'),
          throwsA(const TypeMatcher<AssertionError>()));
    });

    test('Regsiter a Session bean with registerIf false', () {
      DDI.instance.registerSession(() => C(),
          registerIf: () => false, qualifierName: 'typeC');

      expect(() => DDI.instance.get(qualifierName: 'typeC'),
          throwsA(const TypeMatcher<AssertionError>()));
    });

    test('Regsiter a Dependent bean with registerIf true', () {
      DDI.instance.registerDependent(() => C(),
          registerIf: () => true, qualifierName: 'typeC');

      DDI.instance.get(qualifierName: 'typeC');

      DDI.instance.destroy(qualifierName: 'typeC');

      expect(() => DDI.instance.get(qualifierName: 'typeC'),
          throwsA(const TypeMatcher<AssertionError>()));
    });

    test('Regsiter a Dependent bean with registerIf false', () {
      DDI.instance.registerDependent(() => C(),
          registerIf: () => false, qualifierName: 'typeC');

      expect(() => DDI.instance.get(qualifierName: 'typeC'),
          throwsA(const TypeMatcher<AssertionError>()));
    });
  });
}
