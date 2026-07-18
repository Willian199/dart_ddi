import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/core_review_samples.dart';

void main() {
  group('Core review regressions', () {
    test(
      'isRegistered should return false when qualifier belongs to another type',
      () async {
        final ddi = DDI.newInstance();

        await ddi.singleton<CoreReviewServiceA>(
          CoreReviewServiceA.new,
          qualifier: 'shared',
        );

        expect(
          ddi.isRegistered<CoreReviewServiceB>(qualifier: 'shared'),
          isFalse,
        );
      },
    );

    test(
      'getOptional should return null when qualifier belongs to another type',
      () async {
        final ddi = DDI.newInstance();

        await ddi.singleton<CoreReviewServiceA>(
          CoreReviewServiceA.new,
          qualifier: 'shared',
        );

        expect(
          ddi.getOptional<CoreReviewServiceB>(qualifier: 'shared'),
          isNull,
        );
      },
    );

    test(
      'get should report BeanNotFound when qualifier belongs to another type',
      () async {
        final ddi = DDI.newInstance();

        await ddi.singleton<CoreReviewServiceA>(
          CoreReviewServiceA.new,
          qualifier: 'shared',
        );

        expect(
          () => ddi.get<CoreReviewServiceB>(qualifier: 'shared'),
          throwsA(isA<BeanNotFoundException>()),
        );
      },
    );

    test(
      'register should not overwrite another type with the same qualifier',
      () async {
        final ddi = DDI.newInstance();

        await ddi.singleton<CoreReviewServiceA>(
          CoreReviewServiceA.new,
          qualifier: 'shared',
        );

        await expectLater(
          ddi.singleton<CoreReviewServiceB>(
            CoreReviewServiceB.new,
            qualifier: 'shared',
          ),
          throwsA(isA<DuplicatedBeanException>()),
        );

        expect(ddi.get<CoreReviewServiceA>(qualifier: 'shared'),
            isA<CoreReviewServiceA>());
      },
    );

    test(
      'destroy should not remove a bean when qualifier belongs to another type',
      () async {
        final ddi = DDI.newInstance();

        await ddi.singleton<CoreReviewServiceA>(
          CoreReviewServiceA.new,
          qualifier: 'shared',
        );

        await ddi.destroy<CoreReviewServiceB>(qualifier: 'shared');

        expect(
          ddi.isRegistered<CoreReviewServiceA>(qualifier: 'shared'),
          isTrue,
        );
      },
    );

    test(
      'dispose should report BeanNotFound when qualifier belongs to another type',
      () async {
        final ddi = DDI.newInstance();

        await ddi.application<CoreReviewServiceA>(
          CoreReviewServiceA.new,
          qualifier: 'shared',
        );

        await expectLater(
          Future<void>.sync(
            () => ddi.dispose<CoreReviewServiceB>(qualifier: 'shared'),
          ),
          throwsA(isA<BeanNotFoundException>()),
        );

        expect(
          ddi.isRegistered<CoreReviewServiceA>(qualifier: 'shared'),
          isTrue,
        );
      },
    );

    test(
      'register should capture implicit context before async canRegister',
      () async {
        final ddi = DDI.newInstance();
        final rootContext = ddi.currentContext;
        final canRegister = Completer<void>();

        final registration = ddi.singleton<CoreReviewServiceA>(
          CoreReviewServiceA.new,
          canRegister: () async {
            await canRegister.future;
            return true;
          },
        );

        ddi.createContext('later-context');
        canRegister.complete();
        await registration;

        expect(
          ddi.isRegistered<CoreReviewServiceA>(context: rootContext),
          isTrue,
        );
        expect(
          ddi.isRegistered<CoreReviewServiceA>(context: 'later-context'),
          isFalse,
        );
      },
    );

    test(
      'destroy should be retryable after transient PreDestroy failure',
      () async {
        final ddi = DDI.newInstance();
        final bean = CoreReviewFailsOncePreDestroy();

        await ddi.singleton<CoreReviewFailsOncePreDestroy>(() => bean);

        await expectLater(
          Future<void>.sync(
            () => ddi.destroy<CoreReviewFailsOncePreDestroy>(),
          ),
          throwsStateError,
        );

        expect(ddi.isRegistered<CoreReviewFailsOncePreDestroy>(), isTrue);

        await ddi.destroy<CoreReviewFailsOncePreDestroy>();

        expect(bean.calls, equals(2));
        expect(ddi.isRegistered<CoreReviewFailsOncePreDestroy>(), isFalse);
      },
    );

    test(
      'dispose should be retryable after transient PreDispose failure',
      () async {
        final ddi = DDI.newInstance();
        final bean = CoreReviewFailsOncePreDispose();

        await ddi.application<CoreReviewFailsOncePreDispose>(() => bean);
        expect(ddi.get<CoreReviewFailsOncePreDispose>(), same(bean));

        await expectLater(
          ddi.dispose<CoreReviewFailsOncePreDispose>(),
          throwsStateError,
        );

        await ddi.dispose<CoreReviewFailsOncePreDispose>();

        expect(bean.calls, equals(2));
        expect(ddi.isReady<CoreReviewFailsOncePreDispose>(), isFalse);
      },
    );

    test(
      'addDecorator should report BeanNotFound when qualifier belongs to another type',
      () async {
        final ddi = DDI.newInstance();

        await ddi.singleton<CoreReviewServiceA>(
          CoreReviewServiceA.new,
          qualifier: 'shared',
        );

        expect(
          () => ddi.addDecorator<CoreReviewServiceB>(
            [(bean) => bean],
            qualifier: 'shared',
          ),
          throwsA(isA<BeanNotFoundException>()),
        );
      },
    );

    test(
      'failed child destruction should keep parent registered for retry',
      () async {
        final ddi = DDI.newInstance();
        final child = CoreReviewFailsOncePreDestroy();

        await ddi.singleton<CoreReviewFailsOncePreDestroy>(() => child);
        await ddi.singleton<CoreReviewServiceA>(
          CoreReviewServiceA.new,
          children: {CoreReviewFailsOncePreDestroy},
        );

        await expectLater(
          Future<void>.sync(() => ddi.destroy<CoreReviewServiceA>()),
          throwsStateError,
        );

        expect(ddi.isRegistered<CoreReviewServiceA>(), isTrue);
        expect(ddi.isRegistered<CoreReviewFailsOncePreDestroy>(), isTrue);

        await ddi.destroy<CoreReviewServiceA>();

        expect(child.calls, equals(2));
        expect(ddi.isRegistered<CoreReviewServiceA>(), isFalse);
        expect(ddi.isRegistered<CoreReviewFailsOncePreDestroy>(), isFalse);
      },
    );

    test(
      'singleton registration should not mutate caller decorator list',
      () async {
        final ddi = DDI.newInstance();
        final decorators = <CoreReviewServiceA Function(CoreReviewServiceA)>[
          (bean) => bean,
        ];

        await ddi.singleton<CoreReviewServiceA>(
          CoreReviewServiceA.new,
          decorators: decorators,
        );

        expect(decorators, hasLength(1));
      },
    );

    test(
      'failed dispose during async creation should preserve created instance',
      () async {
        final ddi = DDI.newInstance();
        final bean = CoreReviewFailsOncePreDispose();
        final creationStarted = Completer<void>();
        final releaseCreation = Completer<void>();

        await ddi.application<CoreReviewFailsOncePreDispose>(() async {
          creationStarted.complete();
          await releaseCreation.future;
          return bean;
        });

        final creation = ddi.getAsync<CoreReviewFailsOncePreDispose>();
        await creationStarted.future;

        final disposal = ddi.dispose<CoreReviewFailsOncePreDispose>();
        releaseCreation.complete();

        expect(
          await creation.timeout(const Duration(seconds: 2)),
          same(bean),
        );
        await expectLater(
          disposal.timeout(const Duration(seconds: 2)),
          throwsStateError,
        );

        expect(
          await ddi
              .getAsync<CoreReviewFailsOncePreDispose>()
              .timeout(const Duration(seconds: 2)),
          same(bean),
        );
      },
    );

    test(
      'async creation should wait for an ongoing dispose without deadlock',
      () async {
        final ddi = DDI.newInstance();
        final disposeStarted = Completer<void>();
        final releaseDispose = Completer<void>();

        await ddi.application<CoreReviewBlockingPreDispose>(
          () => CoreReviewBlockingPreDispose(
            disposeStarted: disposeStarted,
            releaseDispose: releaseDispose,
          ),
        );

        final first = await ddi.getAsync<CoreReviewBlockingPreDispose>();
        final disposal = ddi.dispose<CoreReviewBlockingPreDispose>();
        await disposeStarted.future.timeout(const Duration(seconds: 2));

        var creationCompleted = false;
        final creation =
            ddi.getAsync<CoreReviewBlockingPreDispose>().then((instance) {
          creationCompleted = true;
          return instance;
        });

        await Future<void>.delayed(Duration.zero);
        expect(creationCompleted, isFalse);

        releaseDispose.complete();

        await disposal.timeout(const Duration(seconds: 2));
        final second = await creation.timeout(const Duration(seconds: 2));

        expect(second, isNot(same(first)));
      },
    );

    test('destroy should reject an unknown explicit context', () async {
      final ddi = DDI.newInstance();

      await ddi.singleton<CoreReviewServiceA>(CoreReviewServiceA.new);

      await expectLater(
        Future<void>.sync(
          () => ddi.destroy<CoreReviewServiceA>(context: 'missing-context'),
        ),
        throwsA(isA<ContextNotFoundException>()),
      );

      expect(ddi.isRegistered<CoreReviewServiceA>(), isTrue);
    });

    test('dispose should reject an unknown explicit context', () async {
      final ddi = DDI.newInstance();

      await ddi.application<CoreReviewServiceA>(CoreReviewServiceA.new);

      await expectLater(
        Future<void>.sync(
          () => ddi.dispose<CoreReviewServiceA>(context: 'missing-context'),
        ),
        throwsA(isA<ContextNotFoundException>()),
      );

      expect(ddi.isRegistered<CoreReviewServiceA>(), isTrue);
    });

    test('unfreezeContext should reject an unknown context', () {
      final ddi = DDI.newInstance();

      expect(
        () => ddi.unfreezeContext('missing-context'),
        throwsA(isA<ContextNotFoundException>()),
      );
    });

    test(
      'get should fallback to a parent context when explicit context has no local bean',
      () async {
        final ddi = DDI.newInstance();

        await ddi.application<CoreReviewContextService>(
          () => const CoreReviewContextService('root'),
          qualifier: 'root-service',
        );

        ddi.createContext('ctx');

        expect(
          ddi
              .get<CoreReviewContextService>(
                qualifier: 'root-service',
                context: 'ctx',
              )
              .origin,
          equals('root'),
        );
      },
    );

    test(
      'getOptional should fallback to a parent context when explicit context has no local bean',
      () async {
        final ddi = DDI.newInstance();

        await ddi.application<CoreReviewContextService>(
          () => const CoreReviewContextService('root'),
          qualifier: 'root-service',
        );

        ddi.createContext('ctx');

        expect(
          ddi
              .getOptional<CoreReviewContextService>(
                qualifier: 'root-service',
                context: 'ctx',
              )
              ?.origin,
          equals('root'),
        );
      },
    );

    test(
      'getAsync should fallback to a parent context when explicit context has no local bean',
      () async {
        final ddi = DDI.newInstance();

        await ddi.application<CoreReviewContextService>(
          () async => const CoreReviewContextService('root'),
          qualifier: 'root-service',
        );

        ddi.createContext('ctx');

        final service = await ddi.getAsync<CoreReviewContextService>(
          qualifier: 'root-service',
          context: 'ctx',
        );

        expect(service.origin, equals('root'));
      },
    );

    test(
      'selector lookup should fallback to a parent context from an explicit context',
      () async {
        final ddi = DDI.newInstance();

        await ddi.application<CoreReviewContextService>(
          () => const CoreReviewContextService('root-selected'),
          qualifier: 'root-selected',
          selector: (value) => value == 'selected',
        );

        ddi.createContext('ctx');

        expect(
          ddi
              .get<CoreReviewContextService>(
                select: 'selected',
                context: 'ctx',
              )
              .origin,
          equals('root-selected'),
        );
      },
    );

    test(
      'async selector lookup should fallback to a parent context from an explicit context',
      () async {
        final ddi = DDI.newInstance();

        await ddi.application<CoreReviewContextService>(
          () async => const CoreReviewContextService('root-selected'),
          qualifier: 'root-selected',
          selector: (value) async => value == 'selected',
        );

        ddi.createContext('ctx');

        final service = await ddi.getAsync<CoreReviewContextService>(
          select: 'selected',
          context: 'ctx',
        );

        expect(service.origin, equals('root-selected'));
      },
    );

    test(
      'isRegistered and isReady should fallback from active context when context is omitted',
      () async {
        final ddi = DDI.newInstance();

        await ddi.singleton<CoreReviewContextService>(
          () => const CoreReviewContextService('root'),
          qualifier: 'root-service',
        );

        ddi.createContext('ctx');

        expect(
          ddi.isRegistered<CoreReviewContextService>(
            qualifier: 'root-service',
          ),
          isTrue,
        );
        expect(
          ddi.isReady<CoreReviewContextService>(
            qualifier: 'root-service',
          ),
          isTrue,
        );
        expect(
          ddi.isRegistered<CoreReviewContextService>(
            qualifier: 'root-service',
            context: 'ctx',
          ),
          isFalse,
        );
      },
    );

    test(
      'destroy should not fallback when an explicit context has no local bean',
      () async {
        final ddi = DDI.newInstance();

        await ddi.singleton<CoreReviewContextService>(
          () => const CoreReviewContextService('root'),
          qualifier: 'root-service',
        );

        ddi.createContext('ctx');

        await ddi.destroy<CoreReviewContextService>(
          qualifier: 'root-service',
          context: 'ctx',
        );

        expect(
          ddi.isRegistered<CoreReviewContextService>(
            qualifier: 'root-service',
          ),
          isTrue,
        );
      },
    );

    test(
      'dispose should not fallback when an explicit context has no local bean',
      () async {
        final ddi = DDI.newInstance();

        await ddi.application<CoreReviewContextService>(
          () => const CoreReviewContextService('root'),
          qualifier: 'root-service',
        );
        ddi.get<CoreReviewContextService>(qualifier: 'root-service');

        ddi.createContext('ctx');

        await expectLater(
          Future<void>.sync(
            () => ddi.dispose<CoreReviewContextService>(
              qualifier: 'root-service',
              context: 'ctx',
            ),
          ),
          throwsA(isA<BeanNotFoundException>()),
        );
        expect(
          ddi.isReady<CoreReviewContextService>(
            qualifier: 'root-service',
          ),
          isTrue,
        );
      },
    );
  });
}
