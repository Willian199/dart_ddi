import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/l.dart';

void postConstructPreDestroyTest() {
  group('DDI PostConstruct and PreDestroy test', () {
    test('Regsiter a Singleton bean with PostConstruct  and PreDestroy', () {
      DDI.instance.registerSingleton(clazzRegister: L.new);

      final L instance = DDI.instance.get();

      expect('abcd', instance.value);

      DDI.instance.destroy<L>();
    });

    test('Regsiter a Applcation bean with PostConstruct  and PreDestroy', () {
      DDI.instance.registerApplication(clazzRegister: () => L());

      final L instance = DDI.instance.get();

      expect('abcd', instance.value);

      DDI.instance.destroy<L>();
    });

    test('Regsiter a Session bean with PostConstruct  and PreDestroy', () {
      DDI.instance.registerSession(clazzRegister: L.new);

      final L instance = DDI.instance.get();

      expect('abcd', instance.value);

      DDI.instance.destroy<L>();
    });

    test('Regsiter a Dependent bean with PostConstruct  and PreDestroy', () {
      DDI.instance.registerDependent(clazzRegister: L.new);

      final L instance = DDI.instance.get();

      expect('abcd', instance.value);

      DDI.instance.destroy<L>();
    });

    test('Regsiter a Object bean with PostConstruct  and PreDestroy', () {
      DDI.instance.registerObject(L());

      final L instance = DDI.instance.get();

      expect('abcd', instance.value);

      DDI.instance.destroy<L>();
    });
  });
}
