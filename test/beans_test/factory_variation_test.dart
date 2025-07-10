import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/b.dart';
import '../clazz_samples/c.dart';
import '../clazz_samples/multi_inject.dart';

typedef RecordInject = (A a, B b, C c);

void main() {
  group('DDI Factory Variation Tests', () {
    void registerBeans() {
      MultiInject.new.builder.asDependent();
      B.new.builder.asApplication();
      C.new.builder.asApplication();
      A.new.builder.asSingleton();
    }

    void removeBeans() {
      ddi.destroy<MultiInject>();
      ddi.destroy<A>();
      ddi.destroy<B>();
      ddi.destroy<C>();
    }

    void disposeBeans() {
      ddi.dispose<MultiInject>();
      ddi.dispose<A>();
      ddi.dispose<B>();
      ddi.dispose<C>();
    }

    void expectRegistered() {
      expect(ddi.isRegistered<MultiInject>(), true);
      expect(ddi.isRegistered<A>(), true);
      expect(ddi.isRegistered<B>(), true);
      expect(ddi.isRegistered<C>(), true);
    }

    test('Register and retrieve all Factories', () {
      registerBeans();

      expectRegistered();

      final instance1 = ddi.get<MultiInject>();
      final instance2 = ddi.get<A>();

      expect(instance1.a, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      disposeBeans();
      removeBeans();
    });

    test('Register and retrieve all Factories using List', () {
      registerBeans();

      expectRegistered();

      final instance1 = ddi.getWith<MultiInject, List<Object>>(
          parameter: [ddi.get<A>(), ddi.get<B>(), ddi.get<C>()]);
      final instance2 = ddi.get<A>();

      expect(instance1.a, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      disposeBeans();
      removeBeans();
    });

    test('Register and retrieve all Factories using Optional List', () {
      registerBeans();

      expectRegistered();

      final instance1 = ddi.getOptionalWith<MultiInject, List<Object>>(
          parameter: [
            ddi.getOptional<A>()!,
            ddi.getOptional<B>()!,
            ddi.getOptional<C>()!
          ])!;
      final instance2 = ddi.get<A>();

      expect(instance1.a, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      disposeBeans();
      removeBeans();
    });

    test('Register and retrieve all Factories using Map', () async {
      (B b) async {
        return A(b);
      }.builder.asApplication();

      B.new.builder.asApplication();
      C.new.builder.asDependent();

      ddi.register(
        factory: DependentFactory(
          builder: CustomBuilder<MultiInject>(
              producer: ({required A a, required B b, required C? c}) {
                return MultiInject(a, b, c ?? C());
              },
              parametersType: [],
              returnType: MultiInject,
              isFuture: false),
        ),
      );

      expectRegistered();

      final instance1 = ddi.getWith<MultiInject, Map<Symbol, dynamic>>(
        parameter: {
          #a: await ddi.getOptionalAsync<A>(),
          #b: ddi.getOptional<B>()!,
          #c: ddi.getOptional<C>()!,
        },
      );

      final instance2 = ddi.get<A>();

      expect(instance1.a, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      disposeBeans();
      removeBeans();
    });

    test('Register Factories and get using Map', () {
      C.new.builder.asApplication();
      B.new.builder.asApplication();

      ddi.register(
        factory: DependentFactory(
          builder: CustomBuilder<MultiInject>(
              producer: ({required B b, required C c}) {
                return MultiInject(A(b), b, c);
              },
              parametersType: [],
              returnType: MultiInject,
              isFuture: false),
        ),
      );

      final instance1 =
          ddi.getWith<MultiInject, Map<Symbol, dynamic>>(parameter: {
        #b: ddi.getOptional<B>()!,
        #c: ddi.getOptional<C>()!,
      });

      final instance2 = ddi.get<B>();

      expect(instance1.b, same(instance2));
      expect(instance1.b.c, same(instance2.c));
      expect(instance1.b.c.value, same(instance2.c.value));

      removeBeans();
    });

    test('Register and retrieve Factories with Wrong Map type', () {
      C.new.builder.asApplication();
      B.new.builder.asApplication();
      A.new.builder.asSingleton();

      ddi.register(
        factory: DependentFactory(
          builder: CustomBuilder<MultiInject>(
            producer: ({required A a, required B b, required C c}) {
              return MultiInject(a, b, c);
            },
            parametersType: [],
            returnType: MultiInject,
            isFuture: false,
          ),
        ),
      );

      expectRegistered();

      expect(
          () => ddi.getWith<MultiInject, Map<dynamic, dynamic>>(
                parameter: {
                  A: ddi.get<A>(),
                  B: ddi.get<B>(),
                  C: ddi.get<C>(),
                },
              ),
          throwsA(isA<AssertionError>()));

      removeBeans();
    });

    test('Register a Future and retrieve all Factories using Map', () async {
      C.new.builder.asApplication();
      B.new.builder.asApplication();
      A.new.builder.asSingleton();

      ddi.register<MultiInject>(
        factory: DependentFactory(
          builder: CustomBuilder(
            producer: ({required A a, required B b, required C c}) async {
              await Future.delayed(const Duration(milliseconds: 10));
              return MultiInject(a, b, c);
            },
            parametersType: [],
            returnType: MultiInject,
            isFuture: true,
          ),
        ),
      );

      expectRegistered();

      final instance1 =
          await ddi.getAsyncWith<MultiInject, Map<Symbol, dynamic>>(
        parameter: {
          #a: ddi.get<A>(),
          #b: ddi.get<B>(),
          #c: ddi.get<C>(),
        },
      );

      final instance2 = ddi.get<A>();

      expect(instance1.a, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      disposeBeans();
      removeBeans();
    });

    test('Register a Future and retrieve all Factories using List', () async {
      C.new.builder.asApplication();
      B.new.builder.asApplication();
      A.new.builder.asSingleton();

      ddi.register<MultiInject>(
        factory: DependentFactory(
          builder: CustomBuilder(
            producer: (A a, B b, C c) async {
              await Future.delayed(const Duration(milliseconds: 10));
              return MultiInject(a, b, c);
            },
            parametersType: [],
            returnType: MultiInject,
            isFuture: true,
          ),
        ),
      );

      expectRegistered();

      final instance1 =
          await ddi.getOptionalAsyncWith<MultiInject, List<Object>>(
        parameter: [
          ddi.get<A>(),
          ddi.get<B>(),
          ddi.get<C>(),
        ],
      );

      final instance2 = ddi.get<A>();

      expect(instance1, isNotNull);
      expect(instance1!.a, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      disposeBeans();
      removeBeans();
    });

    test('Register a Future and retrieve all Factories using a Record',
        () async {
      C.new.builder.asApplication();
      B.new.builder.asApplication();
      A.new.builder.asSingleton();

      ddi.register<MultiInject>(
        factory: DependentFactory(
          builder: CustomBuilder(
            producer: (RecordInject record) async {
              await Future.delayed(const Duration(milliseconds: 10));
              return MultiInject(record.$1, record.$2, record.$3);
            },
            parametersType: [],
            returnType: MultiInject,
            isFuture: true,
          ),
        ),
      );

      expectRegistered();

      final instance1 = await ddi.getAsyncWith<MultiInject, RecordInject>(
        parameter: (
          ddi.get<A>(),
          ddi.get<B>(),
          ddi.get<C>(),
        ),
      );

      final instance2 = ddi.get<A>();

      expect(instance1.a, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      disposeBeans();
      removeBeans();
    });
  });
}
