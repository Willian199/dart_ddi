import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:dart_ddi/src/exception/concurrent_creation.dart';
import 'package:test/test.dart';

import '../clazz_samples/father.dart';
import '../clazz_samples/mother.dart';

void factoryCircularDetection() {
  group('DDI Factory Circular Injection Detection tests', () {
    test('Inject a Factory Singleton bean depending from a bean that not exists yet', () async {
      await expectLater(() => Father.fromMother.builder.asSingleton(), throwsA(isA<BeanNotFoundException>()));
      expect(ddi.isRegistered<Father>(), false);
    });

    test('Inject a Factory Application bean depending from a bean that not exists yet', () {
      Father.fromMother.builder.asApplication();
      Mother.fromFather.builder.asApplication();

      expect(ddi.isRegistered<Mother>(), true);
      expect(ddi.isRegistered<Father>(), true);

      expect(ddi.isReady<Mother>(), false);
      expect(ddi.isReady<Father>(), false);

      ddi.destroy<Mother>();
      ddi.destroy<Father>();

      expect(ddi.isRegistered<Mother>(), false);
      expect(ddi.isRegistered<Father>(), false);
    });

    test('Inject a Factory Application bean with circular dependency', () {
      Father.fromMother.builder.asApplication();
      Mother.fromFather.builder.asApplication();

      expect(() => ddi.get<Mother>(), throwsA(isA<ConcurrentCreationException>()));

      ddi.destroy<Mother>();
      ddi.destroy<Father>();

      expect(ddi.isRegistered<Mother>(), false);
      expect(ddi.isRegistered<Father>(), false);
    });

    test('Inject a Factory Dependent bean with circular dependency', () {
      Father.fromMother.builder.asDependent();
      Mother.fromFather.builder.asDependent();

      expect(() => ddi.get<Mother>(), throwsA(isA<ConcurrentCreationException>()));

      ddi.destroy<Mother>();
      ddi.destroy<Father>();

      expect(ddi.isRegistered<Mother>(), false);
      expect(ddi.isRegistered<Father>(), false);
    });

    test('Inject a Factory Singleton bean depending from a bean that not exists yet', () {
      expect(
          () => ddi.register(
                factory: SingletonFactory(
                  builder: () {
                    return Future.delayed(const Duration(milliseconds: 10), () => Father(mother: ddi()));
                  }.builder,
                ),
              ),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Inject a Future Factory Application bean depending from a bean that not exists yet', () {
      //This works because it was just registered
      ddi.register<Father>(
        factory: ApplicationFactory(
          builder: () {
            return Future.delayed(const Duration(milliseconds: 10), () async => Father(mother: await ddi.getAsync<Mother>()));
          }.builder,
        ),
      );

      ddi.register<Mother>(
        factory: ApplicationFactory(
          builder: () {
            return Future.delayed(const Duration(milliseconds: 10), () async => Mother(father: await ddi.getAsync<Father>()));
          }.builder,
        ),
      );

      ddi.destroy<Mother>();
      ddi.destroy<Father>();

      expect(ddi.isRegistered<Mother>(), false);
      expect(ddi.isRegistered<Father>(), false);
    });

    test('Inject a Future Factory Application bean with circular dependency', () async {
      ddi.register<Father>(
        factory: ApplicationFactory(
          builder: () {
            return Future.delayed(const Duration(milliseconds: 10), () async => Father(mother: await ddi.getAsync<Mother>()));
          }.builder,
        ),
      );

      ddi.register<Mother>(
        factory: ApplicationFactory(
          builder: () {
            return Future.delayed(const Duration(milliseconds: 10), () async => Mother(father: await ddi.getAsync<Father>()));
          }.builder,
        ),
      );

      await expectLater(() => ddi.getAsync<Mother>(), throwsA(isA<ConcurrentCreationException>()));

      ddi.destroy<Mother>();
      ddi.destroy<Father>();

      expect(ddi.isRegistered<Mother>(), false);
      expect(ddi.isRegistered<Father>(), false);
    });

    test('Inject a Future Factory Dependent bean with circular dependency', () async {
      ddi.register<Father>(
        factory: DependentFactory(
          builder: () {
            return Future.delayed(const Duration(milliseconds: 10), () async => Father(mother: await ddi.getAsync<Mother>()));
          }.builder,
        ),
      );

      ddi.register<Mother>(
        factory: DependentFactory(
          builder: () {
            return Future.delayed(const Duration(milliseconds: 10), () async => Mother(father: await ddi.getAsync<Father>()));
          }.builder,
        ),
      );

      await expectLater(() => ddi.getAsync<Mother>(), throwsA(isA<ConcurrentCreationException>()));

      ddi.destroy<Mother>();
      ddi.destroy<Father>();

      expect(ddi.isRegistered<Mother>(), false);
      expect(ddi.isRegistered<Father>(), false);
    });
  });
}
