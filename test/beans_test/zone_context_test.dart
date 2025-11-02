import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/c.dart';
import '../clazz_samples/g.dart';
import '../clazz_samples/h.dart';
import '../clazz_samples/i.dart';

void main() {
  group('DDI Zone Context Basic Tests', () {
    final newDdi = DDI.newInstance(enableZoneRegistry: true);

    tearDownAll(() {
      expect(newDdi.isEmpty, true);
    });

    test('Must create the Beans in separated zone', () async {
      newDdi.singleton<G>(H.new);

      await newDdi.runInZone('zone1', () async {
        newDdi.singleton<G>(I.new);

        expect(newDdi.isRegistered<G>(), isTrue);

        expect(newDdi.get<G>().area(), 20);
      });

      expect(newDdi.get<G>().area(), 10);

      expect(newDdi.isRegistered<G>(), isTrue);

      newDdi.destroy<G>();

      expect(newDdi.isRegistered<G>(), isFalse);
    });

    test('Create a Global and acess in a zone', () async {
      newDdi.singleton<C>(() => C());

      expect(newDdi.isRegistered<C>(), isTrue);

      await newDdi.runInZone('zone1', () async {
        expect(newDdi.isRegistered<C>(), isFalse);

        newDdi.singleton<G>(I.new);

        expect(newDdi.isRegistered<G>(), isTrue);

        expect(newDdi.get<G>().area(), 20);

        expect(newDdi.get<C>().value, 1);
      });

      newDdi.destroy<C>();
      expect(newDdi.isRegistered<G>(), isFalse);
      expect(newDdi.isRegistered<C>(), isFalse);
      expect(() => newDdi.get<G>(), throwsA(isA<BeanNotFoundException>()));
    });

    test('Zones devem ser completamente isoladas umas das outras', () async {
      newDdi.runInZone('zone1', () {
        newDdi.singleton<String>(() => 'Zone 1 String',
            qualifier: 'zoneString');

        newDdi.runInZone<void>('zone2', () {
          newDdi.singleton<String>(() => 'Zone 2 String',
              qualifier: 'zoneString');

          expect(
            newDdi.get<String>(qualifier: 'zoneString'),
            equals('Zone 2 String'),
          );

          expect(
            () => newDdi.get<String>(qualifier: 'zoneString2'),
            throwsA(isA<BeanNotFoundException>()),
          );

          newDdi.destroy<String>(qualifier: 'zoneString');
          expect(newDdi.isRegistered<String>(qualifier: 'zoneString'), false);
        });

        expect(
          newDdi.get<String>(qualifier: 'zoneString'),
          equals('Zone 1 String'),
        );
      });
    });
  });
}
