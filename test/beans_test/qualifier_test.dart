import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/core/dart_ddi_default_qualifier_impl.dart';
import 'package:dart_ddi/src/core/dart_ddi_zone_qualifier_impl.dart';
import 'package:test/test.dart';

import '../clazz_samples/test_service.dart';

void main() {
  group('Qualifier Tests', () {
    group('DartDDIDefaultQualifierImpl', () {
      test('hasContext should return false when no context is active', () {
        final qualifier = DartDDIDefaultQualifierImpl();
        expect(qualifier.hasContext, false);
      });

      test('runWithContext should activate a context and fallback to root', () {
        final qualifier = DartDDIDefaultQualifierImpl();
        final rootFactory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );

        qualifier.setFactory(TestService, rootFactory);

        qualifier.runWithContext('test', () {
          expect(
            qualifier.getFactory<TestService>(qualifier: TestService)?.factory,
            same(rootFactory),
          );
          expect(qualifier.hasContext, true);
          return Object();
        });
      });

      test(
          'runWithContext should reuse an existing context instead of duplicating it',
          () {
        final qualifier = DartDDIDefaultQualifierImpl();
        final contextFactory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );
        final siblingFactory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );

        qualifier.runWithContext('A', () {
          qualifier.setFactory('serviceA', contextFactory);
          return Object();
        });

        qualifier.runWithContext('B', () {
          qualifier.setFactory('serviceB', siblingFactory);

          qualifier.runWithContext('A', () {
            expect(
              qualifier.getFactory<TestService>(qualifier: 'serviceA')?.factory,
              same(contextFactory),
            );
            expect(
              qualifier.getFactory<TestService>(qualifier: 'serviceB')?.factory,
              isNull,
            );
            return Object();
          });

          return Object();
        });
      });

      test(
          'remove should keep the named context alive after removing its last factory',
          () {
        final qualifier = DartDDIDefaultQualifierImpl();
        final oldParentFactory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );
        final newParentFactory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );
        final childFactory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );

        qualifier.runWithContext('old-parent', () {
          qualifier.setFactory('old-parent-service', oldParentFactory);

          qualifier.runWithContext('shared-child', () {
            qualifier.setFactory('child-service', childFactory);
            return Object();
          });

          return Object();
        });

        qualifier.removeFactory('child-service', context: 'shared-child');
        qualifier.restoreContext(null);

        qualifier.runWithContext('new-parent', () {
          qualifier.setFactory('new-parent-service', newParentFactory);

          qualifier.runWithContext('shared-child', () {
            expect(
              qualifier
                  .getFactory<TestService>(qualifier: 'new-parent-service')
                  ?.factory,
              isNull,
            );
            expect(
              qualifier
                  .getFactory<TestService>(qualifier: 'old-parent-service')
                  ?.factory,
              same(oldParentFactory),
            );
            return Object();
          });

          return Object();
        });
      });

      test(
          'remove should not change current context when deepest context becomes empty',
          () {
        final qualifier = DartDDIDefaultQualifierImpl();
        final deepFactory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );

        qualifier.createContext('A');
        qualifier.createContext('B');
        qualifier.createContext('C');
        qualifier.createContext('D');

        qualifier.setFactory('deep-service', deepFactory);
        qualifier.removeFactory('deep-service', context: 'D');

        expect(qualifier.currentContext, equals('D'));
      });

      test(
          'remove should keep descendant contexts when an intermediate context becomes empty',
          () {
        final qualifier = DartDDIDefaultQualifierImpl();
        final parentFactory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );
        final childFactory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );

        qualifier.createContext('A');
        qualifier.createContext('B');
        qualifier.setFactory('service-b', parentFactory);
        qualifier.createContext('C');
        qualifier.setFactory('service-c', childFactory);

        qualifier.removeFactory('service-b', context: 'B');

        expect(
          qualifier
              .getFactory<TestService>(
                qualifier: 'service-c',
                contextQualifier: 'C',
                fallback: false,
              )
              ?.factory,
          same(childFactory),
        );
        expect(
          qualifier.getFactory<TestService>(qualifier: 'service-b')?.factory,
          isNull,
        );
      });

      test('remove should not cascade prune descendants of the removed context',
          () {
        final qualifier = DartDDIDefaultQualifierImpl();
        final factoryB = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );
        final factoryC = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );
        final factoryD = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );

        qualifier.createContext('A');
        qualifier.createContext('B');
        qualifier.setFactory('service-b', factoryB);
        qualifier.createContext('C');
        qualifier.setFactory('service-c', factoryC);
        qualifier.createContext('D');
        qualifier.setFactory('service-d', factoryD);

        qualifier.removeFactory('service-b', context: 'B');

        expect(
          qualifier
              .getFactory<TestService>(
                qualifier: 'service-c',
                contextQualifier: 'C',
                fallback: false,
              )
              ?.factory,
          same(factoryC),
        );
        expect(
          qualifier
              .getFactory<TestService>(
                qualifier: 'service-d',
                contextQualifier: 'D',
                fallback: false,
              )
              ?.factory,
          same(factoryD),
        );
      });

      test('remove should keep current context when removing a parent factory',
          () {
        final qualifier = DartDDIDefaultQualifierImpl();
        final factoryB = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );
        final factoryC = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );

        qualifier.createContext('A');
        qualifier.createContext('B');
        qualifier.setFactory('service-b', factoryB);
        qualifier.createContext('C');
        qualifier.setFactory('service-c', factoryC);

        expect(qualifier.currentContext, equals('C'));

        qualifier.removeFactory('service-b', context: 'B');

        expect(qualifier.currentContext, equals('C'));
      });

      test(
          'remove should not prune sibling branches when removing an intermediate context',
          () {
        final qualifier = DartDDIDefaultQualifierImpl();
        final factoryB = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );
        final siblingFactory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );

        qualifier.createContext('A');
        qualifier.createContext('B');
        qualifier.setFactory('service-b', factoryB);
        qualifier.restoreContext('A');
        qualifier.createContext('X');
        qualifier.setFactory('service-x', siblingFactory);

        qualifier.removeFactory('service-b', context: 'B');

        expect(
          qualifier
              .getFactory<TestService>(
                qualifier: 'service-x',
                contextQualifier: 'X',
                fallback: false,
              )
              ?.factory,
          same(siblingFactory),
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

        final entries = qualifier.entries().toList();
        expect(entries.length, 2);
        expect(entries.any((e) => e.key == TestService), true);
        expect(entries.any((e) => e.key == 'qualifier1'), true);
      });

      test('entries should return entries from an explicit named context', () {
        final qualifier = DartDDIDefaultQualifierImpl();
        final rootFactory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );
        final contextFactory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );
        final rootContext = qualifier.currentContext;

        qualifier.setFactory('rootService', rootFactory);

        qualifier.runWithContext('named-context', () {
          qualifier.setFactory('contextService', contextFactory);
          return Object();
        });

        final rootEntries = qualifier.entries(context: rootContext).toList();
        final contextEntries =
            qualifier.entries(context: 'named-context').toList();

        expect(rootEntries.any((e) => e.key == 'rootService'), true);
        expect(rootEntries.any((e) => e.key == 'contextService'), false);
        expect(contextEntries.any((e) => e.key == 'contextService'), true);
        expect(contextEntries.any((e) => e.key == 'rootService'), false);
      });

      test(
          'getFactory should resolve a named context explicitly using contextQualifier',
          () {
        final qualifier = DartDDIDefaultQualifierImpl();
        final parentFactory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );
        final childFactory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );

        qualifier.runWithContext('parent', () {
          qualifier.setFactory('parentService', parentFactory);

          qualifier.runWithContext('child', () {
            qualifier.setFactory('childService', childFactory);
            return Object();
          });

          return Object();
        });

        expect(
          qualifier
              .getFactory<TestService>(
                qualifier: 'parentService',
                contextQualifier: 'parent',
              )
              ?.factory,
          same(parentFactory),
        );
        expect(
          qualifier
              .getFactory<TestService>(
                qualifier: 'childService',
                contextQualifier: 'child',
              )
              ?.factory,
          same(childFactory),
        );
        expect(
          qualifier
              .getFactory<TestService>(
                qualifier: 'childService',
                contextQualifier: 'parent',
                fallback: false,
              )
              ?.factory,
          isNull,
        );
      });

      test('restoreContext should fallback to root when context does not exist',
          () {
        final qualifier = DartDDIDefaultQualifierImpl();
        final rootContext = qualifier.currentContext;

        qualifier.createContext('temp');
        expect(qualifier.currentContext, equals('temp'));

        qualifier.restoreContext('unknown-context');
        expect(qualifier.currentContext, equals(rootContext));
      });

      test('runWithContext should restore previous context on sync error', () {
        final qualifier = DartDDIDefaultQualifierImpl();
        final rootContext = qualifier.currentContext;

        expect(
          () => qualifier.runWithContext('ctx-sync', () {
            throw StateError('sync-error');
          }),
          throwsA(isA<StateError>()),
        );
        expect(qualifier.currentContext, equals(rootContext));
      });

      test('runWithContext should restore previous context on async error',
          () async {
        final qualifier = DartDDIDefaultQualifierImpl();
        final rootContext = qualifier.currentContext;

        await expectLater(
          qualifier.runWithContext<Future<void>>('ctx-async', () async {
            throw StateError('async-error');
          }),
          throwsA(isA<StateError>()),
        );
        expect(qualifier.currentContext, equals(rootContext));
      });

      test('freezeContext should throw for unknown context', () {
        final qualifier = DartDDIDefaultQualifierImpl();

        expect(
          () => qualifier.freezeContext('missing-context'),
          throwsA(isA<ContextNotFoundException>()),
        );
      });

      test('destroyContext should throw for root context', () {
        final qualifier = DartDDIDefaultQualifierImpl();
        final rootContext = qualifier.currentContext;

        expect(
          () => qualifier.destroyContext(rootContext),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('destroyContext should throw for unknown context', () {
        final qualifier = DartDDIDefaultQualifierImpl();

        expect(
          () => qualifier.destroyContext('missing-context'),
          throwsA(isA<ContextNotFoundException>()),
        );
      });

      test(
          'contextHasDestroyBlockers should be recalculated when replacing non-destroyable factory',
          () {
        final qualifier = DartDDIDefaultQualifierImpl();
        qualifier.createContext('ctx-blockers');

        qualifier.setFactory(
          'service',
          ApplicationFactory<TestService>(
            builder: TestService.new.builder,
            canDestroy: false,
          ),
          context: 'ctx-blockers',
        );
        expect(qualifier.contextHasDestroyBlockers('ctx-blockers'), isTrue);

        qualifier.setFactory(
          'service',
          ApplicationFactory<TestService>(
            builder: TestService.new.builder,
          ),
          context: 'ctx-blockers',
        );
        expect(qualifier.contextHasDestroyBlockers('ctx-blockers'), isFalse);
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
        qualifier.runWithContext('parent', () {
          qualifier.setFactory(TestService, factory);

          // Try to get from child zone with fallback (nested zones)
          qualifier.runWithContext('child', () {
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
        qualifier.runWithContext('parent', () {
          qualifier.setFactory(TestService, factory);

          // Try to get from child zone without fallback (nested zones)
          qualifier.runWithContext('child', () {
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

        qualifier.runWithContext('zone1', () {
          qualifier.setFactory(TestService, factory);
          qualifier.setFactory('qualifier1', factory);

          final entries = qualifier.entries().toList();
          expect(entries.length, 2);
          expect(entries.any((e) => e.key == TestService), true);
          expect(entries.any((e) => e.key == 'qualifier1'), true);
        });
      });

      test('entries should return entries from an explicit zone context', () {
        final qualifier = DartDDIZoneQualifierImpl();
        final parentEntries = <MapEntry<Object, DDIBaseFactory<Object>>>[];
        Object? parentContext;

        qualifier.runWithContext('parent', () {
          qualifier.setFactory(
            'parentService',
            ApplicationFactory<TestService>(builder: TestService.new.builder),
          );

          parentContext = qualifier.currentContext;
          parentEntries.addAll(qualifier.entries().toList());

          qualifier.runWithContext('child', () {
            qualifier.setFactory(
              'childService',
              ApplicationFactory<TestService>(builder: TestService.new.builder),
            );

            final childEntries = qualifier.entries().toList();
            final explicitParentEntries =
                qualifier.entries(context: parentContext).toList();

            expect(childEntries.any((e) => e.key == 'childService'), true);
            expect(childEntries.any((e) => e.key == 'parentService'), false);
            expect(explicitParentEntries.any((e) => e.key == 'parentService'),
                true);
            expect(explicitParentEntries.any((e) => e.key == 'childService'),
                false);

            return Object();
          });

          return Object();
        });

        expect(parentEntries.any((e) => e.key == 'parentService'), true);
      });

      // TODO
      /*test(
          'getFactory should resolve a named zone context explicitly using contextQualifier',
          () {
        final qualifier = DartDDIZoneQualifierImpl();
        final parentFactory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );
        final childFactory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );

        qualifier.runWithContext('parent', () {
          qualifier.setFactory('parentService', parentFactory);

          qualifier.runWithContext('child', () {
            qualifier.setFactory('childService', childFactory);

            expect(
              qualifier.getFactory<TestService>(
                qualifier: 'parentService',
                contextQualifier: 'parent',
              ),
              same(parentFactory),
            );
            expect(
              qualifier.getFactory<TestService>(
                qualifier: 'childService',
                contextQualifier: 'child',
              ),
              same(childFactory),
            );
            expect(
              qualifier.getFactory<TestService>(
                qualifier: 'childService',
                contextQualifier: 'parent',
                fallback: false,
              ),
              isNull,
            );
            return Object();
          });

          return Object();
        });

      });*/

      test('isEmpty should return true when zone is empty', () {
        final qualifier = DartDDIZoneQualifierImpl();

        qualifier.runWithContext('zone1', () {
          expect(qualifier.isEmpty, true);
        });
      });

      test('isEmpty should return false when zone has entries', () {
        final qualifier = DartDDIZoneQualifierImpl();
        final factory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );

        qualifier.runWithContext('zone1', () {
          qualifier.setFactory(TestService, factory);
          expect(qualifier.isEmpty, false);
        });
      });

      test('length should return correct count', () {
        final qualifier = DartDDIZoneQualifierImpl();
        final factory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );

        qualifier.runWithContext('zone1', () {
          expect(qualifier.length, 0);
          qualifier.setFactory(TestService, factory);
          expect(qualifier.length, 1);
          qualifier.setFactory('qualifier1', factory);
          expect(qualifier.length, 2);
        });
      });

      test('createContext and restoreContext should be no-op', () {
        final qualifier = DartDDIZoneQualifierImpl();

        expect(() => qualifier.createContext('ignored'), returnsNormally);
        expect(() => qualifier.restoreContext('ignored'), returnsNormally);
      });

      test('hasContextQualifier should return false for unknown root name', () {
        final qualifier = DartDDIZoneQualifierImpl();

        expect(qualifier.hasContextQualifier('missing-zone'), isFalse);
      });

      test(
          'hasContextQualifier should return false when name differs even if zone map is non-empty',
          () {
        final qualifier = DartDDIZoneQualifierImpl();
        final factory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );

        qualifier.runWithContext('zone-a', () {
          qualifier.setFactory('service', factory);
          expect(qualifier.hasContextQualifier('zone-a'), isTrue);
          expect(qualifier.hasContextQualifier('zone-b'), isFalse);
          return Object();
        });
      });

      test('contextDestroyOrder should be empty for missing context', () {
        final qualifier = DartDDIZoneQualifierImpl();

        expect(qualifier.contextDestroyOrder('missing').isEmpty, isTrue);
      });

      test('contextHasDestroyBlockers should inspect root and explicit maps',
          () {
        final qualifier = DartDDIZoneQualifierImpl();
        final nonDestroyable = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
          canDestroy: false,
        );
        final explicitMap = <Object, DDIBaseFactory<Object>>{
          'service': nonDestroyable as DDIBaseFactory<Object>,
        };
        final rootContext = qualifier.currentContext;

        qualifier.setFactory(
          'service',
          nonDestroyable,
          context: rootContext,
        );

        expect(qualifier.contextHasDestroyBlockers(rootContext), isTrue);
        expect(qualifier.contextHasDestroyBlockers(explicitMap), isTrue);
        expect(qualifier.contextHasDestroyBlockers('missing'), isFalse);
      });

      test('destroyContext should clear explicit map context', () {
        final qualifier = DartDDIZoneQualifierImpl();
        final explicitMap = <Object, DDIBaseFactory<Object>>{
          'service': ApplicationFactory<TestService>(
            builder: TestService.new.builder,
          ) as DDIBaseFactory<Object>,
        };

        qualifier.destroyContext(explicitMap);
        expect(explicitMap, isEmpty);
      });

      test('destroyContext should throw for root and unknown context', () {
        final qualifier = DartDDIZoneQualifierImpl();
        final rootContext = qualifier.currentContext;

        expect(
          () => qualifier.destroyContext(rootContext),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          () => qualifier.destroyContext('missing-zone'),
          throwsA(isA<ContextNotFoundException>()),
        );
      });

      test(
          'removeFactory should fallback to current zone map for unknown context',
          () {
        final qualifier = DartDDIZoneQualifierImpl();
        final factory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );

        qualifier.runWithContext('zone-rm', () {
          qualifier.setFactory('service', factory);
          final removed =
              qualifier.removeFactory('service', context: 'unknown-context');
          expect(removed, same(factory));
          return Object();
        });
      });
    });
  });
}
