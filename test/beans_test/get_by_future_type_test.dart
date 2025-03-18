import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:test/test.dart';

import '../clazz_samples/g.dart';
import '../clazz_samples/h.dart';
import '../clazz_samples/i.dart';

void runByFutureType() {
  group('DDI Process Future By Type', () {
    test('Application Get bean by Type that have registered and dispose',
        () async {
      ///Where is Singleton, should the register in the correct order
      DDI.instance
          .application<G>(() => Future.value(H()), qualifier: 'firtsClass');

      final List<Object> keys1 = DDI.instance.getByType<G>();

      expect(keys1.length, 1);
      DDI.instance
          .application<G>(() => Future.value(I()), qualifier: 'secondClass');

      final List<Object> keys2 = DDI.instance.getByType<G>();

      expect(keys2.length, 2);

      final G instance1 = await DDI.instance.getAsync<G>(qualifier: keys2[0]);
      final G instance2 = await DDI.instance.getAsync<G>(qualifier: keys2[1]);

      expect(instance1.area(), instance2.area() / 2);

      DDI.instance.disposeByType<G>();
      DDI.instance.destroyByType<G>();

      expect(() => DDI.instance.getAsync(qualifier: keys2[0]),
          throwsA(isA<BeanNotFoundException>()));
      expect(() => DDI.instance.getAsync(qualifier: keys2[1]),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Dependent Get bean by Type that have registered and dispose',
        () async {
      DDI.instance.dependent<G>(() => H(), qualifier: 'firtsClass');

      final List<Object> keys1 = DDI.instance.getByType<G>();

      expect(keys1.length, 1);
      DDI.instance
          .dependent<G>(() => Future.value(I()), qualifier: 'secondClass');

      final List<Object> keys2 = DDI.instance.getByType<G>();

      expect(keys2.length, 2);

      final G instance1 = await DDI.instance.getAsync<G>(qualifier: keys2[0]);
      final G instance2 = await DDI.instance.getAsync<G>(qualifier: keys2[1]);

      expect(instance1.area(), instance2.area() / 2);

      DDI.instance.disposeByType<G>();
      DDI.instance.destroyByType<G>();

      expect(() => DDI.instance.get(qualifier: keys2[0]),
          throwsA(isA<BeanNotFoundException>()));
      expect(() => DDI.instance.get(qualifier: keys2[1]),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Get bean by Type that have registered and dispose', () async {
      DDI.instance.application<G>(
          () => Future.delayed(const Duration(milliseconds: 500), H.new),
          qualifier: 'firtsClass');

      final List<Object> keys1 = DDI.instance.getByType<G>();

      expect(keys1.length, 1);
      DDI.instance.dependent<G>(I.new, qualifier: 'secondClass');

      final List<Object> keys2 = DDI.instance.getByType<G>();

      expect(keys2.length, 2);

      final G instance1 = await DDI.instance.getAsync<G>(qualifier: keys2[0]);
      final G instance2 = await DDI.instance.getAsync<G>(qualifier: keys2[1]);

      expect(instance1.area(), instance2.area() / 2);

      DDI.instance.disposeByType<G>();
      DDI.instance.destroyByType<G>();

      expect(() => DDI.instance.get(qualifier: keys2[0]),
          throwsA(isA<BeanNotFoundException>()));
      expect(() => DDI.instance.get(qualifier: keys2[1]),
          throwsA(isA<BeanNotFoundException>()));
    });
  });
}
