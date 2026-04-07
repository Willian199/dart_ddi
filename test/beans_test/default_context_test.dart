import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';
import '../clazz_samples/default_context_async_pre_destroy_bean.dart';

void main() {
  group('DDI Default Context Tests', () {
    test(
      'default qualifier should support contextual override and restore the global bean afterwards',
      () async {
        final newDdi = DDI.newInstance();

        await newDdi.singleton<String>(() => 'global', qualifier: 'message');

        await newDdi.runInContext('context-1', () async {
          await newDdi.singleton<String>(() => 'context', qualifier: 'message');

          expect(
            newDdi.get<String>(qualifier: 'message'),
            equals('context'),
          );
        });

        expect(
          newDdi.get<String>(qualifier: 'message'),
          equals('global'),
        );
      },
    );

    test(
      'default qualifier should expose the active context during overlapping async callbacks',
      () async {
        final newDdi = DDI.newInstance();

        final contextFuture = newDdi.runInContext('context-1', () async {
          await newDdi.singleton<String>(() => 'context', qualifier: 'message');

          await Future<void>.delayed(const Duration(milliseconds: 5));

          expect(
            newDdi.get<String>(qualifier: 'message'),
            equals('context'),
          );

          return 'done';
        });

        await Future<void>.delayed(const Duration(milliseconds: 1));

        // TODO maybe to fix. Shouldn't be possible to find a async bean outside the context or it should be found if the current context still the same(eg. not finished yet)?
        expect(
          newDdi.isRegistered<String>(qualifier: 'message'),
          isTrue,
        );

        expect(await contextFuture, equals('done'));
        expect(
          newDdi.isRegistered<String>(qualifier: 'message'),
          isFalse,
        );
      },
    );

    test(
      'default qualifier should serialize concurrent async contexts safely',
      () async {
        final newDdi = DDI.newInstance();

        final futureA = newDdi.runInContext('context-A', () async {
          await newDdi.singleton<String>(() => 'A', qualifier: 'message');
          await Future<void>.delayed(const Duration(milliseconds: 5));
          return newDdi.get<String>(qualifier: 'message');
        });

        final futureB = newDdi.runInContext('context-B', () async {
          await newDdi.singleton<String>(() => 'B', qualifier: 'message');
          await Future<void>.delayed(const Duration(milliseconds: 1));
          return newDdi.get<String>(qualifier: 'message');
        });

        expect(await Future.wait([futureA, futureB]), equals(['A', 'B']));
        expect(newDdi.isRegistered<String>(qualifier: 'message'), isFalse);
      },
    );

    test(
      'runInContext should support async bodies and cleanup the contextual bean afterwards',
      () async {
        final newDdi = DDI.newInstance();

        final value = await newDdi.runInContext('context-1', () async {
          await newDdi.singleton<String>(() => 'value', qualifier: 'message');
          return newDdi.get<String>(qualifier: 'message');
        });

        expect(value, equals('value'));
        expect(
          newDdi.isRegistered<String>(qualifier: 'message'),
          isFalse,
        );
      },
    );

    test(
      'async cleanup started by runInContext should preserve the root bean after context cleanup',
      () async {
        final newDdi = DDI.newInstance();

        await newDdi.object<DefaultContextAsyncPreDestroyBean>(
          DefaultContextAsyncPreDestroyBean('root'),
          qualifier: 'bean',
        );

        newDdi.runInContext('context-1', () {
          newDdi.object<DefaultContextAsyncPreDestroyBean>(
            DefaultContextAsyncPreDestroyBean('context'),
            qualifier: 'bean',
          );
        });

        await Future<void>.delayed(const Duration(milliseconds: 5));

        expect(
          newDdi
              .get<DefaultContextAsyncPreDestroyBean>(qualifier: 'bean')
              .origin,
          equals('root'),
        );
      },
    );

    test('runInContext should restore root context after sync exception',
        () async {
      final newDdi = DDI.newInstance();

      await newDdi.singleton<String>(() => 'root', qualifier: 'message');

      expect(
        () => newDdi.runInContext('sync-error-context', () {
          newDdi.singleton<String>(() => 'context', qualifier: 'message');
          throw StateError('sync-failure');
        }),
        throwsA(isA<StateError>()),
      );

      expect(newDdi.get<String>(qualifier: 'message'), equals('root'));
      expect(
        newDdi.isRegistered<String>(
          qualifier: 'message',
          context: 'sync-error-context',
        ),
        isFalse,
      );
    });

    test('runInContext should restore root context after async exception',
        () async {
      final newDdi = DDI.newInstance();

      await newDdi.singleton<String>(() => 'root', qualifier: 'message');

      await expectLater(
        newDdi.runInContext('async-error-context', () async {
          await newDdi.singleton<String>(() => 'context', qualifier: 'message');
          await Future<void>.delayed(const Duration(milliseconds: 1));
          throw StateError('async-failure');
        }),
        throwsA(isA<StateError>()),
      );

      expect(newDdi.get<String>(qualifier: 'message'), equals('root'));
      expect(
        newDdi.isRegistered<String>(
          qualifier: 'message',
          context: 'async-error-context',
        ),
        isFalse,
      );
    });
  });
}
