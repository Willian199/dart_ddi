import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';
import '../clazz_samples/by_type_async_behavior_samples.dart';

void main() {
  group('ByType async behavior', () {
    setUp(() {
      AsyncDisposableTarget.preDisposeCalls = 0;
      AsyncDisposableOther.preDisposeCalls = 0;
      AsyncDestroyTarget.preDestroyCalls = 0;
      AsyncDestroyOther.preDestroyCalls = 0;
      SlowAsyncDestroyChild.preDestroyCalls = 0;
      SlowAsyncDestroyChild.gate = null;
    });

    test('disposeByType should only affect BeanT and await async lifecycle',
        () async {
      final ddi = DDI.newInstance();

      await ddi.application<AsyncDisposableTarget>(
        AsyncDisposableTarget.new,
      );
      await ddi.application<AsyncDisposableOther>(
        AsyncDisposableOther.new,
      );

      ddi.get<AsyncDisposableTarget>();
      ddi.get<AsyncDisposableOther>();

      await ddi.disposeByType<AsyncDisposableTarget>();

      expect(AsyncDisposableTarget.preDisposeCalls, 1);
      expect(AsyncDisposableOther.preDisposeCalls, 0);
      expect(ddi.isReady<AsyncDisposableTarget>(), isFalse);
      expect(ddi.isReady<AsyncDisposableOther>(), isTrue);
    });

    test('destroyByType should only affect BeanT and await async lifecycle',
        () async {
      final ddi = DDI.newInstance();

      await ddi.application<AsyncDestroyTarget>(AsyncDestroyTarget.new);
      await ddi.application<AsyncDestroyOther>(AsyncDestroyOther.new);

      ddi.get<AsyncDestroyTarget>();
      ddi.get<AsyncDestroyOther>();

      await ddi.destroyByType<AsyncDestroyTarget>();

      expect(AsyncDestroyTarget.preDestroyCalls, 1);
      expect(AsyncDestroyOther.preDestroyCalls, 0);
      expect(ddi.isRegistered<AsyncDestroyTarget>(), isFalse);
      expect(ddi.isRegistered<AsyncDestroyOther>(), isTrue);
    });

    test('disposeByType without await should still complete eventually',
        () async {
      final ddi = DDI.newInstance();

      await ddi.application<AsyncDisposableTarget>(
        AsyncDisposableTarget.new,
      );
      ddi.get<AsyncDisposableTarget>();

      unawaited(Future<void>.sync(() {
        ddi.disposeByType<AsyncDisposableTarget>();
      }));

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(AsyncDisposableTarget.preDisposeCalls, 1);
      expect(ddi.isReady<AsyncDisposableTarget>(), isFalse);
    });

    test('destroyByType without await should still complete eventually',
        () async {
      final ddi = DDI.newInstance();

      await ddi.application<AsyncDestroyTarget>(AsyncDestroyTarget.new);
      ddi.get<AsyncDestroyTarget>();

      unawaited(Future<void>.sync(() {
        ddi.destroyByType<AsyncDestroyTarget>();
      }));

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(AsyncDestroyTarget.preDestroyCalls, 1);
      expect(ddi.isRegistered<AsyncDestroyTarget>(), isFalse);
    });

    test(
        'destroy parent should await async destroy of children even without parent lifecycle',
        () async {
      final ddi = DDI.newInstance();

      SlowAsyncDestroyChild.gate = Completer<void>();

      await ddi.application<ParentWithoutLifecycle>(
        ParentWithoutLifecycle.new,
        children: {'child'},
      );
      await ddi.application<SlowAsyncDestroyChild>(
        SlowAsyncDestroyChild.new,
        qualifier: 'child',
      );
      ddi.get<SlowAsyncDestroyChild>(qualifier: 'child');

      final destroyFuture = Future<void>.sync(() async {
        await ddi.destroy<ParentWithoutLifecycle>();
      });

      var completed = false;
      unawaited(destroyFuture.then((_) => completed = true));

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(completed, isFalse);
      expect(SlowAsyncDestroyChild.preDestroyCalls, 0);

      SlowAsyncDestroyChild.gate!.complete();
      await destroyFuture;

      expect(SlowAsyncDestroyChild.preDestroyCalls, 1);
      expect(ddi.isRegistered(qualifier: 'child'), isFalse);
      expect(ddi.isRegistered<ParentWithoutLifecycle>(), isFalse);
    });

    test('destroyByType with unknown explicit context should throw', () {
      final ddi = DDI.newInstance();

      expect(
        () => ddi.destroyByType<AsyncDestroyTarget>(context: 'missing-context'),
        throwsA(isA<ContextNotFoundException>()),
      );
    });

    test('disposeByType with unknown explicit context should throw', () {
      final ddi = DDI.newInstance();

      expect(
        () =>
            ddi.disposeByType<AsyncDisposableTarget>(context: 'missing-context'),
        throwsA(isA<ContextNotFoundException>()),
      );
    });
  });
}
