import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/test_service.dart';

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

/// Decorator that tracks calls
int decoratorCallCount = 0;

TestService trackingDecorator(TestService instance) {
  decoratorCallCount++;
  return instance;
}

void main() {
  group('DDI Instance Interceptor and Decorator Behavior Tests', () {
    tearDown(() {
      ddi.destroyByType<TestService>();
      ddi.destroyByType<TrackingInterceptor>();
      decoratorCallCount = 0;
    });

    tearDownAll(() {
      expect(ddi.isEmpty, true);
    });

    group('Instance with cache = true', () {
      test('Instance with cache = true should call interceptor.onGet only once',
          () {
        ddi.singleton<TrackingInterceptor>(TrackingInterceptor.new);
        ddi.application<TestService>(
          TestService.new,
          interceptors: {TrackingInterceptor},
        );

        final instance = ddi.getInstance<TestService>(cache: true);
        final service1 = instance.get();
        final service2 = instance.get();
        final service3 = instance.get();

        // All should be the same cached instance
        expect(service1, same(service2));
        expect(service2, same(service3));

        final interceptor = ddi.get<TrackingInterceptor>();
        // With Instance.cache = true, interceptor.onGet should be called only once
        expect(interceptor.getCallCount, equals(1));
        expect(interceptor.createCallCount, equals(1));
      });

      test('Instance with cache = true should call decorator only once', () {
        ddi.application<TestService>(
          TestService.new,
          decorators: [trackingDecorator],
        );

        final instance = ddi.getInstance<TestService>(cache: true);
        final service1 = instance.get();
        final service2 = instance.get();
        final service3 = instance.get();

        // All should be the same cached instance
        expect(service1, same(service2));
        expect(service2, same(service3));

        // With Instance.cache = true, decorator should be called only once
        expect(decoratorCallCount, equals(1));
      });
    });

    group('Instance with useWeakReference = true', () {
      test(
          'Instance with useWeakReference = true should call interceptor.onGet only once',
          () {
        ddi.singleton<TrackingInterceptor>(TrackingInterceptor.new);
        ddi.application<TestService>(
          TestService.new,
          interceptors: {TrackingInterceptor},
        );

        final instance = ddi.getInstance<TestService>(useWeakReference: true);
        final service1 = instance.get();
        final service2 = instance.get();
        final service3 = instance.get();

        // All should be the same instance (from ApplicationScope)
        expect(service1, same(service2));
        expect(service2, same(service3));

        final interceptor = ddi.get<TrackingInterceptor>();
        // With Instance.useWeakReference = true, interceptor.onGet should be called only once
        // (when instance is first retrieved and stored in weak reference)
        expect(interceptor.getCallCount, equals(1));
        expect(interceptor.createCallCount, equals(1));
      });

      test(
          'Instance with useWeakReference = true should call decorator only once',
          () {
        ddi.application<TestService>(
          TestService.new,
          decorators: [trackingDecorator],
        );

        final instance = ddi.getInstance<TestService>(useWeakReference: true);
        final service1 = instance.get();
        final service2 = instance.get();
        final service3 = instance.get();

        // All should be the same instance (from ApplicationScope)
        expect(service1, same(service2));
        expect(service2, same(service3));

        // With Instance.useWeakReference = true, decorator should be called only once
        expect(decoratorCallCount, equals(1));
      });
    });

    group('ApplicationScope with useWeakReference = true', () {
      test(
          'ApplicationScope with useWeakReference = true should call interceptor.onGet every time',
          () {
        ddi.singleton<TrackingInterceptor>(TrackingInterceptor.new);
        ddi.application<TestService>(
          TestService.new,
          useWeakReference: true,
          interceptors: {TrackingInterceptor},
        );

        // Get instance without Instance cache/weakReference
        final instance = ddi.getInstance<TestService>();
        final service1 = instance.get();
        final service2 = instance.get();
        final service3 = instance.get();

        // All should be the same instance (from ApplicationScope)
        expect(service1, same(service2));
        expect(service2, same(service3));

        final interceptor = ddi.get<TrackingInterceptor>();
        // With ApplicationScope.useWeakReference = true, interceptor.onGet should be called every time
        // (because instance may be recreated if GC collected)
        expect(interceptor.getCallCount, equals(3));
        expect(interceptor.createCallCount, equals(1)); // Only created once
      });

      test(
          'ApplicationScope with useWeakReference = true should call decorator only during creation',
          () {
        ddi.application<TestService>(
          TestService.new,
          useWeakReference: true,
          decorators: [trackingDecorator],
        );

        // Get instance without Instance cache/weakReference
        final instance = ddi.getInstance<TestService>();
        final service1 = instance.get();
        final service2 = instance.get();
        final service3 = instance.get();

        // All should be the same instance (from ApplicationScope)
        expect(service1, same(service2));
        expect(service2, same(service3));

        // Decorators are applied only during creation, not on each get
        // With ApplicationScope.useWeakReference = true, if instance is GC collected and recreated,
        // decorator would be called again, but in normal flow it's called only once
        expect(decoratorCallCount, equals(1));
      });
    });

    group('ApplicationScope with useWeakReference + Instance with cache', () {
      test(
          'ApplicationScope useWeakReference + Instance cache should call interceptor.onGet only once',
          () {
        ddi.singleton<TrackingInterceptor>(TrackingInterceptor.new);
        ddi.application<TestService>(
          TestService.new,
          useWeakReference: true,
          interceptors: {TrackingInterceptor},
        );

        // Instance with cache should prevent interceptor.onGet from being called multiple times
        final instance = ddi.getInstance<TestService>(cache: true);
        final service1 = instance.get();
        final service2 = instance.get();
        final service3 = instance.get();

        // All should be the same cached instance
        expect(service1, same(service2));
        expect(service2, same(service3));

        final interceptor = ddi.get<TrackingInterceptor>();
        // With Instance.cache = true, interceptor.onGet should be called only once
        // (Instance cache takes precedence over ApplicationScope useWeakReference)
        expect(interceptor.getCallCount, equals(1));
        expect(interceptor.createCallCount, equals(1));
      });

      test(
          'ApplicationScope useWeakReference + Instance cache should call decorator only once',
          () {
        ddi.application<TestService>(
          TestService.new,
          useWeakReference: true,
          decorators: [trackingDecorator],
        );

        // Instance with cache should prevent decorator from being called multiple times
        final instance = ddi.getInstance<TestService>(cache: true);
        final service1 = instance.get();
        final service2 = instance.get();
        final service3 = instance.get();

        // All should be the same cached instance
        expect(service1, same(service2));
        expect(service2, same(service3));

        // With Instance.cache = true, decorator should be called only once
        expect(decoratorCallCount, equals(1));
      });
    });

    group('ApplicationScope without useWeakReference', () {
      test(
          'ApplicationScope without useWeakReference should call interceptor.onGet every time',
          () {
        ddi.singleton<TrackingInterceptor>(TrackingInterceptor.new);
        ddi.application<TestService>(
          TestService.new,
          interceptors: {TrackingInterceptor},
        );

        // Get instance without Instance cache/weakReference
        final instance = ddi.getInstance<TestService>();
        final service1 = instance.get();
        final service2 = instance.get();
        final service3 = instance.get();

        // All should be the same instance (from ApplicationScope)
        expect(service1, same(service2));
        expect(service2, same(service3));

        final interceptor = ddi.get<TrackingInterceptor>();
        // Without Instance cache/weakReference, interceptor.onGet should be called every time
        expect(interceptor.getCallCount, equals(3));
        expect(interceptor.createCallCount, equals(1)); // Only created once
      });

      test(
          'ApplicationScope without useWeakReference should call decorator only during creation',
          () {
        ddi.application<TestService>(
          TestService.new,
          decorators: [trackingDecorator],
        );

        // Get instance without Instance cache/weakReference
        final instance = ddi.getInstance<TestService>();
        final service1 = instance.get();
        final service2 = instance.get();
        final service3 = instance.get();

        // All should be the same instance (from ApplicationScope)
        expect(service1, same(service2));
        expect(service2, same(service3));

        // Decorators are applied only during creation, not on each get
        expect(decoratorCallCount, equals(1));
      });
    });

    group('Dependent scope', () {
      test(
          'Dependent without Instance cache should call interceptor.onGet every time',
          () {
        ddi.singleton<TrackingInterceptor>(TrackingInterceptor.new);
        ddi.dependent<TestService>(
          TestService.new,
          interceptors: {TrackingInterceptor},
        );

        final instance = ddi.getInstance<TestService>();
        final service1 = instance.get();
        final service2 = instance.get();
        final service3 = instance.get();

        // Should create new instances
        expect(service1, isNot(same(service2)));
        expect(service2, isNot(same(service3)));

        final interceptor = ddi.get<TrackingInterceptor>();
        // Dependent creates new instances, so interceptor.onGet should be called every time
        expect(interceptor.getCallCount, equals(3));
        expect(interceptor.createCallCount, equals(3)); // Created 3 times
      });

      test(
          'Dependent with Instance cache should call interceptor.onGet only once',
          () {
        ddi.singleton<TrackingInterceptor>(TrackingInterceptor.new);
        ddi.dependent<TestService>(
          TestService.new,
          interceptors: {TrackingInterceptor},
        );

        final instance = ddi.getInstance<TestService>(cache: true);
        final service1 = instance.get();
        final service2 = instance.get();
        final service3 = instance.get();

        // Should cache the instance
        expect(service1, same(service2));
        expect(service2, same(service3));

        final interceptor = ddi.get<TrackingInterceptor>();
        // With Instance.cache = true, interceptor.onGet should be called only once
        expect(interceptor.getCallCount, equals(1));
        expect(interceptor.createCallCount, equals(1)); // Only created once
      });
    });
  });
}
