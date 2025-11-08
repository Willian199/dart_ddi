import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/test_service.dart';

void main() {
  group('DDI Instance Cache Tests', () {
    tearDown(() {
      ddi.destroyByType<TestService>();
    });

    tearDownAll(() {
      expect(ddi.isEmpty, true);
    });

    test('Instance with cache should maintain strong reference', () {
      ddi.application<TestService>(
        TestService.new,
      );

      final instance = ddi.getInstance<TestService>(cache: true);
      final service1 = instance.get();
      final service2 = instance.get();

      // With cache, should return the same instance
      expect(service1, same(service2));
      expect(service1.doSomething(), equals('done'));
    });

    test('Instance without cache should not maintain reference', () {
      ddi.application<TestService>(
        TestService.new,
      );

      final instance = ddi.getInstance<TestService>();
      final service1 = instance.get();
      final service2 = instance.get();

      // Without cache, should return the same instance (from ApplicationScope)
      expect(service1, same(service2));
      expect(service1.doSomething(), equals('done'));
    });

    test(
        'Instance with cache = true should convert WeakReference to Strong reference',
        () {
      // ApplicationScope with WeakReference
      ddi.application<TestService>(
        TestService.new,
        useWeakReference: true,
      );

      // Instance with cache = true should maintain strong reference
      final instance = ddi.getInstance<TestService>(cache: true);
      final service1 = instance.get();
      final service2 = instance.get();

      // With cache, should return the same instance
      // The Instance maintains a strong reference, preventing GC
      expect(service1, same(service2));
      expect(service1.doSomething(), equals('done'));

      // Verify that the cached instance is the same on subsequent calls
      final service3 = instance.get();
      expect(service3, same(service1));
    });

    test('Instance with useWeakReference = true should use weak reference', () {
      ddi.application<TestService>(
        TestService.new,
      );

      // Instance with useWeakReference = true
      final instance = ddi.getInstance<TestService>(useWeakReference: true);
      final service1 = instance.get();
      final service2 = instance.get();

      // Should return the same instance (from ApplicationScope)
      expect(service1, same(service2));
      expect(service1.doSomething(), equals('done'));
    });

    test(
        'Instance with cache = true should take precedence over useWeakReference',
        () {
      ddi.application<TestService>(
        TestService.new,
        useWeakReference: true,
      );

      // Both cache and useWeakReference are true, but cache takes precedence
      final instance = ddi.getInstance<TestService>(
        cache: true,
        useWeakReference: true,
      );
      final service1 = instance.get();
      final service2 = instance.get();

      // With cache, should return the same instance and maintain strong reference
      expect(service1, same(service2));
      expect(service1.doSomething(), equals('done'));

      // Verify that the cached instance is the same on subsequent calls
      final service3 = instance.get();
      expect(service3, same(service1));
    });

    test('Instance cache should work with ApplicationScope WeakReference', () {
      // ApplicationScope with WeakReference
      ddi.application<TestService>(
        TestService.new,
        useWeakReference: true,
      );

      // Get instance without cache (should use weak reference from ApplicationScope)
      final instanceWithoutCache = ddi.getInstance<TestService>();
      final service1 = instanceWithoutCache.get();

      // Get instance with cache (should maintain strong reference)
      final instanceWithCache = ddi.getInstance<TestService>(cache: true);
      final service2 = instanceWithCache.get();

      // Both should return the same instance (from ApplicationScope)
      expect(service1, same(service2));
      expect(service1.doSomething(), equals('done'));

      // Verify that instanceWithCache maintains strong reference
      final service3 = instanceWithCache.get();
      expect(service3, same(service2));
    });
  });
}
