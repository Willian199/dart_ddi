import 'package:dart_ddi/core/dart_di.dart';
import 'package:flutter_test/flutter_test.dart';

import '../clazz_test/g.dart';
import '../clazz_test/h.dart';
import '../clazz_test/i.dart';

void runByType() {
  group('DDI Process By Type', () {
    test('Application Get bean by Type that have registered and dispose', () {
      ///Where is Singleton, should the register in the correct order
      DDI.instance
          .registerApplication<G>(() => H(), qualifierName: 'firtsClass');

      final List<Object> keys1 = DDI.instance.getByType<G>();

      expect(keys1.length, 1);
      DDI.instance
          .registerApplication<G>(() => I(), qualifierName: 'secondClass');

      final List<Object> keys2 = DDI.instance.getByType<G>();

      expect(keys2.length, 2);

      final G instance1 = DDI.instance.get(qualifierName: keys2[0]);
      final G instance2 = DDI.instance.get(qualifierName: keys2[1]);

      expect(instance1.area(), instance2.area() / 2);

      DDI.instance.disposeByType<G>();
      DDI.instance.destroyByType<G>();

      expect(() => DDI.instance.get(qualifierName: keys2[0]),
          throwsA(const TypeMatcher<AssertionError>()));
      expect(() => DDI.instance.get(qualifierName: keys2[1]),
          throwsA(const TypeMatcher<AssertionError>()));
    });

    test('Dependent Get bean by Type that have registered and dispose', () {
      ///Where is Singleton, should the register in the correct order
      DDI.instance.registerDependent<G>(() => H(), qualifierName: 'firtsClass');

      final List<Object> keys1 = DDI.instance.getByType<G>();

      expect(keys1.length, 1);
      DDI.instance
          .registerDependent<G>(() => I(), qualifierName: 'secondClass');

      final List<Object> keys2 = DDI.instance.getByType<G>();

      expect(keys2.length, 2);

      final G instance1 = DDI.instance.get(qualifierName: keys2[0]);
      final G instance2 = DDI.instance.get(qualifierName: keys2[1]);

      expect(instance1.area(), instance2.area() / 2);

      DDI.instance.disposeByType<G>();
      DDI.instance.destroyByType<G>();

      expect(() => DDI.instance.get(qualifierName: keys2[0]),
          throwsA(const TypeMatcher<AssertionError>()));
      expect(() => DDI.instance.get(qualifierName: keys2[1]),
          throwsA(const TypeMatcher<AssertionError>()));
    });

    test('Session Get bean by Type that have registered and dispose', () {
      ///Where is Singleton, should the register in the correct order
      DDI.instance.registerSession<G>(() => H(), qualifierName: 'firtsClass');

      final List<Object> keys1 = DDI.instance.getByType<G>();

      expect(keys1.length, 1);
      DDI.instance.registerSession<G>(() => I(), qualifierName: 'secondClass');

      final List<Object> keys2 = DDI.instance.getByType<G>();

      expect(keys2.length, 2);

      final G instance1 = DDI.instance.get(qualifierName: keys2[0]);
      final G instance2 = DDI.instance.get(qualifierName: keys2[1]);

      expect(instance1.area(), instance2.area() / 2);

      DDI.instance.disposeByType<G>();
      DDI.instance.destroyByType<G>();

      expect(() => DDI.instance.get(qualifierName: keys2[0]),
          throwsA(const TypeMatcher<AssertionError>()));
      expect(() => DDI.instance.get(qualifierName: keys2[1]),
          throwsA(const TypeMatcher<AssertionError>()));
    });

    test('Get bean by Type that have registered and dispose', () {
      ///Where is Singleton, should the register in the correct order
      DDI.instance
          .registerApplication<G>(() => H(), qualifierName: 'firtsClass');

      final List<Object> keys1 = DDI.instance.getByType<G>();

      expect(keys1.length, 1);
      DDI.instance
          .registerDependent<G>(() => I(), qualifierName: 'secondClass');

      final List<Object> keys2 = DDI.instance.getByType<G>();

      expect(keys2.length, 2);

      final G instance1 = DDI.instance.get(qualifierName: keys2[0]);
      final G instance2 = DDI.instance.get(qualifierName: keys2[1]);

      expect(instance1.area(), instance2.area() / 2);

      DDI.instance.disposeByType<G>();
      DDI.instance.destroyByType<G>();

      expect(() => DDI.instance.get(qualifierName: keys2[0]),
          throwsA(const TypeMatcher<AssertionError>()));
      expect(() => DDI.instance.get(qualifierName: keys2[1]),
          throwsA(const TypeMatcher<AssertionError>()));
    });
  });
}
