import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/core/dart_ddi_default_qualifier_impl.dart';
import 'package:dart_ddi/src/core/dart_ddi_zone_qualifier_impl.dart';
import 'package:test/test.dart';

import '../clazz_samples/test_service.dart';

void main() {
  group('Qualifier Tests', () {
    group('DartDDIDefaultQualifierImpl', () {
      test('hasZoneRegistry should return false', () {
        final qualifier = DartDDIDefaultQualifierImpl();
        expect(qualifier.hasZoneRegistry(), false);
      });

      test('runWithZoneRegistry should throw UnsupportedError', () {
        final qualifier = DartDDIDefaultQualifierImpl();
        expect(
          () => qualifier.runWithZoneRegistry('test', () => 42),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('keys should return all qualifiers', () {
        final qualifier = DartDDIDefaultQualifierImpl();
        final factory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );

        qualifier.setFactory(TestService, factory);
        qualifier.setFactory('qualifier1', factory);

        expect(qualifier.keys, contains(TestService));
        expect(qualifier.keys, contains('qualifier1'));
        expect(qualifier.keys.length, 2);
      });

      test('entries should return all entries', () {
        final qualifier = DartDDIDefaultQualifierImpl();
        final factory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );

        qualifier.setFactory(TestService, factory);
        qualifier.setFactory('qualifier1', factory);

        final entries = qualifier.entries.toList();
        expect(entries.length, 2);
        expect(entries.any((e) => e.key == TestService), true);
        expect(entries.any((e) => e.key == 'qualifier1'), true);
      });
    });

    group('DartDDIZoneQualifierImpl', () {
      test('getFactory should fallback to parent zone when qualifier not found',
          () {
        final qualifier = DartDDIZoneQualifierImpl();
        final factory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );

        // Register in a parent zone
        qualifier.runWithZoneRegistry('parent', () {
          qualifier.setFactory(TestService, factory);

          // Try to get from child zone with fallback (nested zones)
          qualifier.runWithZoneRegistry('child', () {
            final retrievedFactory = qualifier.getFactory<TestService>(
              qualifier: TestService,
            );
            expect(retrievedFactory, isNotNull);
          });
        });
      });

      test(
          'getFactory should return null when fallback is false and not in current zone',
          () {
        final qualifier = DartDDIZoneQualifierImpl();
        final factory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );

        // Register in a parent zone
        qualifier.runWithZoneRegistry('parent', () {
          qualifier.setFactory(TestService, factory);

          // Try to get from child zone without fallback (nested zones)
          qualifier.runWithZoneRegistry('child', () {
            final retrievedFactory = qualifier.getFactory<TestService>(
              qualifier: TestService,
              fallback: false,
            );
            expect(retrievedFactory, isNull);
          });
        });
      });

      test('entries should return entries from current zone', () {
        final qualifier = DartDDIZoneQualifierImpl();
        final factory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );

        qualifier.runWithZoneRegistry('zone1', () {
          qualifier.setFactory(TestService, factory);
          qualifier.setFactory('qualifier1', factory);

          final entries = qualifier.entries.toList();
          expect(entries.length, 2);
          expect(entries.any((e) => e.key == TestService), true);
          expect(entries.any((e) => e.key == 'qualifier1'), true);
        });
      });

      test('isEmpty should return true when zone is empty', () {
        final qualifier = DartDDIZoneQualifierImpl();

        qualifier.runWithZoneRegistry('zone1', () {
          expect(qualifier.isEmpty, true);
        });
      });

      test('isEmpty should return false when zone has entries', () {
        final qualifier = DartDDIZoneQualifierImpl();
        final factory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );

        qualifier.runWithZoneRegistry('zone1', () {
          qualifier.setFactory(TestService, factory);
          expect(qualifier.isEmpty, false);
        });
      });

      test('length should return correct count', () {
        final qualifier = DartDDIZoneQualifierImpl();
        final factory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );

        qualifier.runWithZoneRegistry('zone1', () {
          expect(qualifier.length, 0);
          qualifier.setFactory(TestService, factory);
          expect(qualifier.length, 1);
          qualifier.setFactory('qualifier1', factory);
          expect(qualifier.length, 2);
        });
      });
    });
  });
}
