import 'package:dart_ddi/dart_ddi.dart';
import 'package:flutter_test/flutter_test.dart';

import '../clazz_test/l.dart';

void postConstructPreDestroyTest() {
  group('DDI PostConstruct and PreDestroy test', () {
    test('Regsiter a Singleton bean with PostConstruct  and PreDestroy', () {
      DDI.instance.registerSingleton(() => L());

      DDI.instance.get<L>();

      DDI.instance.destroy<L>();
    });

    test('Regsiter a Applcation bean with PostConstruct  and PreDestroy', () {
      DDI.instance.registerApplication(() => L());

      DDI.instance.get<L>();

      DDI.instance.destroy<L>();
    });

    test('Regsiter a Session bean with PostConstruct  and PreDestroy', () {
      DDI.instance.registerSession(() => L());

      DDI.instance.get<L>();

      DDI.instance.destroy<L>();
    });

    test('Regsiter a Dependent bean with PostConstruct  and PreDestroy', () {
      DDI.instance.registerDependent(() => L());

      DDI.instance.get<L>();

      DDI.instance.destroy<L>();
    });

    test('Regsiter a Object bean with PostConstruct  and PreDestroy', () {
      DDI.instance.registerObject(L());

      DDI.instance.get<L>();

      DDI.instance.destroy<L>();
    });
  });
}
