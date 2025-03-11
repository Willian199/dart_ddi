import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:test/test.dart';

import '../clazz_samples/g.dart';
import '../clazz_samples/h.dart';
import '../clazz_samples/i.dart';

void runByType() {
  group('DDI Process By Type', () {
    test('Application Get bean by Type that have registered and dispose', () {
      ddi.registerApplication<G>(() => H(), qualifier: 'firtsClass');

      final List<Object> keys1 = ddi.getByType<G>();

      expect(keys1.length, 1);
      ddi.registerApplication<G>(() => I(), qualifier: 'secondClass');

      final List<Object> keys2 = ddi.getByType<G>();

      expect(keys2.length, 2);

      final G instance1 = ddi.get(qualifier: keys2[0]);
      final G instance2 = ddi.get(qualifier: keys2[1]);

      expect(instance1.area(), instance2.area() / 2);

      ddi.disposeByType<G>();
      expect(ddi.isReady(qualifier: 'firtsClass'), false);
      expect(ddi.isReady(qualifier: 'secondClass'), false);

      ddi.destroyByType<G>();

      expect(() => ddi.get(qualifier: keys2[0]), throwsA(isA<BeanNotFoundException>()));
      expect(() => ddi.get(qualifier: keys2[1]), throwsA(isA<BeanNotFoundException>()));

      expect(ddi.isRegistered(qualifier: 'firtsClass'), false);
      expect(ddi.isRegistered(qualifier: 'secondClass'), false);
    });

    test('Dependent Get bean by Type that have registered and dispose', () {
      ddi.registerDependent<G>(() => H(), qualifier: 'firtsClass');

      final List<Object> keys1 = ddi.getByType<G>();

      expect(keys1.length, 1);
      ddi.registerDependent<G>(() => I(), qualifier: 'secondClass');

      final List<Object> keys2 = ddi.getByType<G>();

      expect(keys2.length, 2);

      final G instance1 = ddi.get(qualifier: keys2[0]);
      final G instance2 = ddi.get(qualifier: keys2[1]);

      expect(instance1.area(), instance2.area() / 2);

      ddi.disposeByType<G>();
      expect(ddi.isReady(qualifier: 'firtsClass'), false);
      expect(ddi.isReady(qualifier: 'secondClass'), false);

      ddi.destroyByType<G>();

      expect(() => ddi.get(qualifier: keys2[0]), throwsA(isA<BeanNotFoundException>()));
      expect(() => ddi.get(qualifier: keys2[1]), throwsA(isA<BeanNotFoundException>()));
      expect(ddi.isRegistered(qualifier: 'firtsClass'), false);
      expect(ddi.isRegistered(qualifier: 'secondClass'), false);
    });

    test('Get bean by Type that have registered and dispose', () {
      ddi.registerApplication<G>(() => H(), qualifier: 'firtsClass');

      final List<Object> keys1 = ddi.getByType<G>();

      expect(keys1.length, 1);
      ddi.registerDependent<G>(() => I(), qualifier: 'secondClass');

      final List<Object> keys2 = ddi.getByType<G>();

      expect(keys2.length, 2);

      final G instance1 = ddi.get(qualifier: keys2[0]);
      final G instance2 = ddi.get(qualifier: keys2[1]);

      expect(instance1.area(), instance2.area() / 2);

      ddi.disposeByType<G>();
      expect(ddi.isReady(qualifier: 'firtsClass'), false);
      expect(ddi.isReady(qualifier: 'secondClass'), false);

      ddi.destroyByType<G>();

      expect(() => ddi.get(qualifier: keys2[0]), throwsA(isA<BeanNotFoundException>()));
      expect(() => ddi.get(qualifier: keys2[1]), throwsA(isA<BeanNotFoundException>()));
      expect(ddi.isRegistered(qualifier: 'firtsClass'), false);
      expect(ddi.isRegistered(qualifier: 'secondClass'), false);
    });

    test('Factory Singleton Get bean by Type that have registered and dispose', () {
      ddi.register<G>(
        factory: SingletonFactory(builder: H.new.builder),
        qualifier: 'firtsClass',
      );

      final List<Object> keys1 = ddi.getByType<G>();

      expect(keys1.length, 1);
      ddi.register<G>(
        factory: SingletonFactory(builder: I.new.builder),
        qualifier: 'secondClass',
      );

      final List<Object> keys2 = ddi.getByType<G>();

      expect(keys2.length, 2);

      final G instance1 = ddi.get(qualifier: keys2[0]);
      final G instance2 = ddi.get(qualifier: keys2[1]);

      expect(instance1.area(), instance2.area() / 2);

      ddi.disposeByType<G>();
      // Singleton are not allow to dispose
      expect(ddi.isReady(qualifier: 'firtsClass'), true);
      expect(ddi.isReady(qualifier: 'secondClass'), true);

      ddi.destroyByType<G>();

      expect(() => ddi.get(qualifier: keys2[0]), throwsA(isA<BeanNotFoundException>()));
      expect(() => ddi.get(qualifier: keys2[1]), throwsA(isA<BeanNotFoundException>()));
    });

    test('Factory Application Get bean by Type that have registered and dispose', () {
      ddi.register<G>(factory: ApplicationFactory(builder: H.new.builder), qualifier: 'firtsClass');

      final List<Object> keys1 = ddi.getByType<G>();

      expect(keys1.length, 1);
      ddi.register<G>(
        factory: ApplicationFactory(builder: I.new.builder),
        qualifier: 'secondClass',
      );

      final List<Object> keys2 = ddi.getByType<G>();

      expect(keys2.length, 2);

      final G instance1 = ddi.get(qualifier: keys2[0]);
      final G instance2 = ddi.get(qualifier: keys2[1]);

      expect(instance1.area(), instance2.area() / 2);

      ddi.disposeByType<G>();
      expect(ddi.isReady(qualifier: 'firtsClass'), false);
      expect(ddi.isReady(qualifier: 'secondClass'), false);

      ddi.destroyByType<G>();

      expect(() => ddi.get(qualifier: keys2[0]), throwsA(isA<BeanNotFoundException>()));
      expect(() => ddi.get(qualifier: keys2[1]), throwsA(isA<BeanNotFoundException>()));
    });

    test('Factory and Non Factory Application Get bean by Type that have registered and dispose', () {
      ddi.register<G>(factory: ApplicationFactory(builder: H.new.builder), qualifier: 'firtsClass');

      final List<Object> keys1 = ddi.getByType<G>();

      expect(keys1.length, 1);
      ddi.registerApplication<G>(() => I(), qualifier: 'secondClass');

      final List<Object> keys2 = ddi.getByType<G>();

      expect(keys2.length, 2);

      final G instance1 = ddi.get(qualifier: keys2[0]);
      final G instance2 = ddi.get(qualifier: keys2[1]);

      expect(instance1.area(), instance2.area() / 2);

      ddi.disposeByType<G>();

      expect(ddi.isReady(qualifier: 'firtsClass'), false);
      expect(ddi.isReady(qualifier: 'secondClass'), false);

      ddi.destroyByType<G>();

      expect(() => ddi.get(qualifier: keys2[0]), throwsA(isA<BeanNotFoundException>()));
      expect(() => ddi.get(qualifier: keys2[1]), throwsA(isA<BeanNotFoundException>()));
    });

    test('Future Factory Application Get bean by Type that have registered and dispose', () async {
      ddi.register<G>(
        qualifier: 'firtsClass',
        factory: ApplicationFactory(
          builder: () async {
            await Future.delayed(const Duration(milliseconds: 200));
            return H();
          }.builder,
        ),
      );

      final List<Object> keys1 = ddi.getByType<G>();

      expect(keys1.length, 1);
      ddi.register<G>(
        qualifier: 'secondClass',
        factory: ApplicationFactory(
          builder: () async {
            await Future.delayed(const Duration(milliseconds: 200));
            return I();
          }.builder,
        ),
      );

      final List<Object> keys2 = ddi.getByType<G>();

      expect(keys2.length, 2);

      final G instance1 = await ddi.getAsync(qualifier: keys2[0]);
      final G instance2 = await ddi.getAsync(qualifier: keys2[1]);

      expect(instance1.area(), instance2.area() / 2);

      ddi.disposeByType<G>();

      expect(ddi.isReady(qualifier: 'firtsClass'), false);
      expect(ddi.isReady(qualifier: 'secondClass'), false);

      ddi.destroyByType<G>();

      expect(() => ddi.get(qualifier: keys2[0]), throwsA(isA<BeanNotFoundException>()));
      expect(() => ddi.get(qualifier: keys2[1]), throwsA(isA<BeanNotFoundException>()));
    });

    test('Future Factory Singleton Get bean by Type that have registered and dispose', () async {
      await ddi.register<G>(
        qualifier: 'firtsClass',
        factory: SingletonFactory(
          builder: () async {
            await Future.delayed(const Duration(milliseconds: 200));
            return H();
          }.builder,
        ),
      );

      final List<Object> keys1 = ddi.getByType<G>();

      expect(keys1.length, 1);
      await ddi.register<G>(
        qualifier: 'secondClass',
        factory: SingletonFactory(
          builder: () async {
            await Future.delayed(const Duration(milliseconds: 200));
            return I();
          }.builder,
        ),
      );

      final List<Object> keys2 = ddi.getByType<G>();

      expect(keys2.length, 2);

      final G instance1 = await ddi.getAsync(qualifier: keys2[0]);
      final G instance2 = await ddi.getAsync(qualifier: keys2[1]);

      expect(instance1.area(), instance2.area() / 2);

      ddi.disposeByType<G>();

      expect(ddi.isReady(qualifier: 'firtsClass'), true);
      expect(ddi.isReady(qualifier: 'secondClass'), true);

      ddi.destroyByType<G>();

      expect(() => ddi.get(qualifier: keys2[0]), throwsA(isA<BeanNotFoundException>()));
      expect(() => ddi.get(qualifier: keys2[1]), throwsA(isA<BeanNotFoundException>()));
    });

    test('Future Factory Dependent Get bean by Type that have registered and dispose', () async {
      ddi.register<G>(
        qualifier: 'firtsClass',
        factory: DependentFactory(
          builder: () async {
            await Future.delayed(const Duration(milliseconds: 200));
            return H();
          }.builder,
        ),
      );

      final List<Object> keys1 = ddi.getByType<G>();

      expect(keys1.length, 1);
      ddi.register<G>(
        qualifier: 'secondClass',
        factory: DependentFactory(
          builder: () async {
            await Future.delayed(const Duration(milliseconds: 200));
            return I();
          }.builder,
        ),
      );

      final List<Object> keys2 = ddi.getByType<G>();

      expect(keys2.length, 2);

      final G instance1 = await ddi.getAsync(qualifier: keys2[0]);
      final G instance2 = await ddi.getAsync(qualifier: keys2[1]);

      expect(instance1.area(), instance2.area() / 2);

      ddi.disposeByType<G>();
      expect(ddi.isReady(qualifier: 'firtsClass'), false);
      expect(ddi.isReady(qualifier: 'secondClass'), false);

      ddi.destroyByType<G>();

      expect(() => ddi.get(qualifier: keys2[0]), throwsA(isA<BeanNotFoundException>()));
      expect(() => ddi.get(qualifier: keys2[1]), throwsA(isA<BeanNotFoundException>()));
    });

    test('Future Factory and Non Future Singleton getByType', () async {
      await ddi.register<G>(
        qualifier: 'firtsClass',
        factory: SingletonFactory(
          builder: () async {
            await Future.delayed(const Duration(milliseconds: 200));
            return H();
          }.builder,
        ),
      );

      final List<Object> keys1 = ddi.getByType<G>();

      expect(keys1.length, 1);
      ddi.register<G>(factory: SingletonFactory(builder: I.new.builder), qualifier: 'secondClass');

      final List<Object> keys2 = ddi.getByType<G>();

      expect(keys2.length, 2);

      final G instance1 = await ddi.getAsync(qualifier: keys2[0]);
      final G instance2 = await ddi.getAsync(qualifier: keys2[1]);

      expect(instance1.area(), instance2.area() / 2);

      ddi.disposeByType<G>();
      expect(ddi.isReady(qualifier: 'firtsClass'), true);
      expect(ddi.isReady(qualifier: 'secondClass'), true);

      ddi.destroyByType<G>();

      expect(() => ddi.get(qualifier: keys2[0]), throwsA(isA<BeanNotFoundException>()));
      expect(() => ddi.get(qualifier: keys2[1]), throwsA(isA<BeanNotFoundException>()));
    });

    test('Future Factory and Non Future Application getByType', () async {
      await ddi.register<G>(
        qualifier: 'firtsClass',
        factory: ApplicationFactory(
          builder: () async {
            await Future.delayed(const Duration(milliseconds: 200));
            return H();
          }.builder,
        ),
      );

      final List<Object> keys1 = ddi.getByType<G>();

      expect(keys1.length, 1);
      ddi.register<G>(factory: ApplicationFactory(builder: I.new.builder), qualifier: 'secondClass');

      final List<Object> keys2 = ddi.getByType<G>();

      expect(keys2.length, 2);

      final G instance1 = await ddi.getAsync(qualifier: keys2[0]);
      final G instance2 = await ddi.getAsync(qualifier: keys2[1]);

      expect(instance1.area(), instance2.area() / 2);

      ddi.disposeByType<G>();
      expect(ddi.isReady(qualifier: 'firtsClass'), false);
      expect(ddi.isReady(qualifier: 'secondClass'), false);

      ddi.destroyByType<G>();

      expect(() => ddi.get(qualifier: keys2[0]), throwsA(isA<BeanNotFoundException>()));
      expect(() => ddi.get(qualifier: keys2[1]), throwsA(isA<BeanNotFoundException>()));
    });
  });
}
