import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/c.dart';
import '../clazz_samples/g.dart';
import '../clazz_samples/h.dart';
import '../clazz_samples/i.dart';

class _AsyncZonePreDestroyBean with PreDestroy {
  _AsyncZonePreDestroyBean(this.origin);

  final String origin;

  @override
  Future<void> onPreDestroy() async {
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
}

void main() {
  group('DDI Zone Context Basic Tests', () {
    final newDdi = DDI.newInstance(enableZoneRegistry: true);

    tearDownAll(() {
      expect(newDdi.isEmpty, true);
    });

    test('Must create the Beans in separated zone', () async {
      newDdi.singleton<G>(H.new);

      await newDdi.runInContext('zone1', () async {
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

      await newDdi.runInContext('zone1', () async {
        expect(newDdi.isRegistered<C>(), isTrue);

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
      newDdi.runInContext('zone1', () {
        newDdi.singleton<String>(() => 'Zone 1 String',
            qualifier: 'zoneString');

        newDdi.runInContext<void>('zone2', () {
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
          expect(newDdi.isRegistered<String>(qualifier: 'zoneString'), true);
        });

        expect(
          newDdi.get<String>(qualifier: 'zoneString'),
          equals('Zone 1 String'),
        );
      });
    });

    test(
      'beans registered in an async context should remain available until the async body completes',
      () async {
        final localDdi = DDI.newInstance(enableZoneRegistry: true);

        await localDdi.runInContext('zone-async', () async {
          await localDdi.singleton<String>(
            () => 'inside-context',
            qualifier: 'asyncString',
          );

          expect(
            localDdi.isRegistered<String>(qualifier: 'asyncString'),
            isTrue,
          );
          expect(
            localDdi.get<String>(qualifier: 'asyncString'),
            equals('inside-context'),
          );

          await Future<void>.delayed(const Duration(milliseconds: 1));

          expect(
            localDdi.isRegistered<String>(qualifier: 'asyncString'),
            isTrue,
          );
          expect(
            localDdi.get<String>(qualifier: 'asyncString'),
            equals('inside-context'),
          );
        });

        expect(
          localDdi.isRegistered<String>(qualifier: 'asyncString'),
          isFalse,
        );
      },
    );

    test(
      'nested async contexts should restore the parent zone after the child completes',
      () async {
        final localDdi = DDI.newInstance(enableZoneRegistry: true);

        await localDdi.runInContext('outer-zone', () async {
          await localDdi.singleton<String>(
            () => 'outer',
            qualifier: 'nestedString',
          );

          await localDdi.runInContext('inner-zone', () async {
            await localDdi.singleton<String>(
              () => 'inner',
              qualifier: 'nestedString',
            );

            expect(
              localDdi.get<String>(qualifier: 'nestedString'),
              equals('inner'),
            );

            await Future<void>.delayed(const Duration(milliseconds: 1));

            expect(
              localDdi.get<String>(qualifier: 'nestedString'),
              equals('inner'),
            );
          });

          expect(
            localDdi.get<String>(qualifier: 'nestedString'),
            equals('outer'),
          );
        });

        expect(
          localDdi.isRegistered<String>(qualifier: 'nestedString'),
          isFalse,
        );
      },
    );

    test(
      'async cleanup started by runInContext should not remove the root bean after context restore',
      () async {
        final localDdi = DDI.newInstance(enableZoneRegistry: true);

        await localDdi.object<_AsyncZonePreDestroyBean>(
          _AsyncZonePreDestroyBean('root'),
          qualifier: 'bean',
        );

        localDdi.runInContext('zone-1', () {
          localDdi.object<_AsyncZonePreDestroyBean>(
            _AsyncZonePreDestroyBean('context'),
            qualifier: 'bean',
          );
        });

        await Future<void>.delayed(const Duration(milliseconds: 5));

        expect(
          localDdi.get<_AsyncZonePreDestroyBean>(qualifier: 'bean').origin,
          equals('root'),
        );
      },
    );

    test(
      'runInContext should cleanup zone beans even when body throws synchronously',
      () async {
        final localDdi = DDI.newInstance(enableZoneRegistry: true);

        await localDdi.singleton<String>(() => 'root', qualifier: 'message');

        expect(
          () => localDdi.runInContext('zone-error', () {
            localDdi.singleton<String>(() => 'zone', qualifier: 'message');
            throw StateError('zone-failure');
          }),
          throwsA(isA<StateError>()),
        );

        expect(localDdi.get<String>(qualifier: 'message'), equals('root'));
      },
    );
  });
}
