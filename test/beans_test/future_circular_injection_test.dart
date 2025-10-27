import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:dart_ddi/src/exception/concurrent_creation.dart';
import 'package:test/test.dart';

import '../clazz_samples/c.dart';
import '../clazz_samples/father.dart';
import '../clazz_samples/mother.dart';

void main() {
  group('DDI Future Circular Injection Detection tests', () {
    tearDownAll(
      () {
        expect(ddi.isEmpty, true);
      },
    );
    test('Inject a Singleton bean depending from a bean that not exists yet',
        () async {
      await expectLater(
          () => DDI.instance
              .singleton(() => Future.value(Father(mother: ddi.get<Mother>()))),
          throwsA(isA<BeanNotFoundException>()));
      expect(DDI.instance.isRegistered<Father>(), false);
    });

    test('Inject a Application bean depending from a bean that not exists yet',
        () {
      //This works because it was just registered
      DDI.instance.application<Father>(() async =>
          Future.value(Father(mother: await DDI.instance.getAsync<Mother>())));
      DDI.instance.application<Mother>(() async =>
          Future.value(Mother(father: await DDI.instance.getAsync<Father>())));

      DDI.instance.destroy<Mother>();
      DDI.instance.destroy<Father>();

      expect(DDI.instance.isRegistered<Father>(), false);
      expect(DDI.instance.isRegistered<Mother>(), false);
    });

    test('Inject a Application bean with circular dependency', () async {
      DDI.instance.application<Father>(() async =>
          Future.value(Father(mother: await DDI.instance.getAsync<Mother>())));
      DDI.instance.application<Mother>(() async =>
          Future.value(Mother(father: await DDI.instance.getAsync<Father>())));

      await expectLater(() => DDI.instance.getAsync<Mother>(),
          throwsA(isA<ConcurrentCreationException>()));

      DDI.instance.destroy<Mother>();
      DDI.instance.destroy<Father>();

      expect(DDI.instance.isRegistered<Father>(), false);
      expect(DDI.instance.isRegistered<Mother>(), false);
    });

    test('Inject a Dependent bean with circular dependency', () {
      DDI.instance.dependent<Father>(() async =>
          Future.value(Father(mother: await DDI.instance.getAsync<Mother>())));

      DDI.instance.dependent<Mother>(() async =>
          Future.value(Mother(father: await DDI.instance.getAsync<Father>())));

      expectLater(() => DDI.instance.getAsync<Mother>(),
          throwsA(isA<ConcurrentCreationException>()));

      DDI.instance.destroy<Mother>();
      DDI.instance.destroy<Father>();

      expect(DDI.instance.isRegistered<Father>(), false);
      expect(DDI.instance.isRegistered<Mother>(), false);
    });

    test('Get the same Singleton bean 10 times', () async {
      await DDI.instance.singleton(() async {
        await Future.delayed(const Duration(milliseconds: 20));
        return C();
      });

      expect(DDI.instance.isRegistered<C>(), true);
      expect(DDI.instance.isReady<C>(), true);

      int count = 0;
      for (int i = 0; i < 10; i++) {
        final C val = await DDI.instance.getAsync<C>();
        count += val.value;
      }

      expectLater(count, 10);

      DDI.instance.destroy<C>();

      expect(DDI.instance.isRegistered<C>(), false);
    });

    test('Get the same Singleton without await register', () async {
      DDI.instance.singleton(() async {
        await Future.delayed(const Duration(milliseconds: 20));
        return C();
      });

      expect(DDI.instance.isRegistered<C>(), true);
      expect(DDI.instance.isReady<C>(), false);

      int count = 0;
      for (int i = 0; i < 10; i++) {
        final C val = await DDI.instance.getAsync<C>();
        count += val.value;
      }

      expectLater(count, 10);

      DDI.instance.destroy<C>();

      expect(DDI.instance.isRegistered<C>(), false);
    });

    test('Get the same Application bean 10 times', () async {
      DDI.instance.application(() async {
        await Future.delayed(const Duration(milliseconds: 20));
        return C();
      });

      expect(DDI.instance.isRegistered<C>(), true);
      expect(DDI.instance.isReady<C>(), false);

      int count = 0;
      for (int i = 0; i < 10; i++) {
        final C val = await DDI.instance.getAsync<C>();
        count += val.value;
      }

      expectLater(count, 10);

      DDI.instance.destroy<C>();

      expect(DDI.instance.isRegistered<C>(), false);
    });

    test('Get the same Dependent bean 10 times', () async {
      DDI.instance.dependent(() async {
        await Future.delayed(const Duration(milliseconds: 20));
        return C();
      });

      expect(DDI.instance.isRegistered<C>(), true);
      expect(DDI.instance.isReady<C>(), false);

      int count = 0;
      for (int i = 0; i < 10; i++) {
        final C val = await DDI.instance.getAsync<C>();
        count += val.value;
      }

      expectLater(count, 10);

      DDI.instance.destroy<C>();

      expect(DDI.instance.isRegistered<C>(), false);
    });
  });
}
