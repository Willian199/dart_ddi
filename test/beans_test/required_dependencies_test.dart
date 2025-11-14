import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/b.dart';
import '../clazz_samples/c.dart';

void main() {
  group('DDI Required Dependencies Tests', () {
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
              required: {B},
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
            required: {B},
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
            required: {B, C},
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
              required: {B, C},
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
          required: {'bQualifier'},
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

    group('Application Factory with Required Dependencies', () {
      test(
          'Should throw MissingDependenciesException when required dependency is not registered',
          () {
        ddi.register<A>(
          factory: ApplicationFactory(
            builder: A.new.builder,
            required: {B},
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
            required: {B},
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
            required: {B},
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
            required: {B},
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

    group('Dependent Factory with Required Dependencies', () {
      test(
          'Should throw MissingDependenciesException when required dependency is not registered',
          () {
        ddi.register<A>(
          factory: DependentFactory(
            builder: A.new.builder,
            required: {B},
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
            required: {B},
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
            required: {B},
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

    group('Object Factory with Required Dependencies', () {
      test(
          'Should throw MissingDependenciesException when required dependency is not registered',
          () {
        expect(
          () => ddi.register<C>(
            factory: ObjectFactory(
              instance: C(),
              required: {B},
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
            required: {B},
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

        // Register A in new instance with required B
        newDdi.register<A>(
          factory: SingletonFactory(
            builder: A.new.builder,
            required: {B},
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
              required: {B},
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
      test('Should wait for async dependencies in getAsyncWith', () async {
        ddi.singleton<C>(C.new);
        ddi.singleton<B>(() async => B(ddi()));

        ddi.register<A>(
          factory: ApplicationFactory(
            builder: A.new.builder,
            required: {B},
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
            required: {B},
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
      test('Should work with empty required set', () {
        ddi.register<C>(
          factory: SingletonFactory(
            builder: C.new.builder,
            required: {},
          ),
        );

        expect(ddi.isRegistered<C>(), true);
        final instance = ddi.get<C>();
        expect(instance, isA<C>());

        ddi.destroy<C>();
        expect(ddi.isRegistered<C>(), false);
      });

      test('Should work with null required', () {
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
