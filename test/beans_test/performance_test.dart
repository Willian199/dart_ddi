import 'dart:async';
import 'package:test/test.dart';
import 'package:dart_ddi/dart_ddi.dart';

/// Simple bean used for performance tests.
class ExampleService {}

/// Lightweight interceptor used to simulate lifecycle hooks.
class ExampleInterceptor implements DDIInterceptor {
  int onCreateCalled = 0;
  int onGetCalled = 0;

  @override
  Object onCreate(Object instance) {
    onCreateCalled++;
    return instance;
  }

  @override
  Object onGet(Object instance) {
    onGetCalled++;
    return instance;
  }

  @override
  void onDispose(Object? instance) {}

  @override
  FutureOr<void> onDestroy(Object? instance) {}
}

void main() {
  const interaction = 10000000;
  group('Beans Performance Test', () {
    test('Application Scope should be efficient', () {
      final sw = Stopwatch()..start();

      ddi.application(ExampleInterceptor.new);
      ddi.application(ExampleService.new, interceptors: {ExampleInterceptor});

      // Simulate 10,000,000 dependency resolutions
      for (var i = 0; i < interaction; i++) {
        ddi.get<ExampleService>();
      }

      sw.stop();

      final interceptor = ddi.get<ExampleInterceptor>();
      // Validation
      expect(
        interceptor.onCreateCalled,
        1,
        reason: 'Creation should occur only once.',
      );
      expect(
        interceptor.onGetCalled,
        equals(interaction),
        reason: 'Interceptor should run on each get.',
      );

      // Sanity check for performance
      expect(
        sw.elapsedMilliseconds,
        lessThan(1500),
        reason:
            'Should resolve 10,000,000 instances in under 2000ms on a modern CPU.',
      );

      ddi.destroy<ExampleService>();
      ddi.destroy<ExampleInterceptor>();

      expect(
        () => ddi.get<ExampleService>(),
        throwsA(isA<BeanNotFoundException>()),
      );
    });

    test('Singleton Scope should be efficient', () {
      final sw = Stopwatch()..start();

      ddi.singleton(ExampleInterceptor.new);
      ddi.singleton(ExampleService.new, interceptors: {ExampleInterceptor});

      // Simulate 10,000,000 dependency resolutions
      for (var i = 0; i < interaction; i++) {
        ddi.get<ExampleService>();
      }

      sw.stop();

      final interceptor = ddi.get<ExampleInterceptor>();
      // Validation
      expect(
        interceptor.onCreateCalled,
        1,
        reason: 'Creation should occur only once.',
      );
      expect(
        interceptor.onGetCalled,
        equals(interaction),
        reason: 'Interceptor should run on each get.',
      );

      // Sanity check for performance
      expect(
        sw.elapsedMilliseconds,
        lessThan(1500),
        reason:
            'Should resolve 10,000,000 instances in under 2000ms on a modern CPU.',
      );

      ddi.destroy<ExampleService>();
      ddi.destroy<ExampleInterceptor>();

      expect(
        () => ddi.get<ExampleService>(),
        throwsA(isA<BeanNotFoundException>()),
      );
    });

    test('Object Scope should be efficient', () {
      final sw = Stopwatch()..start();

      ddi.object(ExampleInterceptor());
      ddi.object(ExampleService(), interceptors: {ExampleInterceptor});

      // Simulate 10,000,000 dependency resolutions
      for (var i = 0; i < interaction; i++) {
        ddi.get<ExampleService>();
      }

      sw.stop();

      final interceptor = ddi.get<ExampleInterceptor>();
      // Validation
      expect(
        interceptor.onCreateCalled,
        1,
        reason: 'Creation should occur only once.',
      );
      expect(
        interceptor.onGetCalled,
        equals(interaction),
        reason: 'Interceptor should run on each get.',
      );

      // Sanity check for performance
      expect(
        sw.elapsedMilliseconds,
        lessThan(1500),
        reason:
            'Should resolve 10,000,000 instances in under 2000ms on a modern CPU.',
      );

      ddi.destroy<ExampleService>();
      ddi.destroy<ExampleInterceptor>();

      expect(
        () => ddi.get<ExampleService>(),
        throwsA(isA<BeanNotFoundException>()),
      );
    });

    test('Dependent Scope should run without major problems', () {
      final sw = Stopwatch()..start();

      ddi.dependent(ExampleInterceptor.new);
      ddi.dependent(ExampleService.new, interceptors: {ExampleInterceptor});

      // Simulate 10,000,000 dependency resolutions
      for (var i = 0; i < interaction; i++) {
        ddi.get<ExampleService>();
      }

      sw.stop();

      // The Dependent scope is a lot slower due to instance creation on each get and Circular Dependecy Injection validation.
      expect(
        sw.elapsedMilliseconds,
        lessThan(15000),
        reason:
            'Should resolve 10,000,000 instances in under 10000ms on a modern CPU.',
      );

      ddi.destroy<ExampleService>();
      ddi.destroy<ExampleInterceptor>();

      expect(
        () => ddi.get<ExampleService>(),
        throwsA(isA<BeanNotFoundException>()),
      );
    });

    test('Should be fast to add dynamic interceptor', () {
      final sw = Stopwatch()..start();

      ddi.application(ExampleService.new);

      ddi.get<ExampleService>();

      for (var i = 0; i < 100000; i++) {
        ddi.addInterceptor<ExampleService>({Object()});
      }

      sw.stop();

      expect(
        sw.elapsedMilliseconds,
        lessThan(100),
        reason: 'Adding interceptors should be extremely fast.',
      );

      ddi.destroy<ExampleService>();

      expect(ddi.isRegistered<ExampleService>(), false);

      expect(
        () => ddi.get<ExampleService>(),
        throwsA(isA<BeanNotFoundException>()),
      );
    });

    test('Should be fast to add dynamic interceptor on DependentScope', () {
      final sw = Stopwatch()..start();

      ddi.dependent(ExampleService.new);

      ddi.get<ExampleService>();

      for (var i = 0; i < 100000; i++) {
        ddi.addInterceptor<ExampleService>({Object()});
      }

      sw.stop();

      expect(
        sw.elapsedMilliseconds,
        lessThan(100),
        reason: 'Adding interceptors should be extremely fast.',
      );

      ddi.destroy<ExampleService>();

      expect(ddi.isRegistered<ExampleService>(), false);

      expect(
        () => ddi.get<ExampleService>(),
        throwsA(isA<BeanNotFoundException>()),
      );
    });

    test('Should be fast to add dynamic decorators on ApplicationScope', () {
      final sw = Stopwatch()..start();

      ddi.application(() => 'teste', qualifier: 'performance_string_decorated');

      expect(ddi.get(qualifier: 'performance_string_decorated'), 'teste');

      for (var i = 0; i < 100000; i++) {
        ddi.addDecorator(
          [(String instance) => instance.toUpperCase()],
          qualifier: 'performance_string_decorated',
        );
      }

      sw.stop();

      expect(
        sw.elapsedMilliseconds,
        lessThan(100),
        reason: 'Adding interceptors should be extremely fast.',
      );

      expect(ddi.get(qualifier: 'performance_string_decorated'), 'TESTE');

      ddi.destroy(qualifier: 'performance_string_decorated');

      expect(
          ddi.isRegistered(qualifier: 'performance_string_decorated'), false);

      expect(
        () => ddi.get(qualifier: 'performance_string_decorated'),
        throwsA(isA<BeanNotFoundException>()),
      );
    });

    test('Should be fast to add dynamic decorators on SingletonScope', () {
      final sw = Stopwatch()..start();

      ddi.singleton(() => 'teste', qualifier: 'performance_string_decorated');

      expect(ddi.get(qualifier: 'performance_string_decorated'), 'teste');

      for (var i = 0; i < 100000; i++) {
        ddi.addDecorator(
          [(String instance) => instance.toUpperCase()],
          qualifier: 'performance_string_decorated',
        );
      }

      sw.stop();

      expect(
        sw.elapsedMilliseconds,
        lessThan(100),
        reason: 'Adding interceptors should be extremely fast.',
      );

      expect(ddi.get(qualifier: 'performance_string_decorated'), 'TESTE');

      ddi.destroy(qualifier: 'performance_string_decorated');

      expect(
          ddi.isRegistered(qualifier: 'performance_string_decorated'), false);

      expect(
        () => ddi.get(qualifier: 'performance_string_decorated'),
        throwsA(isA<BeanNotFoundException>()),
      );
    });

    test('Should be fast to add dynamic decorators on DependentScope', () {
      final sw = Stopwatch()..start();

      ddi.dependent(() => 'teste', qualifier: 'performance_string_decorated');

      expect(ddi.get(qualifier: 'performance_string_decorated'), 'teste');

      for (var i = 0; i < 100000; i++) {
        ddi.addDecorator(
          [(String instance) => instance.toUpperCase()],
          qualifier: 'performance_string_decorated',
        );
      }

      sw.stop();

      expect(
        sw.elapsedMilliseconds,
        lessThan(100),
        reason: 'Adding interceptors should be extremely fast.',
      );

      expect(ddi.get(qualifier: 'performance_string_decorated'), 'TESTE');

      ddi.destroy(qualifier: 'performance_string_decorated');

      expect(
          ddi.isRegistered(qualifier: 'performance_string_decorated'), false);

      expect(
        () => ddi.get(qualifier: 'performance_string_decorated'),
        throwsA(isA<BeanNotFoundException>()),
      );
    });
  });
}
