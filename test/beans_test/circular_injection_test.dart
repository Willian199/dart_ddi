import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:dart_ddi/src/exception/concurrent_creation.dart';
import 'package:test/test.dart';

import '../clazz_samples/c.dart';
import '../clazz_samples/father.dart';
import '../clazz_samples/mother.dart';

void main() {
  group('DDI Circular Injection Detection tests', () {
    tearDownAll(() {
      expect(ddi.isEmpty, true);
    });

    test(
      'Inject a Singleton bean depending from a bean that not exists yet',
      () {
        expect(
          () => DDI.instance.singleton(() => Father(mother: DDI.instance())),
          throwsA(isA<BeanNotFoundException>()),
        );
      },
    );

    test(
      'Inject a Application bean depending from a bean that not exists yet',
      () {
        //This works because it was just registered
        DDI.instance.application(() => Father(mother: DDI.instance()));
        DDI.instance.application(() => Mother(father: DDI.instance()));

        expect(DDI.instance.isReady<Father>(), false);
        expect(DDI.instance.isReady<Mother>(), false);

        DDI.instance.destroy<Mother>();
        DDI.instance.destroy<Father>();
      },
    );

    test('Inject a Application bean with circular dependency', () {
      DDI.instance.application(() => Father(mother: DDI.instance()));
      DDI.instance.application(() => Mother(father: DDI.instance()));

      expect(DDI.instance.isReady<Father>(), false);
      expect(DDI.instance.isReady<Mother>(), false);

      expect(
        () => DDI.instance.get<Mother>(),
        throwsA(isA<ConcurrentCreationException>()),
      );

      DDI.instance.destroy<Mother>();
      DDI.instance.destroy<Father>();

      expect(DDI.instance.isRegistered<Father>(), false);
      expect(DDI.instance.isRegistered<Mother>(), false);
    });

    test('Inject a Dependent bean with circular dependency', () {
      DDI.instance.dependent(() => Father(mother: DDI.instance()));
      DDI.instance.dependent(() => Mother(father: DDI.instance()));

      expect(
        () => DDI.instance.get<Mother>(),
        throwsA(isA<ConcurrentCreationException>()),
      );

      DDI.instance.destroy<Mother>();
      DDI.instance.destroy<Father>();
    });

    test('Get the same Singleton bean 100 times', () {
      DDI.instance.singleton(() => C());

      int count = 0;
      for (int i = 0; i < 100; i++) {
        count += DDI.instance.get<C>().value;
      }

      expectLater(count, 100);

      DDI.instance.destroy<C>();
    });

    test('Get the same Application bean 100 times', () {
      DDI.instance.application(() => C());

      int count = 0;
      for (int i = 0; i < 100; i++) {
        count += DDI.instance.get<C>().value;
      }

      expectLater(count, 100);

      DDI.instance.destroy<C>();
    });

    test('Get the same Dependent bean 100 times', () {
      DDI.instance.dependent(() => C());

      int count = 0;
      for (int i = 0; i < 100; i++) {
        count += DDI.instance.get<C>().value;
      }

      expectLater(count, 100);

      DDI.instance.destroy<C>();
    });
  });
}
