import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/context_management_samples.dart';

void main() {
  group('DDI Context Management Tests', () {
    test('register with unknown context should throw', () async {
      final ddi = DDI.newInstance();

      await expectLater(
        ddi.application<ContextManagementBean>(
          () => const ContextManagementBean('missing'),
          context: 'missing-context',
        ),
        throwsA(isA<ContextNotFoundException>()),
      );
    });

    test('createContext should throw when key already exists', () {
      final ddi = DDI.newInstance();

      ddi.createContext('duplicate');

      expect(
        () => ddi.createContext('duplicate'),
        throwsA(isA<DuplicatedContextException>()),
      );
    });

    test('destroyContext should remove context bean registrations', () async {
      final ddi = DDI.newInstance();

      ddi.createContext('feature');
      await ddi.object<ContextManagementBean>(
        const ContextManagementBean('feature'),
        context: 'feature',
      );

      expect(ddi.contextExists('feature'), isTrue);
      expect(
          ddi.isRegistered<ContextManagementBean>(context: 'feature'), isTrue);

      await ddi.destroyContext('feature');

      expect(ddi.contextExists('feature'), isFalse);
      expect(
          ddi.isRegistered<ContextManagementBean>(context: 'feature'), isFalse);
    });

    test('destroyContext should throw when context does not exist', () async {
      final ddi = DDI.newInstance();

      await expectLater(
        Future<void>.sync(() => ddi.destroyContext('missing-context')),
        throwsA(isA<ContextNotFoundException>()),
      );
    });

    test('destroyContext should destroy deepest child factories first',
        () async {
      final ddi = DDI.newInstance();
      final events = <String>[];

      ddi.createContext('parent');
      ddi.createContext('child');

      await ddi.object<TrackedDestroyBean>(
        TrackedDestroyBean('parent', events),
        qualifier: 'parentBean',
        context: 'parent',
      );
      await ddi.object<TrackedDestroyBean>(
        TrackedDestroyBean('child', events),
        qualifier: 'childBean',
        context: 'child',
      );

      await ddi.destroyContext('parent');

      expect(events, equals(['child', 'parent']));
      expect(ddi.contextExists('child'), isFalse);
      expect(ddi.contextExists('parent'), isFalse);
    });

    test(
        'destroyContext should respect scope destroy rules and keep context when factory is not destroyable',
        () async {
      final ddi = DDI.newInstance();

      ddi.createContext('locked');
      await ddi.application<ContextManagementBean>(
        () => const ContextManagementBean('locked'),
        context: 'locked',
        canDestroy: false,
      );

      await expectLater(
        ddi.destroyContext('locked'),
        throwsA(isA<ContextDestroyBlockedException>()),
      );

      expect(ddi.contextExists('locked'), isTrue);
      expect(
          ddi.isRegistered<ContextManagementBean>(context: 'locked'), isTrue);
    });

    test(
        'destroyContext should fail fast when context has non-destroyable factory',
        () async {
      final ddi = DDI.newInstance();
      final events = <String>[];

      ddi.createContext('fast-lock');
      await ddi.application<ContextManagementBean>(
        () => const ContextManagementBean('locked'),
        qualifier: 'locked',
        context: 'fast-lock',
        canDestroy: false,
      );
      await ddi.object<TrackedDestroyBean>(
        TrackedDestroyBean('destroyable', events),
        qualifier: 'destroyable',
        context: 'fast-lock',
      );

      await expectLater(
        ddi.destroyContext('fast-lock'),
        throwsA(isA<ContextDestroyBlockedException>()),
      );

      expect(events, isEmpty);
      expect(
          ddi.isRegistered<ContextManagementBean>(
              qualifier: 'locked', context: 'fast-lock'),
          isTrue);
      expect(
        ddi.isRegistered<TrackedDestroyBean>(
          qualifier: 'destroyable',
          context: 'fast-lock',
        ),
        isTrue,
      );
    });

    test(
        'destroyContext should pre-validate child contexts and avoid partial destroy',
        () async {
      final ddi = DDI.newInstance();
      final events = <String>[];

      ddi.createContext('parent-check');
      ddi.createContext('child-check');

      await ddi.object<TrackedDestroyBean>(
        TrackedDestroyBean('parent-check', events),
        qualifier: 'parent-destroyable',
        context: 'parent-check',
      );
      await ddi.application<ContextManagementBean>(
        () => const ContextManagementBean('child-locked'),
        qualifier: 'child-locked',
        context: 'child-check',
        canDestroy: false,
      );

      await expectLater(
        ddi.destroyContext('parent-check'),
        throwsA(isA<ContextDestroyBlockedException>()),
      );

      // Parent instance must remain untouched because validation happens first.
      expect(events, isEmpty);
      expect(
        ddi.isRegistered<TrackedDestroyBean>(
          qualifier: 'parent-destroyable',
          context: 'parent-check',
        ),
        isTrue,
      );
      expect(
        ddi.isRegistered<ContextManagementBean>(
          qualifier: 'child-locked',
          context: 'child-check',
        ),
        isTrue,
      );
    });

    test(
        'register should remove BeanState.none factory from effective context and keep root registration untouched',
        () async {
      final ddi = DDI.newInstance();
      final rootContext = ddi.currentContext;

      await ddi.object<ProbeBean>(
        const ProbeBean('root'),
        qualifier: 'shared-probe',
        context: rootContext,
      );

      ddi.createContext('ctx-probe');

      // Registers in current context with state "none".
      await ddi.register<ProbeBean>(
        factory: NoneStateFactory(),
        qualifier: 'shared-probe',
      );

      await ddi.object<ProbeBean>(
        const ProbeBean('ctx'),
        qualifier: 'shared-probe',
      );

      expect(
        ddi
            .getWith<ProbeBean, Object>(
              qualifier: 'shared-probe',
              context: rootContext,
            )
            .origin,
        equals('root'),
      );
      expect(
        ddi
            .getWith<ProbeBean, Object>(
              qualifier: 'shared-probe',
              context: 'ctx-probe',
            )
            .origin,
        equals('ctx'),
      );
    });

    test('DDIModule should create its context when instance is created',
        () async {
      final ddi = DDI.newInstance();

      await ddi.singleton<AutoContextModuleSample>(
          () => AutoContextModuleSample(ddi));

      final module = ddi.get<AutoContextModuleSample>();
      expect(ddi.contextExists(module.contextQualifier!), isTrue);
      expect(
        ddi
            .getWith<ContextManagementBean, Object>(
                context: module.contextQualifier)
            .origin,
        'module',
      );
    });

    test(
        'DDIModule with canRegister false should not create context and explicit registration in that context should fail',
        () async {
      final ddi = DDI.newInstance();

      await ddi.singleton<AutoContextModuleSample>(
        () => AutoContextModuleSample(ddi),
        canRegister: () => false,
      );

      expect(ddi.isRegistered<AutoContextModuleSample>(), isFalse);
      expect(ddi.contextExists(AutoContextModuleSample), isFalse);

      await expectLater(
        ddi.object<ContextManagementBean>(
          const ContextManagementBean('should-fail'),
          context: AutoContextModuleSample,
        ),
        throwsA(isA<ContextNotFoundException>()),
      );
    });

    test(
        'destroyContext should fail for module context when a child factory has canDestroy false',
        () async {
      final ddi = DDI.newInstance();

      await ddi.singleton<LockedChildModuleSample>(
          () => LockedChildModuleSample(ddi));
      final module = ddi.get<LockedChildModuleSample>();
      final context = module.contextQualifier!;

      expect(ddi.contextExists(context), isTrue);
      expect(
        ddi.isRegistered<ContextManagementBean>(
          qualifier: 'locked-child',
          context: context,
        ),
        isTrue,
      );

      await expectLater(
        ddi.destroyContext(context),
        throwsA(isA<ContextDestroyBlockedException>()),
      );

      expect(ddi.contextExists(context), isTrue);
      expect(
        ddi.isRegistered<ContextManagementBean>(
          qualifier: 'locked-child',
          context: context,
        ),
        isTrue,
      );
    });

    test(
        'destroyContext should work after failed non-destroyable registration rollback',
        () async {
      final ddi = DDI.newInstance();
      ddi.createContext('rollback-ctx');

      await expectLater(
        ddi.singleton<ContextManagementBean>(
          () => const ContextManagementBean('should-fail'),
          context: 'rollback-ctx',
          canDestroy: false,
          requires: {'missing-dependency'},
        ),
        throwsA(isA<MissingDependenciesException>()),
      );

      expect(
        ddi.isRegistered<ContextManagementBean>(context: 'rollback-ctx'),
        isFalse,
      );

      await ddi.destroyContext('rollback-ctx');
      expect(ddi.contextExists('rollback-ctx'), isFalse);
    });

    test(
        'destroyContext should work after failed non-destroyable registration when context is not empty',
        () async {
      final ddi = DDI.newInstance();
      ddi.createContext('rollback-non-empty');

      await ddi.object<ContextManagementBean>(
        const ContextManagementBean('keep'),
        qualifier: 'keep',
        context: 'rollback-non-empty',
      );

      await expectLater(
        ddi.singleton<ContextManagementBean>(
          () => const ContextManagementBean('should-fail'),
          qualifier: 'blocked',
          context: 'rollback-non-empty',
          canDestroy: false,
          requires: {'missing-dependency'},
        ),
        throwsA(isA<MissingDependenciesException>()),
      );

      expect(
        ddi.isRegistered<ContextManagementBean>(
          qualifier: 'keep',
          context: 'rollback-non-empty',
        ),
        isTrue,
      );
      expect(
        ddi.isRegistered<ContextManagementBean>(
          qualifier: 'blocked',
          context: 'rollback-non-empty',
        ),
        isFalse,
      );

      await ddi.destroyContext('rollback-non-empty');
      expect(ddi.contextExists('rollback-non-empty'), isFalse);
    });

    test('concurrent explicit context registrations should remain isolated',
        () async {
      final ddi = DDI.newInstance();
      ddi.createContext('ctx-a');
      ddi.createContext('ctx-b');

      await Future.wait([
        Future<void>.delayed(const Duration(milliseconds: 5), () async {
          await ddi.object<ContextManagementBean>(
            const ContextManagementBean('A'),
            qualifier: 'shared',
            context: 'ctx-a',
          );
        }),
        Future<void>.delayed(const Duration(milliseconds: 1), () async {
          await ddi.object<ContextManagementBean>(
            const ContextManagementBean('B'),
            qualifier: 'shared',
            context: 'ctx-b',
          );
        }),
      ]);

      expect(
        ddi
            .getWith<ContextManagementBean, Object>(
              qualifier: 'shared',
              context: 'ctx-a',
            )
            .origin,
        equals('A'),
      );
      expect(
        ddi
            .getWith<ContextManagementBean, Object>(
              qualifier: 'shared',
              context: 'ctx-b',
            )
            .origin,
        equals('B'),
      );
    });

    test('destroyContext should support concurrent independent containers',
        () async {
      final ddiA = DDI.newInstance();
      final ddiB = DDI.newInstance();

      ddiA.createContext('parallel-a');
      ddiB.createContext('parallel-b');

      await ddiA.object<ContextManagementBean>(
        const ContextManagementBean('A'),
        qualifier: 'a',
        context: 'parallel-a',
      );
      await ddiB.object<ContextManagementBean>(
        const ContextManagementBean('B'),
        qualifier: 'b',
        context: 'parallel-b',
      );

      await Future.wait([
        Future<void>.sync(() => ddiA.destroyContext('parallel-a')),
        Future<void>.sync(() => ddiB.destroyContext('parallel-b')),
      ]);

      expect(ddiA.contextExists('parallel-a'), isFalse);
      expect(ddiB.contextExists('parallel-b'), isFalse);
    });

    test(
        'destroyContext should block register in context while destroy is in progress',
        () async {
      final ddi = DDI.newInstance();
      ddi.createContext('busy-context');

      final destroyStarted = Completer<void>();
      final releaseDestroy = Completer<void>();

      await ddi.register<SlowDestroyBean>(
        factory: SlowDestroyFactory(
          destroyStarted: destroyStarted,
          releaseDestroy: releaseDestroy,
        ),
        qualifier: 'slow',
        context: 'busy-context',
      );

      final destroyFuture = Future<void>.sync(
        () => ddi.destroyContext('busy-context'),
      );

      await destroyStarted.future;

      await expectLater(
        ddi.object<ContextManagementBean>(
          const ContextManagementBean('blocked'),
          qualifier: 'blocked',
          context: 'busy-context',
        ),
        throwsA(
          isA<ContextBeingDestroyedException>(),
        ),
      );

      releaseDestroy.complete();
      await destroyFuture;

      expect(ddi.contextExists('busy-context'), isFalse);
    });

    test(
        'destroyContext should block createContext for the same context while destroy is in progress',
        () async {
      final ddi = DDI.newInstance();
      ddi.createContext('busy-create-context');

      final destroyStarted = Completer<void>();
      final releaseDestroy = Completer<void>();

      await ddi.register<SlowDestroyBean>(
        factory: SlowDestroyFactory(
          destroyStarted: destroyStarted,
          releaseDestroy: releaseDestroy,
        ),
        qualifier: 'slow',
        context: 'busy-create-context',
      );

      final destroyFuture = Future<void>.sync(
        () => ddi.destroyContext('busy-create-context'),
      );

      await destroyStarted.future;

      expect(
        () => ddi.createContext('busy-create-context'),
        throwsA(isA<ContextBeingDestroyedException>()),
      );

      releaseDestroy.complete();
      await destroyFuture;

      expect(ddi.contextExists('busy-create-context'), isFalse);
    });

    test(
        'destroyContext should block register in child context while parent destroy is in progress',
        () async {
      final ddi = DDI.newInstance();
      ddi.createContext('parent-busy');
      ddi.createContext('child-busy');

      final destroyStarted = Completer<void>();
      final releaseDestroy = Completer<void>();

      await ddi.register<SlowDestroyBean>(
        factory: SlowDestroyFactory(
          destroyStarted: destroyStarted,
          releaseDestroy: releaseDestroy,
        ),
        qualifier: 'slow-parent',
        context: 'parent-busy',
      );

      final destroyFuture = Future<void>.sync(
        () => ddi.destroyContext('parent-busy'),
      );

      await destroyStarted.future;

      await expectLater(
        ddi.object<ContextManagementBean>(
          const ContextManagementBean('blocked-child'),
          qualifier: 'blocked-child',
          context: 'child-busy',
        ),
        throwsA(
          isA<ContextBeingDestroyedException>(),
        ),
      );

      releaseDestroy.complete();
      await destroyFuture;

      expect(ddi.contextExists('parent-busy'), isFalse);
      expect(ddi.contextExists('child-busy'), isFalse);
    });

    test('destroyContext reentrant call for same context should be a no-op',
        () async {
      final ddi = DDI.newInstance();
      ddi.createContext('reentrant-context');

      final destroyStarted = Completer<void>();
      final releaseDestroy = Completer<void>();

      await ddi.register<SlowDestroyBean>(
        factory: SlowDestroyFactory(
          destroyStarted: destroyStarted,
          releaseDestroy: releaseDestroy,
        ),
        qualifier: 'slow',
        context: 'reentrant-context',
      );

      final firstDestroy = Future<void>.sync(
        () => ddi.destroyContext('reentrant-context'),
      );

      await destroyStarted.future;

      await expectLater(
        Future<void>.sync(() => ddi.destroyContext('reentrant-context')),
        completes,
      );

      releaseDestroy.complete();
      await firstDestroy;

      expect(ddi.contextExists('reentrant-context'), isFalse);
    });

    test(
        'destroyContext should throw ContextDestroyIncompleteException when factories remain registered',
        () async {
      final ddi = DDI.newInstance();
      ddi.createContext('incomplete-context');

      await ddi.register<ContextManagementBean>(
        factory: IncompleteDestroyFactory(),
        qualifier: 'stuck',
        context: 'incomplete-context',
      );

      await expectLater(
        ddi.destroyContext('incomplete-context'),
        throwsA(isA<ContextDestroyIncompleteException>()),
      );

      expect(ddi.contextExists('incomplete-context'), isTrue);
      expect(
        ddi.isRegistered<ContextManagementBean>(
          qualifier: 'stuck',
          context: 'incomplete-context',
        ),
        isTrue,
      );
    });
  });
}
