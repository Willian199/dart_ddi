import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/core/ddi_default_strategy.dart';
import 'package:test/test.dart';

import '../clazz_samples/spy_strategy.dart';
import '../clazz_samples/test_service.dart';

void main() {
  group('Strategy Tests', () {
    test('DDI.newInstance should use the provided DDIStrategy', () async {
      final spyStrategy = SpyStrategy(DDIDefaultStrategy());
      final ddi = DDI.newInstance(contextStrategy: spyStrategy);

      await ddi.singleton<TestService>(TestService.new);
      expect(spyStrategy.setFactoryCallCount, greaterThan(0));
    });

    group('DDIDefaultStrategy', () {
      test('hasContext should return false when no context is active', () {
        final strategy = DDIDefaultStrategy();
        expect(strategy.hasContext, false);
      });

      test('createContext should activate a context and fallback to parent',
          () {
        final strategy = DDIDefaultStrategy();
        final rootFactory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );

        strategy.setFactory(TestService, rootFactory);
        strategy.createContext('ctx');

        expect(
          strategy.getFactory<TestService>(qualifier: TestService)?.factory,
          same(rootFactory),
        );
        expect(strategy.hasContext, true);
      });

      test('entries should return entries from an explicit named context', () {
        final strategy = DDIDefaultStrategy();
        final rootFactory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );
        final contextFactory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );
        final rootContext = strategy.currentContext;

        strategy.setFactory('rootService', rootFactory);
        strategy.createContext('named-context');
        strategy.setFactory('contextService', contextFactory);

        final rootEntries = strategy.entries(context: rootContext).toList();
        final contextEntries =
            strategy.entries(context: 'named-context').toList();

        expect(rootEntries.any((e) => e.key == 'rootService'), true);
        expect(rootEntries.any((e) => e.key == 'contextService'), false);
        expect(contextEntries.any((e) => e.key == 'contextService'), true);
        expect(contextEntries.any((e) => e.key == 'rootService'), false);
      });

      test('destroyContext should throw for unknown context', () {
        final strategy = DDIDefaultStrategy();

        expect(
          () => strategy.destroyContext('missing-context'),
          throwsA(isA<ContextNotFoundException>()),
        );
      });

      test('freezeContext should throw for unknown context', () {
        final strategy = DDIDefaultStrategy();

        expect(
          () => strategy.freezeContext('missing-context'),
          throwsA(isA<ContextNotFoundException>()),
        );
      });

      test('should resolve bean using multiple aliases', () {
        final strategy = DDIDefaultStrategy();
        final factory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );

        strategy.setFactory(
          TestService,
          factory,
          aliases: {'test-service', #serviceAlias},
        );

        expect(
          strategy.getFactory<TestService>(qualifier: TestService)?.factory,
          same(factory),
        );
        expect(
          strategy.getFactory<TestService>(qualifier: 'test-service')?.factory,
          same(factory),
        );
        expect(
          strategy.getFactory<TestService>(qualifier: #serviceAlias)?.factory,
          same(factory),
        );
      });

      test('nearest ancestor alias should win and fallback after alias removal',
          () {
        final strategy = DDIDefaultStrategy();

        final rootFactory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );
        final parentFactory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );

        strategy.setFactory(
          'root-service',
          rootFactory,
          aliases: {'shared-alias'},
        );

        strategy.createContext('parent');
        strategy.setFactory(
          'parent-service',
          parentFactory,
          aliases: {'shared-alias'},
        );

        strategy.createContext('child');

        final fromChildBeforeRemove =
            strategy.getFactory<TestService>(qualifier: 'shared-alias');
        expect(fromChildBeforeRemove?.factory, same(parentFactory));
        expect(fromChildBeforeRemove?.context, equals('parent'));

        strategy.removeAliases('parent-service', {'shared-alias'},
            context: 'parent');

        final fromChildAfterRemove =
            strategy.getFactory<TestService>(qualifier: 'shared-alias');
        expect(fromChildAfterRemove?.factory, same(rootFactory));
      });

      test('removeFactory without explicit context should remove from current',
          () {
        final strategy = DDIDefaultStrategy();
        final rootFactory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );
        final childFactory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );
        final rootContext = strategy.currentContext;

        strategy.setFactory('service', rootFactory, context: rootContext);
        strategy.createContext('ctx');
        strategy.setFactory('service', childFactory, context: 'ctx');

        final removed = strategy.removeFactory('service');

        expect(removed, same(childFactory));
        expect(
          strategy.getFactory<TestService>(
            qualifier: 'service',
            contextQualifier: 'ctx',
            fallback: false,
          ),
          isNull,
        );
        expect(
          strategy
              .getFactory<TestService>(
                qualifier: 'service',
                contextQualifier: rootContext,
                fallback: false,
              )
              ?.factory,
          same(rootFactory),
        );
      });

      test('removeFactory with unknown explicit context should not touch root',
          () {
        final strategy = DDIDefaultStrategy();
        final rootFactory = ApplicationFactory<TestService>(
          builder: TestService.new.builder,
        );

        strategy.setFactory('service', rootFactory);

        final removed =
            strategy.removeFactory('service', context: 'missing-context');

        expect(removed, isNull);
        expect(
          strategy
              .getFactory<TestService>(
                qualifier: 'service',
                contextQualifier: strategy.currentContext,
                fallback: false,
              )
              ?.factory,
          same(rootFactory),
        );
      });
    });

    test(
      'register with explicit qualifier should also register BeanT as alias',
      () async {
        final ddi = DDI.newInstance();

        await ddi.application<TestService>(
          TestService.new,
          qualifier: 'custom-service',
        );

        expect(
          ddi.isRegistered<TestService>(),
          isTrue,
        );
        expect(
          ddi.isRegistered<TestService>(qualifier: 'custom-service'),
          isTrue,
        );
        expect(
          ddi.get<TestService>(),
          isA<TestService>(),
        );
      },
    );

    test(
      'should resolve by smallest non-null priority when alias matches multiple instances',
      () async {
        final ddi = DDI.newInstance();

        await ddi.application<TestService>(
          TestService.new,
          qualifier: 'service-a',
          priority: 10,
        );
        await ddi.application<TestService>(
          TestService.new,
          qualifier: 'service-b',
          priority: 1,
        );

        final selected = ddi.get<TestService>();
        final expected = ddi.get<TestService>(qualifier: 'service-b');
        expect(identical(selected, expected), isTrue);
      },
    );

    test(
      'null priority should be sorted to the end',
      () async {
        final ddi = DDI.newInstance();

        await ddi.application<TestService>(
          TestService.new,
          qualifier: 'service-a',
        );
        await ddi.application<TestService>(
          TestService.new,
          qualifier: 'service-b',
          priority: 5,
        );

        final selected = ddi.get<TestService>();
        final expected = ddi.get<TestService>(qualifier: 'service-b');
        expect(identical(selected, expected), isTrue);
      },
    );

    test(
      'should throw AmbiguousAliasException when best priority ties',
      () async {
        final ddi = DDI.newInstance();

        await ddi.application<TestService>(
          TestService.new,
          qualifier: 'service-a',
          priority: 1,
        );
        await ddi.application<TestService>(
          TestService.new,
          qualifier: 'service-b',
          priority: 1,
        );

        expect(
          () => ddi.get<TestService>(),
          throwsA(
            isA<AmbiguousAliasException>()
                .having((e) => e.alias, 'alias', equals(TestService))
                .having(
                  (e) => e.qualifiers,
                  'qualifiers',
                  containsAll(<Object>{'service-a', 'service-b'}),
                ),
          ),
        );
      },
    );

    test(
      'should throw AmbiguousAliasException when all priorities are null',
      () async {
        final ddi = DDI.newInstance();

        await ddi.application<TestService>(
          TestService.new,
          qualifier: 'service-a',
        );
        await ddi.application<TestService>(
          TestService.new,
          qualifier: 'service-b',
        );

        expect(
          () => ddi.get<TestService>(),
          throwsA(
            isA<AmbiguousAliasException>().having(
              (e) => e.qualifiers,
              'qualifiers',
              containsAll(<Object>{'service-a', 'service-b'}),
            ),
          ),
        );
      },
    );

    test(
      'getByType should keep returning primary qualifiers',
      () async {
        final ddi = DDI.newInstance();

        await ddi.application<TestService>(
          TestService.new,
          qualifier: 'service-a',
        );
        await ddi.application<TestService>(
          TestService.new,
          qualifier: 'service-b',
        );

        final keys = ddi.getByType<TestService>();
        expect(keys, containsAll(<Object>{'service-a', 'service-b'}));
        expect(keys, isNot(contains(TestService)));
      },
    );

    test(
      'destroyByType should remove all instances matched by alias/type search',
      () async {
        final ddi = DDI.newInstance();

        await ddi.application<TestService>(
          TestService.new,
          qualifier: 'service-a',
        );
        await ddi.application<TestService>(
          TestService.new,
          qualifier: 'service-b',
        );

        ddi.destroyByType<TestService>();

        expect(
          ddi.isRegistered<TestService>(qualifier: 'service-a'),
          isFalse,
        );
        expect(
          ddi.isRegistered<TestService>(qualifier: 'service-b'),
          isFalse,
        );
      },
    );
  });
}
