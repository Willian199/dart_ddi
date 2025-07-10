import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/l.dart';

void main() {
  group('DDI Future PostConstruct and PreDestroy test', () {
    test('Regsiter a Singleton bean with PostConstruct  and PreDestroy',
        () async {
      await DDI.instance.singleton(
          () => Future.delayed(const Duration(milliseconds: 200), L.new));

      final L instance = await DDI.instance.getAsync<L>();

      expect(instance.value, 'abcd');

      DDI.instance.destroy<L>();
    });

    test('Regsiter a Applcation bean with PostConstruct  and PreDestroy',
        () async {
      DDI.instance.application(
          () => Future.delayed(const Duration(milliseconds: 200), L.new));

      final L instance = await DDI.instance.getAsync<L>();

      expect(instance.value, 'abcd');

      DDI.instance.destroy<L>();
    });

    test('Regsiter a Dependent bean with PostConstruct  and PreDestroy',
        () async {
      DDI.instance.dependent(
          () => Future.delayed(const Duration(milliseconds: 200), L.new));

      final L instance = await DDI.instance.getAsync<L>();

      expect(instance.value, 'abcd');

      DDI.instance.destroy<L>();
    });

    test('Regsiter a Object bean with PostConstruct  and PreDestroy', () async {
      Future<L> loadValue() async {
        await Future.delayed(const Duration(milliseconds: 200));

        return L();
      }

      DDI.instance.register(factory: ObjectFactory(instance: loadValue()));

      final L instance = await DDI.instance.get<Future<L>>();

      expect(instance.value, 'abcd');

      DDI.instance.destroy<Future<L>>();
    });
  });
}
