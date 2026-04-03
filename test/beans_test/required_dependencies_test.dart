import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/b.dart';
import '../clazz_samples/c.dart';

class _AsyncRequiresProbe {
  const _AsyncRequiresProbe();
}

class _RequiresReadyStateProbe {
  const _RequiresReadyStateProbe(this.dependencyWasReadyWhenCreated);

  final bool dependencyWasReadyWhenCreated;
}

class _AsyncDependencyProbe {
  const _AsyncDependencyProbe();
}

void main() {
  group('DDI required Dependencies Tests', () {
    tearDown(() {
      ddi.destroyByType<A>();
      ddi.destroyByType<B>();
      ddi.destroyByType<C>();
    });

    tearDownAll(() {
      expect(ddi.isEmpty, true);
    });

    group('Singleton Factory with Required Dependencies', () {
      test(
          'Should throw MissingDependenciesException when required dependency is not registered',
          () {
        expect(
          () => ddi.register<A>(
            factory: SingletonFactory(
              builder: A.new.builder,
              requires: {B},
            ),
          ),
          throwsA(isA<MissingDependenciesException>()),
        );

        expect(ddi.isRegistered<A>(), false);
      });

      test('Should succeed when all required dependencies are registered', () {
        ddi.singleton<C>(C.new);
        ddi.singleton<B>(() => B(ddi()));

        ddi.register<A>(
          factory: SingletonFactory(
            builder: A.new.builder,
            requires: {B},
          ),
        );

        expect(ddi.isRegistered<A>(), true);
        final instance = ddi.get<A>();
        expect(instance, isA<A>());
        expect(instance.b, isA<B>());

        ddi.destroy<A>();
        ddi.destroy<B>();
        ddi.destroy<C>();

        expect(ddi.isRegistered<A>(), false);
        expect(ddi.isRegistered<B>(), false);
        expect(ddi.isRegistered<C>(), false);
      });

      test('Should validate multiple required dependencies', () {
        ddi.singleton<C>(C.new);
        ddi.singleton<B>(() => B(ddi()));

        ddi.register<A>(
          factory: SingletonFactory(
            builder: A.new.builder,
            requires: {B, C},
          ),
        );

        expect(ddi.isRegistered<A>(), true);
        final instance = ddi.get<A>();
        expect(instance, isA<A>());

        ddi.destroy<A>();
        ddi.destroy<B>();
        ddi.destroy<C>();

        expect(ddi.isRegistered<A>(), false);
      });

      test('Should throw when one of multiple required dependencies is missing',
          () {
        ddi.singleton<C>(C.new);

        expect(
          () => ddi.register<A>(
            factory: SingletonFactory(
              builder: A.new.builder,
              requires: {B, C},
            ),
          ),
          throwsA(isA<MissingDependenciesException>()),
        );

        expect(ddi.isRegistered<A>(), false);
        ddi.destroy<C>();
      });

      test('Should work with qualifiers as required dependencies', () {
        ddi.singleton<C>(C.new, qualifier: 'cQualifier');
        ddi.singleton<B>(() => B(ddi.get<C>(qualifier: 'cQualifier')),
            qualifier: 'bQualifier');

        ddi.singleton<A>(
          () => A(
            ddi.get<B>(qualifier: 'bQualifier'),
          ),
          requires: {'bQualifier'},
        );

        expect(ddi.isRegistered<A>(), true);
        final instance = ddi.get<A>();
        expect(instance, isA<A>());

        ddi.destroy<A>();
        ddi.destroy(qualifier: 'bQualifier');
        ddi.destroy(qualifier: 'cQualifier');

        expect(ddi.isRegistered<A>(), false);
        expect(ddi.isRegistered(qualifier: 'bQualifier'), false);
        expect(ddi.isRegistered(qualifier: 'cQualifier'), false);
      });
    });

    group('Application Factory with required Dependencies', () {
      test(
          'Should throw MissingDependenciesException when required dependency is not registered',
          () {
        ddi.register<A>(
          factory: ApplicationFactory(
            builder: A.new.builder,
            requires: {B},
          ),
        );

        expect(
          () => ddi.get<A>(),
          throwsA(isA<MissingDependenciesException>()),
        );

        expect(ddi.isRegistered<A>(), true);
        expect(ddi.isReady<A>(), false);

        ddi.destroy<A>();
        expect(ddi.isRegistered<A>(), false);
      });

      test('Should succeed when all required dependencies are registered', () {
        ddi.singleton<C>(C.new);
        ddi.singleton<B>(() => B(ddi()));

        ddi.register<A>(
          factory: ApplicationFactory(
            builder: A.new.builder,
            requires: {B},
          ),
        );

        expect(ddi.isRegistered<A>(), true);
        final instance = ddi.get<A>();
        expect(instance, isA<A>());
        expect(instance.b, isA<B>());

        ddi.destroy<A>();
        ddi.destroy<B>();
        ddi.destroy<C>();

        expect(ddi.isRegistered<A>(), false);
        expect(ddi.isRegistered<B>(), false);
        expect(ddi.isRegistered<C>(), false);
      });

      test('Should validate dependencies on first getWith call', () {
        ddi.singleton<C>(C.new);
        ddi.singleton<B>(() => B(ddi()));

        ddi.register<A>(
          factory: ApplicationFactory(
            builder: A.new.builder,
            requires: {B},
          ),
        );

        expect(ddi.isRegistered<A>(), true);
        // First call should validate and succeed
        final instance1 = ddi.get<A>();
        expect(instance1, isA<A>());

        // Second call should use cached instance
        final instance2 = ddi.get<A>();
        expect(instance1, same(instance2));

        ddi.destroy<A>();
        ddi.destroy<B>();
        ddi.destroy<C>();

        expect(ddi.isRegistered<A>(), false);
      });

      test('Should throw when dependency is missing on getWith', () {
        ddi.register<A>(
          factory: ApplicationFactory(
            builder: A.new.builder,
            requires: {B},
          ),
        );

        expect(ddi.isRegistered<A>(), true);
        expect(
          () => ddi.get<A>(),
          throwsA(isA<MissingDependenciesException>()),
        );

        ddi.destroy<A>();
        expect(ddi.isRegistered<A>(), false);
      });
    });

    group('Dependent Factory with required Dependencies', () {
      test(
          'Should throw MissingDependenciesException when required dependency is not registered',
          () {
        ddi.register<A>(
          factory: DependentFactory(
            builder: A.new.builder,
            requires: {B},
          ),
        );

        expect(ddi.isRegistered<A>(), true);
        expect(ddi.isReady<A>(), false);
        expect(
          () => ddi.get<A>(),
          throwsA(isA<MissingDependenciesException>()),
        );

        ddi.destroy<A>();
        expect(ddi.isRegistered<A>(), false);
      });

      test('Should succeed when all required dependencies are registered', () {
        ddi.singleton<C>(C.new);
        ddi.singleton<B>(() => B(ddi()));

        ddi.register<A>(
          factory: DependentFactory(
            builder: A.new.builder,
            requires: {B},
          ),
        );

        expect(ddi.isRegistered<A>(), true);
        final instance = ddi.get<A>();
        expect(instance, isA<A>());
        expect(instance.b, isA<B>());

        ddi.destroy<A>();
        ddi.destroy<B>();
        ddi.destroy<C>();

        expect(ddi.isRegistered<A>(), false);
        expect(ddi.isRegistered<B>(), false);
        expect(ddi.isRegistered<C>(), false);
      });

      test('Should validate dependencies on each getWith call', () {
        ddi.singleton<C>(C.new);
        ddi.singleton<B>(() => B(ddi()));

        ddi.register<A>(
          factory: DependentFactory(
            builder: A.new.builder,
            requires: {B},
          ),
        );

        expect(ddi.isRegistered<A>(), true);
        final instance1 = ddi.get<A>();
        final instance2 = ddi.get<A>();

        expect(instance1, isA<A>());
        expect(instance2, isA<A>());
        expect(instance1, isNot(same(instance2)));

        ddi.destroy<A>();
        ddi.destroy<B>();
        ddi.destroy<C>();

        expect(ddi.isRegistered<A>(), false);
      });
    });

    group('Object Factory with required Dependencies', () {
      test(
          'Should throw MissingDependenciesException when required dependency is not registered',
          () {
        expect(
          () => ddi.register<C>(
            factory: ObjectFactory(
              instance: C(),
              requires: {B},
            ),
          ),
          throwsA(isA<MissingDependenciesException>()),
        );

        expect(ddi.isRegistered<C>(), false);
      });

      test('Should succeed when all required dependencies are registered', () {
        ddi.singleton<C>(C.new);
        ddi.singleton<B>(() => B(ddi()));

        ddi.register<A>(
          factory: ObjectFactory(
            instance: A(ddi.get<B>()),
            requires: {B},
          ),
        );

        expect(ddi.isRegistered<A>(), true);
        final instance = ddi.get<A>();
        expect(instance, isA<A>());
        expect(instance.b, isA<B>());

        ddi.destroy<A>();
        ddi.destroy<B>();
        ddi.destroy<C>();

        expect(ddi.isRegistered<A>(), false);
        expect(ddi.isRegistered<B>(), false);
        expect(ddi.isRegistered<C>(), false);
      });
    });

    group('Required Dependencies with DDI.newInstance', () {
      test('Should validate dependencies against the correct DDI instance', () {
        final newDdi = DDI.newInstance();

        // Register in default instance
        ddi.singleton<C>(C.new);
        ddi.singleton<B>(() => B(ddi()));

        // Register in new instance
        newDdi.singleton<C>(C.new);
        newDdi.singleton<B>(() => B(newDdi()));

        // Register A in new instance with requires B
        newDdi.register<A>(
          factory: SingletonFactory(
            builder: A.new.builder,
            requires: {B},
          ),
        );

        // Should work with newDdi
        expect(newDdi.isRegistered<A>(), true);
        final instance = newDdi.get<A>();
        expect(instance, isA<A>());

        // Should not work with default ddi (B is not registered there for A)
        expect(ddi.isRegistered<A>(), false);
        expect(
          () => ddi.get<A>(),
          throwsA(isA<BeanNotFoundException>()),
        );

        newDdi.destroy<A>();
        newDdi.destroy<B>();
        newDdi.destroy<C>();

        expect(newDdi.isRegistered<A>(), false);
        expect(newDdi.isRegistered<B>(), false);
        expect(newDdi.isRegistered<C>(), false);
      });

      test('Should throw when dependency is in different DDI instance', () {
        final newDdi = DDI.newInstance();

        // Register B only in default instance
        ddi.singleton<C>(C.new);
        ddi.singleton<B>(() => B(ddi()));

        // Try to register A in new instance requiring B
        expect(
          () => newDdi.register<A>(
            factory: SingletonFactory(
              builder: A.new.builder,
              requires: {B},
            ),
          ),
          throwsA(isA<MissingDependenciesException>()),
        );

        expect(newDdi.isRegistered<A>(), false);
        ddi.destroy<B>();
        ddi.destroy<C>();
      });
    });

    group('Required Dependencies with Async', () {
      test(
          'ApplicationFactory getAsyncWith should validate missing required dependency before creating the bean',
          () async {
        ddi.register<_AsyncRequiresProbe>(
          factory: ApplicationFactory(
            builder: _AsyncRequiresProbe.new.builder,
            requires: {'missing-dependency'},
          ),
        );

        await expectLater(
          ddi.getAsync<_AsyncRequiresProbe>(),
          throwsA(isA<MissingDependenciesException>()),
        );

        ddi.destroy<_AsyncRequiresProbe>();
        expect(ddi.isRegistered<_AsyncRequiresProbe>(), false);
      });

      test(
          'DependentFactory getAsyncWith should await async required dependencies before creating the bean',
          () async {
        var dependencyReady = false;

        ddi.application<_AsyncDependencyProbe>(
          () async {
            await Future<void>.delayed(const Duration(milliseconds: 1));
            dependencyReady = true;
            return const _AsyncDependencyProbe();
          },
          qualifier: 'async-dependency',
        );

        ddi.register<_RequiresReadyStateProbe>(
          factory: DependentFactory(
            builder: (() => _RequiresReadyStateProbe(dependencyReady)).builder,
            requires: {'async-dependency'},
          ),
        );

        final instance = await ddi.getAsync<_RequiresReadyStateProbe>();
        expect(instance.dependencyWasReadyWhenCreated, isTrue);

        ddi.destroy<_RequiresReadyStateProbe>();
        ddi.destroy<_AsyncDependencyProbe>(qualifier: 'async-dependency');
      });

      test('Should wait for async dependencies in getAsyncWith', () async {
        ddi.singleton<C>(C.new);
        ddi.singleton<B>(() async => B(ddi()));

        ddi.register<A>(
          factory: ApplicationFactory(
            builder: A.new.builder,
            requires: {B},
          ),
        );

        expect(ddi.isRegistered<A>(), true);
        final instance = await ddi.getAsync<A>();
        expect(instance, isA<A>());
        expect(instance.b, isA<B>());

        ddi.destroy<A>();
        ddi.destroy<B>();
        ddi.destroy<C>();

        expect(ddi.isRegistered<A>(), false);
        expect(ddi.isRegistered<B>(), false);
        expect(ddi.isRegistered<C>(), false);
      });

      test('Should throw when async dependency is not ready in getWith', () {
        ddi.singleton<C>(C.new);
        ddi.singleton<B>(() async => B(ddi()));

        ddi.register<A>(
          factory: ApplicationFactory(
            builder: A.new.builder,
            requires: {B},
          ),
        );

        expect(ddi.isRegistered<A>(), true);
        expect(
          () => ddi.get<A>(),
          throwsA(isA<MissingDependenciesException>()),
        );

        ddi.destroy<A>();
        ddi.destroy<B>();
        ddi.destroy<C>();

        expect(ddi.isRegistered<A>(), false);
      });
    });

    group('Required Dependencies with Empty Set', () {
      test('Should work with empty requires set', () {
        ddi.register<C>(
          factory: SingletonFactory(
            builder: C.new.builder,
            requires: {},
          ),
        );

        expect(ddi.isRegistered<C>(), true);
        final instance = ddi.get<C>();
        expect(instance, isA<C>());

        ddi.destroy<C>();
        expect(ddi.isRegistered<C>(), false);
      });

      test('Should work with null requires', () {
        ddi.register<C>(
          factory: SingletonFactory(
            builder: C.new.builder,
          ),
        );

        expect(ddi.isRegistered<C>(), true);
        final instance = ddi.get<C>();
        expect(instance, isA<C>());

        ddi.destroy<C>();
        expect(ddi.isRegistered<C>(), false);
      });
    });
  });
}
