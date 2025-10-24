import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/l.dart';

void main() {
  group('DDI PostConstruct and PreDestroy test', () {
    tearDownAll(
      () {
        expect(ddi.isEmpty, true);
      },
    );
    test('Regsiter a Singleton bean with PostConstruct  and PreDestroy', () {
      DDI.instance.singleton(() => L());

      final L instance = DDI.instance.get();

      expect('abcd', instance.value);

      DDI.instance.destroy<L>();
    });

    test('Regsiter a Applcation bean with PostConstruct  and PreDestroy', () {
      DDI.instance.application(() => L());

      final L instance = DDI.instance.get();

      expect('abcd', instance.value);

      DDI.instance.destroy<L>();
    });

    test('Regsiter a Dependent bean with PostConstruct  and PreDestroy', () {
      DDI.instance.dependent(() => L());

      final L instance = DDI.instance.get();

      expect('abcd', instance.value);

      DDI.instance.destroy<L>();
    });

    test('Regsiter a Object bean with PostConstruct  and PreDestroy', () {
      DDI.instance.object(L());

      final L instance = DDI.instance.get();

      expect('abcd', instance.value);

      DDI.instance.destroy<L>();
    });
  });
}
