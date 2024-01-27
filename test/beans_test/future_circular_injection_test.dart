import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:dart_ddi/src/exception/circular_detection.dart';
import 'package:test/test.dart';

import '../clazz_samples/c.dart';
import '../clazz_samples/father.dart';
import '../clazz_samples/mother.dart';

void futureCircularDetection() {
  group('DDI Future Circular Injection Detection tests', () {
    test('Inject a Singleton bean depending from a bean that not exists yet',
        () {
      expectLater(
          () => DDI.instance.registerSingleton(
              () => Future.value(Father(mother: DDI.instance()))),
          throwsA(isA<BeanNotFound>()));
    });

    test('Inject a Application bean depending from a bean that not exists yet',
        () {
      //Work because just Register
      DDI.instance.registerApplication<Future<Father>>(() async =>
          Future.value(Father(mother: await DDI.instance<Future<Mother>>())));
      DDI.instance.registerApplication<Future<Mother>>(() async =>
          Future.value(Mother(father: await DDI.instance<Future<Father>>())));

      DDI.instance.destroy<Future<Mother>>();
      DDI.instance.destroy<Future<Father>>();
    });

    test('Inject a Application bean with circular dependency', () {
      DDI.instance.registerApplication<Future<Father>>(() async =>
          Future.value(Father(mother: await DDI.instance<Future<Mother>>())));
      DDI.instance.registerApplication<Future<Mother>>(() async =>
          Future.value(Mother(father: await DDI.instance<Future<Father>>())));

      expectLater(() => DDI.instance<Future<Mother>>(),
          throwsA(isA<CircularDetection>()));

      DDI.instance.destroy<Future<Mother>>();
      DDI.instance.destroy<Future<Father>>();
    });

    test('Inject a Dependent bean with circular dependency', () {
      DDI.instance.registerDependent<Future<Father>>(() async =>
          Future.value(Father(mother: await DDI.instance<Future<Mother>>())));

      DDI.instance.registerDependent<Future<Mother>>(() async =>
          Future.value(Mother(father: await DDI.instance<Future<Father>>())));

      expectLater(() => DDI.instance<Future<Mother>>(),
          throwsA(isA<CircularDetection>()));

      DDI.instance.destroy<Future<Mother>>();
      DDI.instance.destroy<Future<Father>>();
    });

    test('Inject a Session bean with circular dependency', () {
      DDI.instance.registerSession<Future<Father>>(() async =>
          Future.value(Father(mother: await DDI.instance<Future<Mother>>())));

      DDI.instance.registerSession<Future<Mother>>(() async =>
          Future.value(Mother(father: await DDI.instance<Future<Father>>())));

      expectLater(() => DDI.instance<Future<Mother>>(),
          throwsA(isA<CircularDetection>()));

      DDI.instance.destroy<Future<Mother>>();
      DDI.instance.destroy<Future<Father>>();
    });

    test('Get the same Singleton bean 10 times', () async {
      DDI.instance.registerSingleton(() => Future.value(C()));

      int count = 0;
      for (int i = 0; i < 10; i++) {
        final C val = await DDI.instance<Future<C>>();
        count += val.value;
      }

      expectLater(count, 10);

      DDI.instance.destroy<Future<C>>();
    });

    test('Get the same Application bean 10 times', () async {
      DDI.instance.registerApplication(() => Future.value(C()));

      int count = 0;
      for (int i = 0; i < 10; i++) {
        final C val = await DDI.instance<Future<C>>();
        count += val.value;
      }

      expectLater(count, 10);

      DDI.instance.destroy<Future<C>>();
    });

    test('Get the same Session bean 10 times', () async {
      DDI.instance.registerSession(() async {
        await Future.delayed(const Duration(milliseconds: 200));
        return Future.value(C());
      });

      int count = 0;
      for (int i = 0; i < 10; i++) {
        final C val = await DDI.instance<Future<C>>();
        count += val.value;
      }

      expectLater(count, 10);

      DDI.instance.destroy<Future<C>>();
    });

    test('Get the same Dependent bean 10 times', () async {
      DDI.instance.registerDependent(() => Future.value(C()));

      int count = 0;
      for (int i = 0; i < 10; i++) {
        final C val = await DDI.instance<Future<C>>();
        count += val.value;
      }

      expectLater(count, 10);

      DDI.instance.destroy<Future<C>>();
    });
  });
}
