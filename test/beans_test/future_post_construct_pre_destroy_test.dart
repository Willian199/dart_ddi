import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/l.dart';

void futurePostConstructPreDestroyTest() {
  group('DDI Future PostConstruct and PreDestroy test', () {
    test('Regsiter a Singleton bean with PostConstruct  and PreDestroy', () async {
      await DDI.instance.registerSingleton(() => Future.delayed(const Duration(milliseconds: 200), L.new));

      final L instance = await DDI.instance.getAsync<L>();

      expect(instance.value, 'abcd');

      DDI.instance.destroy<L>();
    });

    test('Regsiter a Applcation bean with PostConstruct  and PreDestroy', () async {
      DDI.instance.registerApplication(() => Future.delayed(const Duration(milliseconds: 200), L.new));

      final L instance = await DDI.instance.getAsync<L>();

      expect(instance.value, 'abcd');

      DDI.instance.destroy<L>();
    });

    test('Regsiter a Session bean with PostConstruct  and PreDestroy', () async {
      DDI.instance.registerSession(() => Future.delayed(const Duration(milliseconds: 200), L.new));

      final L instance = await DDI.instance.getAsync<L>();

      expect(instance.value, 'abcd');

      DDI.instance.destroy<L>();
    });

    test('Regsiter a Dependent bean with PostConstruct  and PreDestroy', () async {
      DDI.instance.registerDependent(() => Future.delayed(const Duration(milliseconds: 200), L.new));

      final L instance = await DDI.instance.getAsync<L>();

      expect(instance.value, 'abcd');

      DDI.instance.destroy<L>();
    });

    test('Regsiter a Object bean with PostConstruct  and PreDestroy', () async {
      Future<L> loadValue() async {
        await Future.delayed(const Duration(milliseconds: 200));

        return L();
      }

      DDI.instance.registerObject(loadValue());

      final L instance = await DDI.instance.get<Future<L>>();

      expect(instance.value, 'abcd');

      DDI.instance.destroy<Future<L>>();
    });
  });
}
