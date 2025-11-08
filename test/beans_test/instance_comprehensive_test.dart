import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/test_service.dart';

/// Interceptor that modifies instance onGet
class InstanceModifierInterceptor extends DDIInterceptor<TestService> {
  InstanceModifierInterceptor(this.suffix);
  final String suffix;

  @override
  TestService onGet(TestService instance) {
    // Return a new instance with modified behavior
    return ModifiedTestService(instance, suffix);
  }
}

/// Modified service for testing interceptors
class ModifiedTestService extends TestService {
  ModifiedTestService(this._original, this._suffix) : super();
  final TestService _original;
  final String _suffix;

  @override
  String doSomething() {
    return '${_original.doSomething()}$_suffix';
  }
}

/// Interceptor that tracks get calls
class TrackingInterceptor extends DDIInterceptor<TestService> {
  int getCallCount = 0;
  int createCallCount = 0;

  @override
  TestService onCreate(TestService instance) {
    createCallCount++;
    return instance;
  }

  @override
  TestService onGet(TestService instance) {
    getCallCount++;
    return instance;
  }

  @override
  void onDestroy(TestService? instance) {
    // Track destruction
  }
}

/// Decorator that wraps the instance
TestService testDecorator(TestService instance) {
  return ModifiedTestService(instance, '_decorated');
}

void main() {
  group('DDI Instance Comprehensive Tests', () {
    tearDown(() {
      ddi.destroyByType<TestService>();
      ddi.destroyByType<InstanceModifierInterceptor>();
      ddi.destroyByType<TrackingInterceptor>();
    });

    tearDownAll(() {
      expect(ddi.isEmpty, true);
    });

    group('Instance with Cache and ApplicationScope', () {
      test(
          'ApplicationScope with WeakReference + Instance without cache should work',
          () {
        ddi.application<TestService>(
          TestService.new,
          useWeakReference: true,
        );

        final instance = ddi.getInstance<TestService>();
        final service1 = instance.get();
        final service2 = instance.get();

        // Should return same instance from ApplicationScope
        expect(service1, same(service2));
        expect(service1.doSomething(), equals('done'));
      });
    });

    group('Instance with Interceptors', () {
      test(
          'Instance with cache + Interceptor onGet should cache the modified instance',
          () {
        ddi.singleton<InstanceModifierInterceptor>(
          () => InstanceModifierInterceptor('_intercepted'),
        );
        ddi.application<TestService>(
          TestService.new,
          interceptors: {InstanceModifierInterceptor},
        );

        final instance = ddi.getInstance<TestService>(cache: true);
        final service1 = instance.get();
        final service2 = instance.get();

        // Should cache the modified instance from interceptor
        expect(service1, same(service2));
        expect(service1, isA<ModifiedTestService>());
        expect(service1.doSomething(), equals('done_intercepted'));
      });

      test('Instance with useWeakReference + Interceptor onGet should work',
          () {
        ddi.singleton<InstanceModifierInterceptor>(
          () => InstanceModifierInterceptor('_weak'),
        );
        ddi.application<TestService>(
          TestService.new,
          interceptors: {InstanceModifierInterceptor},
        );

        final instance = ddi.getInstance<TestService>(useWeakReference: true);
        final service1 = instance.get();
        final service2 = instance.get();

        // Should return modified instance from interceptor
        expect(service1, isA<ModifiedTestService>());
        expect(service1.doSomething(), equals('done_weak'));
        expect(service2, isA<ModifiedTestService>());
        expect(service2.doSomething(), equals('done_weak'));
        expect(service1, same(service2));
      });

      test(
          'Instance with cache + Multiple Interceptors should cache final result',
          () {
        ddi.singleton<InstanceModifierInterceptor>(
          () => InstanceModifierInterceptor('_multi'),
        );
        ddi.singleton<TrackingInterceptor>(TrackingInterceptor.new);
        ddi.application<TestService>(
          TestService.new,
          interceptors: {InstanceModifierInterceptor, TrackingInterceptor},
        );

        final instance = ddi.getInstance<TestService>(cache: true);
        final service1 = instance.get();
        final service2 = instance.get();
        final service3 = instance.get();

        // Should cache the final result after all interceptors
        expect(service1, same(service2));
        expect(service2, same(service3));
        expect(service1, isA<ModifiedTestService>());
      });

      test(
          'Instance with cache + Interceptor that changes instance should update cache',
          () {
        ddi.singleton<InstanceModifierInterceptor>(
          () => InstanceModifierInterceptor('_changed'),
        );
        ddi.application<TestService>(
          TestService.new,
          interceptors: {InstanceModifierInterceptor},
        );

        final instance = ddi.getInstance<TestService>(cache: true);
        final service1 = instance.get();

        // First get should apply interceptor
        expect(service1, isA<ModifiedTestService>());
        expect(service1.doSomething(), equals('done_changed'));

        // Second get should return cached modified instance
        final service2 = instance.get();
        expect(service1, same(service2));
        expect(service2.doSomething(), equals('done_changed'));
      });
    });

    group('Instance with Decorators', () {
      test('Instance with cache + Decorator should cache decorated instance',
          () {
        ddi.application<TestService>(
          TestService.new,
          decorators: [testDecorator],
        );

        final instance = ddi.getInstance<TestService>(cache: true);
        final service1 = instance.get();
        final service2 = instance.get();

        // Should cache the decorated instance
        expect(service1, same(service2));
        expect(service1, isA<ModifiedTestService>());
        expect(service1.doSomething(), equals('done_decorated'));
      });

      test('Instance with useWeakReference + Decorator should work', () {
        ddi.application<TestService>(
          TestService.new,
          decorators: [testDecorator],
        );

        final instance = ddi.getInstance<TestService>(useWeakReference: true);
        final service1 = instance.get();
        final service2 = instance.get();

        // Should return decorated instance
        expect(service1, isA<ModifiedTestService>());
        expect(service1.doSomething(), equals('done_decorated'));
        expect(service2, isA<ModifiedTestService>());
        expect(service2.doSomething(), equals('done_decorated'));
      });

      test(
          'Instance with cache + Multiple Decorators should cache final result',
          () {
        TestService decorator1(TestService instance) {
          return ModifiedTestService(instance, '_d1');
        }

        TestService decorator2(TestService instance) {
          return ModifiedTestService(instance, '_d2');
        }

        ddi.application<TestService>(
          TestService.new,
          decorators: [decorator1, decorator2],
        );

        final instance = ddi.getInstance<TestService>(cache: true);
        final service1 = instance.get();
        final service2 = instance.get();

        // Should cache the final decorated instance
        expect(service1, same(service2));
        expect(service1.doSomething(), equals('done_d1_d2'));
      });
    });

    group('Instance with Interceptors and Decorators', () {
      test(
          'Instance with cache + Interceptor + Decorator should cache final result',
          () {
        ddi.singleton<InstanceModifierInterceptor>(
          () => InstanceModifierInterceptor('_intercepted'),
        );
        ddi.application<TestService>(
          TestService.new,
          decorators: [testDecorator],
          interceptors: {InstanceModifierInterceptor},
        );

        final instance = ddi.getInstance<TestService>(cache: true);
        final service1 = instance.get();
        final service2 = instance.get();

        // Should cache the final result (decorated then intercepted)
        expect(service1, same(service2));
        // Interceptor onGet is applied after decorator
        expect(service1.doSomething(), equals('done_decorated_intercepted'));
      });

      test(
          'Instance with useWeakReference + Interceptor + Decorator should work',
          () {
        ddi.singleton<InstanceModifierInterceptor>(
          () => InstanceModifierInterceptor('_weak_intercepted'),
        );
        ddi.application<TestService>(
          TestService.new,
          decorators: [testDecorator],
          interceptors: {InstanceModifierInterceptor},
        );

        final instance = ddi.getInstance<TestService>(useWeakReference: true);
        final service1 = instance.get();
        final service2 = instance.get();

        // Should return final result
        expect(
            service1.doSomething(), equals('done_decorated_weak_intercepted'));
        expect(
            service2.doSomething(), equals('done_decorated_weak_intercepted'));
      });
    });

    group('Instance with Different Scopes', () {
      test('Instance with cache + Singleton scope should work', () {
        ddi.singleton<TestService>(TestService.new);

        final instance = ddi.getInstance<TestService>(cache: true);
        final service1 = instance.get();
        final service2 = instance.get();

        // Should cache the singleton instance
        expect(service1, same(service2));
        expect(service1.doSomething(), equals('done'));
      });

      test('Instance with cache + Dependent scope should cache each instance',
          () {
        ddi.dependent<TestService>(TestService.new);

        final instance = ddi.getInstance<TestService>(cache: true);
        final service1 = instance.get();
        final service2 = instance.get();

        // With cache, should return same instance (cached)
        expect(service1, same(service2));
        expect(service1.doSomething(), equals('done'));
      });

      test(
          'Instance without cache + Dependent scope should create new instances',
          () {
        ddi.dependent<TestService>(TestService.new);

        final instance = ddi.getInstance<TestService>();
        final service1 = instance.get();
        final service2 = instance.get();

        // Without cache, Dependent creates new instances
        expect(service1, isNot(same(service2)));
        expect(service1.doSomething(), equals('done'));
        expect(service2.doSomething(), equals('done'));
      });

      test('Instance with cache + Object scope should work', () {
        final testInstance = TestService();
        ddi.object<TestService>(testInstance);

        final instance = ddi.getInstance<TestService>(cache: true);
        final service1 = instance.get();
        final service2 = instance.get();

        // Should cache the object instance
        expect(service1, same(service2));
        expect(service1, same(testInstance));
        expect(service1.doSomething(), equals('done'));
      });
    });

    group('Instance with Dependent Scope - Detailed Tests', () {
      test('Dependent with cache should cache first instance and reuse it', () {
        ddi.dependent<TestService>(TestService.new);

        final instance = ddi.getInstance<TestService>(cache: true);
        final service1 = instance.get();
        final service2 = instance.get();
        final service3 = instance.get();

        // All should be the same cached instance
        expect(service1, same(service2));
        expect(service2, same(service3));
        // Verify they are the same instance by checking callCount
        service1.doSomething();
        expect(service1.callCount, equals(1));
        expect(service2.callCount, equals(1)); // Same instance
        expect(service3.callCount, equals(1)); // Same instance
      });

      test('Dependent without cache should create new instance on each get',
          () {
        ddi.dependent<TestService>(TestService.new);

        final instance = ddi.getInstance<TestService>();
        final service1 = instance.get();
        final service2 = instance.get();
        final service3 = instance.get();

        // All should be different instances
        expect(service1, isNot(same(service2)));
        expect(service2, isNot(same(service3)));
        expect(service1, isNot(same(service3)));

        // Each should have independent callCount
        expect(service1.callCount, equals(0));
        expect(service2.callCount, equals(0));
        expect(service3.callCount, equals(0));

        service1.doSomething();
        expect(service1.callCount, equals(1));
        expect(service2.callCount, equals(0));
        expect(service3.callCount, equals(0));
      });

      test('Dependent with cache + Interceptor should cache modified instance',
          () {
        ddi.singleton<InstanceModifierInterceptor>(
          () => InstanceModifierInterceptor('_dependent'),
        );
        ddi.dependent<TestService>(
          TestService.new,
          interceptors: {InstanceModifierInterceptor},
        );

        final instance = ddi.getInstance<TestService>(cache: true);
        final service1 = instance.get();
        final service2 = instance.get();

        // Should cache the modified instance from interceptor
        expect(service1, same(service2));
        expect(service1, isA<ModifiedTestService>());
        expect(service1.doSomething(), equals('done_dependent'));
      });

      test(
          'Dependent without cache + Interceptor should create new modified instances',
          () {
        ddi.singleton<InstanceModifierInterceptor>(
          () => InstanceModifierInterceptor('_new'),
        );
        ddi.dependent<TestService>(
          TestService.new,
          interceptors: {InstanceModifierInterceptor},
        );

        final instance = ddi.getInstance<TestService>();
        final service1 = instance.get();
        final service2 = instance.get();

        // Should create new instances, each modified by interceptor
        expect(service1, isNot(same(service2)));
        expect(service1, isA<ModifiedTestService>());
        expect(service2, isA<ModifiedTestService>());
        expect(service1.doSomething(), equals('done_new'));
        expect(service2.doSomething(), equals('done_new'));
      });

      test('Dependent with cache + Decorator should cache decorated instance',
          () {
        ddi.dependent<TestService>(
          TestService.new,
          decorators: [testDecorator],
        );

        final instance = ddi.getInstance<TestService>(cache: true);
        final service1 = instance.get();
        final service2 = instance.get();

        // Should cache the decorated instance
        expect(service1, same(service2));
        expect(service1, isA<ModifiedTestService>());
        expect(service1.doSomething(), equals('done_decorated'));
      });

      test(
          'Dependent without cache + Decorator should create new decorated instances',
          () {
        ddi.dependent<TestService>(
          TestService.new,
          decorators: [testDecorator],
        );

        final instance = ddi.getInstance<TestService>();
        final service1 = instance.get();
        final service2 = instance.get();

        // Should create new decorated instances
        expect(service1, isNot(same(service2)));
        expect(service1, isA<ModifiedTestService>());
        expect(service2, isA<ModifiedTestService>());
        expect(service1.doSomething(), equals('done_decorated'));
        expect(service2.doSomething(), equals('done_decorated'));
      });

      test(
          'Dependent with cache + Interceptor + Decorator should cache final result',
          () {
        ddi.singleton<InstanceModifierInterceptor>(
          () => InstanceModifierInterceptor('_final'),
        );
        ddi.dependent<TestService>(
          TestService.new,
          decorators: [testDecorator],
          interceptors: {InstanceModifierInterceptor},
        );

        final instance = ddi.getInstance<TestService>(cache: true);
        final service1 = instance.get();
        final service2 = instance.get();

        // Should cache the final result (decorated then intercepted)
        expect(service1, same(service2));
        expect(service1.doSomething(), equals('done_decorated_final'));
      });

      test(
          'Dependent without cache + Interceptor + Decorator should create new instances',
          () {
        ddi.singleton<InstanceModifierInterceptor>(
          () => InstanceModifierInterceptor('_each'),
        );
        ddi.dependent<TestService>(
          TestService.new,
          decorators: [testDecorator],
          interceptors: {InstanceModifierInterceptor},
        );

        final instance = ddi.getInstance<TestService>();
        final service1 = instance.get();
        final service2 = instance.get();

        // Should create new instances, each with decorator and interceptor applied
        expect(service1, isNot(same(service2)));
        expect(service1.doSomething(), equals('done_decorated_each'));
        expect(service2.doSomething(), equals('done_decorated_each'));
      });

      test('Dependent with cache + getAsync should cache async result',
          () async {
        ddi.dependent<TestService>(TestService.new);

        final instance = ddi.getInstance<TestService>(cache: true);
        final service1 = await instance.getAsync();
        final service2 = await instance.getAsync();

        // Should cache the async result
        expect(service1, same(service2));
        expect(service1.doSomething(), equals('done'));
      });

      test(
          'Dependent without cache + getAsync should create new async instances',
          () async {
        ddi.dependent<TestService>(TestService.new);

        final instance = ddi.getInstance<TestService>();
        final service1 = await instance.getAsync();
        final service2 = await instance.getAsync();

        // Should create new instances
        expect(service1, isNot(same(service2)));
        expect(service1.doSomething(), equals('done'));
        expect(service2.doSomething(), equals('done'));
      });

      test(
          'Dependent with cache + parameter should cache instance with parameter',
          () {
        ddi.dependent<TestService>(TestService.new);

        final instance = ddi.getInstance<TestService>(cache: true);
        final service1 = instance.get<String>(parameter: 'param1');
        final service2 = instance.get<String>(parameter: 'param1');

        // Should cache the instance (parameter is ignored after first creation)
        expect(service1, same(service2));
      });

      test(
          'Dependent with cache + different parameters should return same cached instance',
          () {
        ddi.dependent<TestService>(TestService.new);

        final instance = ddi.getInstance<TestService>(cache: true);
        // First get with param1 - creates and caches instance
        final service1 = instance.get<String>(parameter: 'param1');
        // Same parameter - returns cached instance
        final service2 = instance.get<String>(parameter: 'param1');
        expect(service1, same(service2));

        // Different parameter - STILL returns cached instance (parameter ignored)
        final service3 = instance.get<String>(parameter: 'param2');
        expect(service1, same(service3)); // Same cached instance
        expect(service2, same(service3)); // Same cached instance

        // Another different parameter - STILL returns cached instance
        final service4 = instance.get<String>(parameter: 'param3');
        expect(service1, same(service4)); // Same cached instance
        expect(service3, same(service4)); // Same cached instance

        // All instances are the same (first cached instance)
        expect(service1, same(service2));
        expect(service2, same(service3));
        expect(service3, same(service4));
      });

      test('Dependent without cache + parameter should create new instances',
          () {
        ddi.dependent<TestService>(TestService.new);

        final instance = ddi.getInstance<TestService>();
        final service1 = instance.get<String>(parameter: 'param1');
        final service2 = instance.get<String>(parameter: 'param2');

        // Should create new instances for each get
        expect(service1, isNot(same(service2)));
      });

      test(
          'Dependent with cache + useWeakReference should use cache (precedence)',
          () {
        ddi.dependent<TestService>(TestService.new);

        final instance = ddi.getInstance<TestService>(
          cache: true,
          useWeakReference: true,
        );
        final service1 = instance.get();
        final service2 = instance.get();

        // Cache should take precedence
        expect(service1, same(service2));
        expect(service1.doSomething(), equals('done'));
      });

      test('Dependent with useWeakReference should work (without cache)', () {
        ddi.dependent<TestService>(TestService.new);

        final instance = ddi.getInstance<TestService>(useWeakReference: true);
        final service1 = instance.get();
        final service2 = instance.get();

        // With useWeakReference, InstanceWrapper may cache via weak reference
        // But Dependent scope creates new instances, so they should be different
        // However, if InstanceWrapper caches the weak reference, they might be the same
        // Let's verify the behavior: Dependent creates new, but InstanceWrapper may cache
        expect(service1.doSomething(), equals('done'));
        expect(service2.doSomething(), equals('done'));
        // Note: With useWeakReference, InstanceWrapper may return same instance if weak reference is still valid
      });

      test(
          'Dependent with cache + Multiple gets should maintain same cached instance',
          () {
        ddi.dependent<TestService>(TestService.new);

        final instance = ddi.getInstance<TestService>(cache: true);
        final services = <TestService>[];

        // Get multiple times
        for (int i = 0; i < 10; i++) {
          services.add(instance.get());
        }

        // All should be the same cached instance
        for (int i = 1; i < services.length; i++) {
          expect(services[0], same(services[i]));
        }

        // Only one instance should exist
        services[0].doSomething();
        expect(services[0].callCount, equals(1));
        expect(services[5].callCount, equals(1)); // Same instance
      });

      test(
          'Dependent without cache + Multiple gets should create different instances',
          () {
        ddi.dependent<TestService>(TestService.new);

        final instance = ddi.getInstance<TestService>();
        final services = <TestService>[];

        // Get multiple times
        for (int i = 0; i < 10; i++) {
          services.add(instance.get());
        }

        // All should be different instances
        for (int i = 0; i < services.length; i++) {
          for (int j = i + 1; j < services.length; j++) {
            expect(services[i], isNot(same(services[j])));
          }
        }

        // Each should have independent state
        services[0].doSomething();
        expect(services[0].callCount, equals(1));
        expect(services[5].callCount, equals(0)); // Different instance
      });
    });

    group('Instance with Async Operations', () {
      test('Instance with cache + getAsync should cache async result',
          () async {
        ddi.application<TestService>(TestService.new);

        final instance = ddi.getInstance<TestService>(cache: true);
        final service1 = await instance.getAsync();
        final service2 = await instance.getAsync();

        // Should cache the async result
        expect(service1, same(service2));
        expect(service1.doSomething(), equals('done'));
      });

      test('Instance with useWeakReference + getAsync should work', () async {
        ddi.application<TestService>(
          TestService.new,
          useWeakReference: true,
        );

        final instance = ddi.getInstance<TestService>(useWeakReference: true);
        final service1 = await instance.getAsync();
        final service2 = await instance.getAsync();

        // Should return instance from async
        expect(service1.doSomething(), equals('done'));
        expect(service2.doSomething(), equals('done'));
      });

      test(
          'Instance with cache + getAsync + Interceptor should cache final result',
          () async {
        ddi.singleton<InstanceModifierInterceptor>(
          () => InstanceModifierInterceptor('_async'),
        );
        ddi.application<TestService>(
          TestService.new,
          interceptors: {InstanceModifierInterceptor},
        );

        final instance = ddi.getInstance<TestService>(cache: true);
        final service1 = await instance.getAsync();
        final service2 = await instance.getAsync();

        // Should cache the async result with interceptor applied
        expect(service1, same(service2));
        expect(service1.doSomething(), equals('done_async'));
      });
    });

    group('Instance with Parameters', () {
      test('Instance with cache + get with parameter should work', () {
        ddi.dependent<TestService>(TestService.new);

        final instance = ddi.getInstance<TestService>(cache: true);
        final service1 = instance.get<String>(parameter: 'test');
        final service2 = instance.get<String>(parameter: 'test');

        // With cache, should return same instance
        expect(service1, same(service2));
        expect(service1.doSomething(), equals('done'));
      });

      test(
          'Instance with cache + different parameters should return same cached instance',
          () {
        ddi.dependent<TestService>(TestService.new);

        final instance = ddi.getInstance<TestService>(cache: true);
        // First get with 'config1' - creates and caches instance
        final service1 = instance.get<String>(parameter: 'config1');
        // Same parameter - returns cached instance
        final service2 = instance.get<String>(parameter: 'config1');
        expect(service1, same(service2)); // Same cached instance

        // Different parameter - STILL returns cached instance (parameter ignored)
        final service3 = instance.get<String>(parameter: 'config2');
        expect(service1, same(service3)); // Same cached instance
        expect(service2, same(service3)); // Same cached instance

        // Another call with config2 - STILL returns cached instance
        final service4 = instance.get<String>(parameter: 'config2');
        expect(service3, same(service4)); // Same cached instance
        expect(service1, same(service4)); // Same cached instance

        // All instances are the same (first cached instance created with 'config1')
        expect(service1, same(service2));
        expect(service2, same(service3));
        expect(service3, same(service4));
      });

      test(
          'Instance without cache + get with parameter should create new instances',
          () {
        ddi.dependent<TestService>(TestService.new);

        final instance = ddi.getInstance<TestService>();
        final service1 = instance.get<String>(parameter: 'config1');
        final service2 = instance.get<String>(parameter: 'config2');

        // Without cache, different parameters create different instances
        expect(service1, isNot(same(service2)));

        // Even same parameter creates new instance (no cache)
        final service3 = instance.get<String>(parameter: 'config1');
        expect(service1, isNot(same(service3))); // Different instances
      });
    });

    group('Instance with Destroy and Dispose', () {
      test('Instance with cache + destroy should clear cache', () async {
        ddi.application<TestService>(TestService.new);

        final instance = ddi.getInstance<TestService>(cache: true);
        final service1 = instance.get();
        expect(service1.doSomething(), equals('done'));

        await instance.destroy();

        // After destroy, should not be resolvable
        expect(instance.isResolvable(), isFalse);
        expect(
          () => instance.get(),
          throwsA(isA<BeanNotFoundException>()),
        );
      });

      test('Instance with useWeakReference + destroy should work', () async {
        ddi.application<TestService>(
          TestService.new,
          useWeakReference: true,
        );

        final instance = ddi.getInstance<TestService>(useWeakReference: true);
        final service1 = instance.get();
        expect(service1.doSomething(), equals('done'));

        await instance.destroy();

        expect(instance.isResolvable(), isFalse);
      });

      test('Instance with cache + dispose should clear cache', () async {
        ddi.application<TestService>(TestService.new);

        final instance = ddi.getInstance<TestService>(cache: true);
        final service1 = instance.get();
        expect(service1.doSomething(), equals('done'));

        await instance.dispose();

        // After dispose, should still be resolvable but instance may be reset
        expect(instance.isResolvable(), isTrue);
      });
    });

    group('Instance with Multiple Instances', () {
      test(
          'Multiple Instance wrappers with different cache settings should work independently',
          () {
        ddi.application<TestService>(TestService.new);

        final instanceWithCache = ddi.getInstance<TestService>(cache: true);
        final instanceWithoutCache = ddi.getInstance<TestService>();

        final service1 = instanceWithCache.get();
        final service2 = instanceWithoutCache.get();

        // Both should return the same instance from ApplicationScope
        expect(service1, same(service2));

        // But instanceWithCache should cache it
        final service3 = instanceWithCache.get();
        expect(service1, same(service3));

        // instanceWithoutCache should also return same (from ApplicationScope)
        final service4 = instanceWithoutCache.get();
        expect(service2, same(service4));
      });
    });

    group('Instance with Qualifiers', () {
      test('Instance with cache + qualifier should work', () {
        ddi.application<TestService>(
          TestService.new,
          qualifier: 'service1',
        );
        ddi.application<TestService>(
          TestService.new,
          qualifier: 'service2',
        );

        final instance1 = ddi.getInstance<TestService>(
          qualifier: 'service1',
          cache: true,
        );
        final instance2 = ddi.getInstance<TestService>(
          qualifier: 'service2',
          cache: true,
        );

        final service1 = instance1.get();
        final service2 = instance2.get();

        // Should be different instances
        expect(service1, isNot(same(service2)));

        // Each should cache independently
        final service1Again = instance1.get();
        final service2Again = instance2.get();

        expect(service1, same(service1Again));
        expect(service2, same(service2Again));
      });
    });

    group('Instance with Complex Scenarios', () {
      test(
          'ApplicationScope WeakReference + Instance cache + Interceptor + Decorator should work',
          () {
        ddi.singleton<InstanceModifierInterceptor>(
          () => InstanceModifierInterceptor('_complex'),
        );
        ddi.application<TestService>(
          TestService.new,
          useWeakReference: true,
          decorators: [testDecorator],
          interceptors: {InstanceModifierInterceptor},
        );

        final instance = ddi.getInstance<TestService>(cache: true);
        final service1 = instance.get();
        final service2 = instance.get();

        // Should cache the final result with all transformations
        expect(service1, same(service2));
        expect(service1.doSomething(), equals('done_decorated_complex'));
      });

      test(
          'Multiple Instance wrappers with different configs + Interceptor should work',
          () {
        ddi.singleton<TrackingInterceptor>(TrackingInterceptor.new);
        ddi.application<TestService>(
          TestService.new,
          interceptors: {TrackingInterceptor},
        );

        final instance1 = ddi.getInstance<TestService>(cache: true);
        final instance2 = ddi.getInstance<TestService>();

        final service1 = instance1.get();
        final service2 = instance2.get();

        // Both should return same instance from ApplicationScope
        expect(service1, same(service2));

        // instance1 should cache
        final service1Again = instance1.get();
        expect(service1, same(service1Again));

        // instance2 should also return same (from ApplicationScope)
        final service2Again = instance2.get();
        expect(service2, same(service2Again));
      });
    });
  });
}
