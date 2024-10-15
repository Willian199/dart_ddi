import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:dart_ddi/src/exception/concurrent_creation.dart';
import 'package:test/test.dart';

import '../clazz_samples/father.dart';
import '../clazz_samples/mother.dart';

void factoryCircularDetection() {
  group('DDI Factory Circular Injection Detection tests', () {
    test('Inject a Factory Singleton bean depending from a bean that not exists yet', () {
      expect(() => ddi.register(factoryClazz: Father.fromMother.factory.asSingleton()), throwsA(isA<BeanNotFoundException>()));
    });

    test('Inject a Factory Application bean depending from a bean that not exists yet', () {
      //This works because it was just registered

      ddi.register(factoryClazz: Father.fromMother.factory.asApplication());
      ddi.register(factoryClazz: Mother.fromFather.factory.asApplication());

      ddi.destroy<Mother>();
      ddi.destroy<Father>();
    });

    test('Inject a Factory Application bean with circular dependency', () {
      ddi.register(factoryClazz: Father.fromMother.factory.asApplication());
      ddi.register(factoryClazz: Mother.fromFather.factory.asApplication());

      expect(() => ddi<Mother>(), throwsA(isA<ConcurrentCreationException>()));

      ddi.destroy<Mother>();
      ddi.destroy<Father>();
    });

    test('Inject a Factory Dependent bean with circular dependency', () {
      ddi.register(factoryClazz: Father.fromMother.factory.asDependent());
      ddi.register(factoryClazz: Mother.fromFather.factory.asDependent());

      expect(() => ddi<Mother>(), throwsA(isA<ConcurrentCreationException>()));

      ddi.destroy<Mother>();
      ddi.destroy<Father>();
    });

    test('Inject a Factory Singleton bean depending from a bean that not exists yet', () {
      expect(
          () => ddi.register(
                factoryClazz: FactoryClazz.singleton(
                  clazzFactory: () {
                    return Future.delayed(const Duration(milliseconds: 10), () => Father(mother: ddi()));
                  }.factory,
                ),
              ),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Inject a Future Factory Application bean depending from a bean that not exists yet', () {
      //This works because it was just registered
      ddi.register<Father>(
        factoryClazz: FactoryClazz.application(
          clazzFactory: () async {
            return Future.delayed(const Duration(milliseconds: 10), () async => Father(mother: await ddi.getAsync<Mother>()));
          }.factory,
        ),
      );

      ddi.register<Mother>(
        factoryClazz: FactoryClazz.application(
          clazzFactory: () async {
            return Future.delayed(const Duration(milliseconds: 10), () async => Mother(father: await ddi.getAsync<Father>()));
          }.factory,
        ),
      );

      ddi.destroy<Mother>();
      ddi.destroy<Father>();
    });

    test('Inject a Future Factory Application bean with circular dependency', () async {
      ddi.register<Father>(
        factoryClazz: FactoryClazz.application(
          clazzFactory: () async {
            return Future.delayed(const Duration(milliseconds: 10), () async => Father(mother: await ddi.getAsync<Mother>()));
          }.factory,
        ),
      );

      ddi.register<Mother>(
        factoryClazz: FactoryClazz.application(
          clazzFactory: () async {
            return Future.delayed(const Duration(milliseconds: 10), () async => Mother(father: await ddi.getAsync<Father>()));
          }.factory,
        ),
      );

      await expectLater(() async => ddi.getAsync<Mother>(), throwsA(isA<ConcurrentCreationException>()));

      ddi.destroy<Mother>();
      ddi.destroy<Father>();
    });

    test('Inject a Future Factory Dependent bean with circular dependency', () async {
      ddi.register<Father>(
        factoryClazz: FactoryClazz.dependent(
          clazzFactory: () async {
            return Future.delayed(const Duration(milliseconds: 10), () async => Father(mother: await ddi.getAsync<Mother>()));
          }.factory,
        ),
      );

      ddi.register<Mother>(
        factoryClazz: FactoryClazz.dependent(
          clazzFactory: () async {
            return Future.delayed(const Duration(milliseconds: 10), () async => Mother(father: await ddi.getAsync<Father>()));
          }.factory,
        ),
      );

      await expectLater(() async => ddi.getAsync<Mother>(), throwsA(isA<ConcurrentCreationException>()));

      ddi.destroy<Mother>();
      ddi.destroy<Father>();
    });
  });
}
