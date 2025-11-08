import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/c.dart';
import '../clazz_samples/test_service.dart';

void main() {
  group('DDI Instance Tests', () {
    tearDown(() {
      ddi.destroyByType<TestService>();
      ddi.destroyByType<C>();
    });

    tearDownAll(() {
      expect(ddi.isEmpty, true);
    });

    test('Instance should be resolvable when bean is registered', () {
      ddi.singleton<TestService>(TestService.new);

      final instance = ddi.getInstance<TestService>();

      expect(instance.isResolvable(), isTrue);
    });

    test('Instance should not be resolvable when bean is not registered', () {
      expect(
        () => ddi.getInstance<TestService>(),
        throwsA(isA<BeanNotFoundException>()),
      );
    });

    test('Instance.get() should return the bean instance', () {
      ddi.singleton<TestService>(TestService.new);

      final instance = ddi.getInstance<TestService>();
      final service = instance.get();

      expect(service, isA<TestService>());
      expect(service.doSomething(), equals('done'));
    });

    test('Instance.getAsync() should return the bean instance asynchronously',
        () async {
      ddi.singleton<TestService>(TestService.new);

      final instance = ddi.getInstance<TestService>();
      final service = await instance.getAsync();

      expect(service, isA<TestService>());
      expect(service.doSomething(), equals('done'));
    });

    test('Instance.get() should work with parameters', () {
      ddi.dependent<TestService>(
        TestService.new,
      );

      final instance = ddi.getInstance<TestService>();
      final service1 = instance.get();
      final service2 = instance.get();

      // Dependent creates new instances
      expect(service1, isNot(same(service2)));
    });

    test('Instance.destroy() should destroy the bean', () async {
      ddi.application<TestService>(TestService.new);

      final instance = ddi.getInstance<TestService>();
      expect(instance.isResolvable(), isTrue);

      await instance.destroy();

      expect(instance.isResolvable(), isFalse);
      expect(
        () => instance.get(),
        throwsA(isA<BeanNotFoundException>()),
      );
    });

    test('Instance.dispose() should dispose the bean', () async {
      ddi.application<TestService>(TestService.new);

      final instance = ddi.getInstance<TestService>();
      expect(instance.isResolvable(), isTrue);

      await instance.dispose();

      // After dispose, bean should still be registered but instance may be null
      expect(instance.isResolvable(), isTrue);
    });

    test('Instance should work with qualifiers', () {
      ddi.singleton<TestService>(
        TestService.new,
        qualifier: 'service1',
      );
      ddi.singleton<TestService>(
        TestService.new,
        qualifier: 'service2',
      );

      final Instance<TestService> instance1 =
          ddi.getInstance<TestService>(qualifier: 'service1');
      final Instance<TestService> instance2 =
          ddi.getInstance<TestService>(qualifier: 'service2');

      expect(instance1.isResolvable(), isTrue);
      expect(instance2.isResolvable(), isTrue);

      final service1 = instance1.get();
      final service2 = instance2.get();

      expect(service1, isNot(same(service2)));
    });
  });
}
