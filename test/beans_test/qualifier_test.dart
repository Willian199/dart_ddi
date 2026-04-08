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
    });
  });
}
