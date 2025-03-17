import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:test/test.dart';

import '../clazz_samples/c.dart';
import '../clazz_samples/g.dart';
import '../clazz_samples/h.dart';
import '../clazz_samples/i.dart';

void zoneContext() {
  group('DDI Zone Context Basic Tests', () {
    test('Must create the Beans in separated zone', () async {
      ddi.registerSingleton<G>(H.new);

      await ddi.runInZone('zone1', () async {
        ddi.registerSingleton<G>(I.new);

        expect(ddi.isRegistered<G>(), isTrue);

        expect(ddi.get<G>().area(), 20);
      });

      expect(ddi.get<G>().area(), 10);

      expect(ddi.isRegistered<G>(), isTrue);

      ddi.destroy<G>();

      expect(ddi.isRegistered<G>(), isFalse);
    });

    test('Create a Global and acess in a zone', () async {
      ddi.registerSingleton<C>(() => C());

      expect(ddi.isRegistered<C>(), isTrue);

      await ddi.runInZone('zone1', () async {
        expect(ddi.isRegistered<C>(), isFalse);

        ddi.registerSingleton<G>(I.new);

        expect(ddi.isRegistered<G>(), isTrue);

        expect(ddi.get<G>().area(), 20);

        expect(ddi.get<C>().value, 1);
      });

      ddi.destroy<C>();
      expect(ddi.isRegistered<G>(), isFalse);
      expect(ddi.isRegistered<C>(), isFalse);
      expect(() => ddi.get<G>(), throwsA(isA<BeanNotFoundException>()));
    });

    test('Zones devem ser completamente isoladas umas das outras', () async {
      ddi.runInZone('zone1', () {
        ddi.registerSingleton<String>(() => 'Zone 1 String',
            qualifier: 'zoneString');

        ddi.runInZone<void>('zone2', () {
          ddi.registerSingleton<String>(() => 'Zone 2 String',
              qualifier: 'zoneString');

          expect(ddi.get<String>(qualifier: 'zoneString'),
              equals('Zone 2 String'));

          expect(() => ddi.get<String>(qualifier: 'zoneString2'),
              throwsA(isA<BeanNotFoundException>()));

          ddi.destroy<String>(qualifier: 'zoneString');
          expect(ddi.isRegistered<String>(qualifier: 'zoneString'), false);
        });

        expect(
            ddi.get<String>(qualifier: 'zoneString'), equals('Zone 1 String'));
      });
    });
  });
}
