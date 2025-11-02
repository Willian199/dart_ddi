import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/c.dart';

void main() {
  group('DDI Register If tests', () {
    tearDownAll(() {
      expect(ddi.isEmpty, true);
    });
    test('Register a Singleton bean with canRegister true', () {
      DDI.instance.singleton(
        () => C(),
        canRegister: () => true,
        qualifier: 'typeC',
      );

      DDI.instance.get(qualifier: 'typeC');

      DDI.instance.destroy(qualifier: 'typeC');

      expect(
        () => DDI.instance.get(qualifier: 'typeC'),
        throwsA(isA<BeanNotFoundException>()),
      );
    });

    test('Register a Singleton bean with canRegister false', () {
      DDI.instance.singleton(
        () => C(),
        canRegister: () => false,
        qualifier: 'typeC',
      );

      expect(
        () => DDI.instance.get(qualifier: 'typeC'),
        throwsA(isA<BeanNotFoundException>()),
      );
    });

    test('Register a Application bean with canRegister true', () {
      DDI.instance.application(
        () => C(),
        canRegister: () => true,
        qualifier: 'typeC',
      );

      DDI.instance.get(qualifier: 'typeC');

      DDI.instance.destroy(qualifier: 'typeC');

      expect(
        () => DDI.instance.get(qualifier: 'typeC'),
        throwsA(isA<BeanNotFoundException>()),
      );
    });

    test('Register a Application bean with canRegister false', () {
      DDI.instance.application(
        () => C(),
        canRegister: () => false,
        qualifier: 'typeC',
      );

      expect(
        () => DDI.instance.get(qualifier: 'typeC'),
        throwsA(isA<BeanNotFoundException>()),
      );
    });

    test('Register a Dependent bean with canRegister true', () {
      DDI.instance.dependent(
        () => C(),
        canRegister: () => true,
        qualifier: 'typeC',
      );

      DDI.instance.get(qualifier: 'typeC');

      DDI.instance.destroy(qualifier: 'typeC');

      expect(
        () => DDI.instance.get(qualifier: 'typeC'),
        throwsA(isA<BeanNotFoundException>()),
      );
    });

    test('Register a Dependent bean with canRegister false', () {
      DDI.instance.dependent(
        () => C(),
        canRegister: () => false,
        qualifier: 'typeC',
      );

      expect(
        () => DDI.instance.get(qualifier: 'typeC'),
        throwsA(isA<BeanNotFoundException>()),
      );
    });
  });
}
