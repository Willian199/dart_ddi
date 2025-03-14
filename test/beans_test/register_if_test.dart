import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:test/test.dart';

import '../clazz_samples/c.dart';

void canRegister() {
  group('DDI Register If tests', () {
    test('Register a Singleton bean with canRegister true', () {
      DDI.instance.registerSingleton(() => C(),
          canRegister: () => true, qualifier: 'typeC');

      DDI.instance.get(qualifier: 'typeC');

      DDI.instance.destroy(qualifier: 'typeC');

      expect(() => DDI.instance.get(qualifier: 'typeC'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Register a Singleton bean with canRegister false', () {
      DDI.instance.registerSingleton(() => C(),
          canRegister: () => false, qualifier: 'typeC');

      expect(() => DDI.instance.get(qualifier: 'typeC'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Register a Application bean with canRegister true', () {
      DDI.instance.registerApplication(() => C(),
          canRegister: () => true, qualifier: 'typeC');

      DDI.instance.get(qualifier: 'typeC');

      DDI.instance.destroy(qualifier: 'typeC');

      expect(() => DDI.instance.get(qualifier: 'typeC'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Register a Application bean with canRegister false', () {
      DDI.instance.registerApplication(() => C(),
          canRegister: () => false, qualifier: 'typeC');

      expect(() => DDI.instance.get(qualifier: 'typeC'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Register a Dependent bean with canRegister true', () {
      DDI.instance.registerDependent(() => C(),
          canRegister: () => true, qualifier: 'typeC');

      DDI.instance.get(qualifier: 'typeC');

      DDI.instance.destroy(qualifier: 'typeC');

      expect(() => DDI.instance.get(qualifier: 'typeC'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Register a Dependent bean with canRegister false', () {
      DDI.instance.registerDependent(() => C(),
          canRegister: () => false, qualifier: 'typeC');

      expect(() => DDI.instance.get(qualifier: 'typeC'),
          throwsA(isA<BeanNotFoundException>()));
    });
  });
}
