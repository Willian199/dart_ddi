import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:test/test.dart';

import '../clazz_samples/c.dart';

void registerIf() {
  group('DDI Register If tests', () {
    test('Try to register a bean with registerIf false', () async {
      await DDI.instance.registerSingleton(C.new, registerIf: () async {
        await Future.delayed(const Duration(milliseconds: 200));

        return false;
      });

      expect(
          () => DDI.instance.get<C>(), throwsA(isA<BeanNotFoundException>()));

      DDI.instance.destroy<C>();
    });

    test('Try to register a bean with registerIf true', () async {
      await DDI.instance.registerSingleton(C.new, registerIf: () async {
        await Future.delayed(const Duration(milliseconds: 200));

        return true;
      });

      final C intance = DDI.instance.get<C>();

      DDI.instance.destroy<C>();

      await expectLater(intance.value, 1);
    });
    test('Register a Singleton bean with registerIf true and qualifier',
        () async {
      await DDI.instance.registerSingleton(
        C.new,
        qualifier: 'typeC',
        registerIf: () async {
          await Future.delayed(const Duration(milliseconds: 200));

          return true;
        },
      );

      DDI.instance.get(qualifier: 'typeC');

      DDI.instance.destroy(qualifier: 'typeC');

      expect(() => DDI.instance.get(qualifier: 'typeC'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Register a Singleton bean with registerIf false and qualifier',
        () async {
      await DDI.instance.registerSingleton(
        C.new,
        qualifier: 'typeC',
        registerIf: () async {
          await Future.delayed(const Duration(milliseconds: 200));

          return false;
        },
      );

      expect(() => DDI.instance.get(qualifier: 'typeC'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Register a Application bean with registerIf true', () async {
      await DDI.instance.registerApplication(
        C.new,
        qualifier: 'typeC',
        registerIf: () async {
          await Future.delayed(const Duration(milliseconds: 200));

          return true;
        },
      );

      DDI.instance.get(qualifier: 'typeC');

      DDI.instance.destroy(qualifier: 'typeC');

      expect(() => DDI.instance.get(qualifier: 'typeC'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Register a Application bean with registerIf false', () async {
      await DDI.instance.registerApplication(
        C.new,
        qualifier: 'typeC',
        registerIf: () async {
          await Future.delayed(const Duration(milliseconds: 200));

          return false;
        },
      );

      expect(() => DDI.instance.get(qualifier: 'typeC'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Register a Session bean with registerIf true', () async {
      await DDI.instance.registerSession(
        C.new,
        qualifier: 'typeC',
        registerIf: () async {
          await Future.delayed(const Duration(milliseconds: 200));

          return true;
        },
      );

      DDI.instance.get(qualifier: 'typeC');

      DDI.instance.destroy(qualifier: 'typeC');

      expect(() => DDI.instance.get(qualifier: 'typeC'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Register a Session bean with registerIf false', () async {
      await DDI.instance.registerSession(
        C.new,
        qualifier: 'typeC',
        registerIf: () async {
          await Future.delayed(const Duration(milliseconds: 200));

          return false;
        },
      );

      expect(() => DDI.instance.get(qualifier: 'typeC'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Register a Dependent bean with registerIf true', () async {
      await DDI.instance.registerDependent(
        C.new,
        qualifier: 'typeC',
        registerIf: () async {
          await Future.delayed(const Duration(milliseconds: 200));

          return true;
        },
      );

      DDI.instance.get(qualifier: 'typeC');

      DDI.instance.destroy(qualifier: 'typeC');

      expect(() => DDI.instance.get(qualifier: 'typeC'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Register a Dependent bean with registerIf false', () async {
      await DDI.instance.registerDependent(
        C.new,
        qualifier: 'typeC',
        registerIf: () async {
          await Future.delayed(const Duration(milliseconds: 200));

          return false;
        },
      );

      expect(() => DDI.instance.get(qualifier: 'typeC'),
          throwsA(isA<BeanNotFoundException>()));
    });
  });
}
