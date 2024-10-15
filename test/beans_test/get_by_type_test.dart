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
      ddi.destroyByType<G>();

      expect(() => ddi.get(qualifier: keys2[0]),
          throwsA(isA<BeanNotFoundException>()));
      expect(() => ddi.get(qualifier: keys2[1]),
          throwsA(isA<BeanNotFoundException>()));
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
      ddi.destroyByType<G>();

      expect(() => ddi.get(qualifier: keys2[0]),
          throwsA(isA<BeanNotFoundException>()));
      expect(() => ddi.get(qualifier: keys2[1]),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Session Get bean by Type that have registered and dispose', () {
      ddi.registerSession<G>(() => H(), qualifier: 'firtsClass');

      final List<Object> keys1 = ddi.getByType<G>();

      expect(keys1.length, 1);
      ddi.registerSession<G>(() => I(), qualifier: 'secondClass');

      final List<Object> keys2 = ddi.getByType<G>();

      expect(keys2.length, 2);

      final G instance1 = ddi.get(qualifier: keys2[0]);
      final G instance2 = ddi.get(qualifier: keys2[1]);

      expect(instance1.area(), instance2.area() / 2);

      ddi.disposeByType<G>();
      ddi.destroyByType<G>();

      expect(() => ddi.get(qualifier: keys2[0]),
          throwsA(isA<BeanNotFoundException>()));
      expect(() => ddi.get(qualifier: keys2[1]),
          throwsA(isA<BeanNotFoundException>()));
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
      ddi.destroyByType<G>();

      expect(() => ddi.get(qualifier: keys2[0]),
          throwsA(isA<BeanNotFoundException>()));
      expect(() => ddi.get(qualifier: keys2[1]),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Factory Singleton Get bean by Type that have registered and dispose',
        () {
      ddi.register<G>(
          factoryClazz: H.new.factory.asSingleton(), qualifier: 'firtsClass');

      final List<Object> keys1 = ddi.getByType<G>();

      expect(keys1.length, 1);
      ddi.register<G>(
          factoryClazz: I.new.factory.asSingleton(), qualifier: 'secondClass');

      final List<Object> keys2 = ddi.getByType<G>();

      expect(keys2.length, 2);

      final G instance1 = ddi.get(qualifier: keys2[0]);
      final G instance2 = ddi.get(qualifier: keys2[1]);

      expect(instance1.area(), instance2.area() / 2);

      ddi.disposeByType<G>();
      ddi.destroyByType<G>();

      expect(() => ddi.get(qualifier: keys2[0]),
          throwsA(isA<BeanNotFoundException>()));
      expect(() => ddi.get(qualifier: keys2[1]),
          throwsA(isA<BeanNotFoundException>()));
    });

    test(
        'Factory Application Get bean by Type that have registered and dispose',
        () {
      ddi.register<G>(
          factoryClazz: H.new.factory.asApplication(), qualifier: 'firtsClass');

      final List<Object> keys1 = ddi.getByType<G>();

      expect(keys1.length, 1);
      ddi.register<G>(
          factoryClazz: I.new.factory.asApplication(),
          qualifier: 'secondClass');

      final List<Object> keys2 = ddi.getByType<G>();

      expect(keys2.length, 2);

      final G instance1 = ddi.get(qualifier: keys2[0]);
      final G instance2 = ddi.get(qualifier: keys2[1]);

      expect(instance1.area(), instance2.area() / 2);

      ddi.disposeByType<G>();
      ddi.destroyByType<G>();

      expect(() => ddi.get(qualifier: keys2[0]),
          throwsA(isA<BeanNotFoundException>()));
      expect(() => ddi.get(qualifier: keys2[1]),
          throwsA(isA<BeanNotFoundException>()));
    });

    test(
        'Factory and Non Factory Application Get bean by Type that have registered and dispose',
        () {
      ddi.register<G>(
          factoryClazz: H.new.factory.asApplication(), qualifier: 'firtsClass');

      final List<Object> keys1 = ddi.getByType<G>();

      expect(keys1.length, 1);
      ddi.registerApplication<G>(() => I(), qualifier: 'secondClass');

      final List<Object> keys2 = ddi.getByType<G>();

      expect(keys2.length, 2);

      final G instance1 = ddi.get(qualifier: keys2[0]);
      final G instance2 = ddi.get(qualifier: keys2[1]);

      expect(instance1.area(), instance2.area() / 2);

      ddi.disposeByType<G>();
      ddi.destroyByType<G>();

      expect(() => ddi.get(qualifier: keys2[0]),
          throwsA(isA<BeanNotFoundException>()));
      expect(() => ddi.get(qualifier: keys2[1]),
          throwsA(isA<BeanNotFoundException>()));
    });

    test(
        'Future Factory Application Get bean by Type that have registered and dispose',
        () async {
      ddi.register<G>(
        qualifier: 'firtsClass',
        factoryClazz: FactoryClazz.application(
          clazzFactory: () async {
            await Future.delayed(const Duration(milliseconds: 200));
            return H();
          }.factory,
        ),
      );

      final List<Object> keys1 = ddi.getByType<G>();

      expect(keys1.length, 1);
      ddi.register<G>(
        qualifier: 'secondClass',
        factoryClazz: FactoryClazz.application(
          clazzFactory: () async {
            await Future.delayed(const Duration(milliseconds: 200));
            return I();
          }.factory,
        ),
      );

      final List<Object> keys2 = ddi.getByType<G>();

      expect(keys2.length, 2);

      final G instance1 = await ddi.getAsync(qualifier: keys2[0]);
      final G instance2 = await ddi.getAsync(qualifier: keys2[1]);

      expect(instance1.area(), instance2.area() / 2);

      ddi.disposeByType<G>();
      ddi.destroyByType<G>();

      expect(() => ddi.get(qualifier: keys2[0]),
          throwsA(isA<BeanNotFoundException>()));
      expect(() => ddi.get(qualifier: keys2[1]),
          throwsA(isA<BeanNotFoundException>()));
    });

    test(
        'Future Factory Singleton Get bean by Type that have registered and dispose',
        () async {
      await ddi.register<G>(
        qualifier: 'firtsClass',
        factoryClazz: FactoryClazz.singleton(
          clazzFactory: () async {
            await Future.delayed(const Duration(milliseconds: 200));
            return H();
          }.factory,
        ),
      );

      final List<Object> keys1 = ddi.getByType<G>();

      expect(keys1.length, 1);
      await ddi.register<G>(
        qualifier: 'secondClass',
        factoryClazz: FactoryClazz.singleton(
          clazzFactory: () async {
            await Future.delayed(const Duration(milliseconds: 200));
            return I();
          }.factory,
        ),
      );

      final List<Object> keys2 = ddi.getByType<G>();

      expect(keys2.length, 2);

      final G instance1 = await ddi.getAsync(qualifier: keys2[0]);
      final G instance2 = await ddi.getAsync(qualifier: keys2[1]);

      expect(instance1.area(), instance2.area() / 2);

      ddi.disposeByType<G>();
      ddi.destroyByType<G>();

      expect(() => ddi.get(qualifier: keys2[0]),
          throwsA(isA<BeanNotFoundException>()));
      expect(() => ddi.get(qualifier: keys2[1]),
          throwsA(isA<BeanNotFoundException>()));
    });

    test(
        'Future Factory Dependent Get bean by Type that have registered and dispose',
        () async {
      ddi.register<G>(
        qualifier: 'firtsClass',
        factoryClazz: FactoryClazz.dependent(
          clazzFactory: () async {
            await Future.delayed(const Duration(milliseconds: 200));
            return H();
          }.factory,
        ),
      );

      final List<Object> keys1 = ddi.getByType<G>();

      expect(keys1.length, 1);
      ddi.register<G>(
        qualifier: 'secondClass',
        factoryClazz: FactoryClazz.dependent(
          clazzFactory: () async {
            await Future.delayed(const Duration(milliseconds: 200));
            return I();
          }.factory,
        ),
      );

      final List<Object> keys2 = ddi.getByType<G>();

      expect(keys2.length, 2);

      final G instance1 = await ddi.getAsync(qualifier: keys2[0]);
      final G instance2 = await ddi.getAsync(qualifier: keys2[1]);

      expect(instance1.area(), instance2.area() / 2);

      ddi.disposeByType<G>();
      ddi.destroyByType<G>();

      expect(() => ddi.get(qualifier: keys2[0]),
          throwsA(isA<BeanNotFoundException>()));
      expect(() => ddi.get(qualifier: keys2[1]),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Future Factory and Non Future Singleton getByType', () async {
      await ddi.register<G>(
        qualifier: 'firtsClass',
        factoryClazz: FactoryClazz.singleton(
          clazzFactory: () async {
            await Future.delayed(const Duration(milliseconds: 200));
            return H();
          }.factory,
        ),
      );

      final List<Object> keys1 = ddi.getByType<G>();

      expect(keys1.length, 1);
      ddi.register<G>(
          factoryClazz: I.new.factory.asSingleton(), qualifier: 'secondClass');

      final List<Object> keys2 = ddi.getByType<G>();

      expect(keys2.length, 2);

      final G instance1 = await ddi.getAsync(qualifier: keys2[0]);
      final G instance2 = await ddi.getAsync(qualifier: keys2[1]);

      expect(instance1.area(), instance2.area() / 2);

      ddi.disposeByType<G>();
      ddi.destroyByType<G>();

      expect(() => ddi.get(qualifier: keys2[0]),
          throwsA(isA<BeanNotFoundException>()));
      expect(() => ddi.get(qualifier: keys2[1]),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Future Factory and Non Future Application getByType', () async {
      await ddi.register<G>(
        qualifier: 'firtsClass',
        factoryClazz: FactoryClazz.application(
          clazzFactory: () async {
            await Future.delayed(const Duration(milliseconds: 200));
            return H();
          }.factory,
        ),
      );

      final List<Object> keys1 = ddi.getByType<G>();

      expect(keys1.length, 1);
      ddi.register<G>(
          factoryClazz: I.new.factory.asApplication(),
          qualifier: 'secondClass');

      final List<Object> keys2 = ddi.getByType<G>();

      expect(keys2.length, 2);

      final G instance1 = await ddi.getAsync(qualifier: keys2[0]);
      final G instance2 = await ddi.getAsync(qualifier: keys2[1]);

      expect(instance1.area(), instance2.area() / 2);

      ddi.disposeByType<G>();
      ddi.destroyByType<G>();

      expect(() => ddi.get(qualifier: keys2[0]),
          throwsA(isA<BeanNotFoundException>()));
      expect(() => ddi.get(qualifier: keys2[1]),
          throwsA(isA<BeanNotFoundException>()));
    });
  });
}
