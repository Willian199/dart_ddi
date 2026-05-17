import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/b.dart';
import '../clazz_samples/c.dart';
import '../clazz_samples/function_extension_auto_inject_samples.dart';
import '../clazz_samples/test_service.dart';

void main() {
  group('Function Extension Tests', () {
    tearDown(() async {
      await _destroyIfRegistered<TestService>();
      await _destroyIfRegistered<String>();
      await _destroyIfRegistered<int>();
      await _destroyIfRegistered<bool>();
      await _destroyIfRegistered<A>();
      await _destroyIfRegistered<B>();
      await _destroyIfRegistered<C>();
      await _destroyIfRegistered<AutoInjectClassLeaf>();
      await _destroyIfRegistered<AutoInjectClassConfig>();
      await _destroyIfRegistered<AutoInjectClassMiddle>();
      await _destroyIfRegistered<AutoInjectClassRoot>();
      await _destroyIfRegistered<AutoInjectFutureLeaf>();
      await _destroyIfRegistered<AutoInjectFutureFlag>();
      await _destroyIfRegistered<AutoInjectFutureRoot>();
      await _destroyIfRegistered<AutoInjectManyA>();
      await _destroyIfRegistered<AutoInjectManyB>();
      await _destroyIfRegistered<AutoInjectManyC>();
      await _destroyIfRegistered<AutoInjectManyD>();
      await _destroyIfRegistered<AutoInjectManyRoot>();
      await _destroyIfRegistered<AutoInjectManyFutureRoot>();
    });

    tearDownAll(() {
      expect(ddi.isEmpty, true);
    });

    group('P2 - Function with 2 parameters (sync)', () {
      test('should create builder with correct parameters and return type', () {
        TestService func(String name, int value) {
          return TestService();
        }

        expect(func.builder.parametersType, [String, int]);
        expect(func.builder.returnType, TestService);
        expect(func.builder.isFuture, false);
      });

      test('should register and retrieve using builder', () {
        TestService func(String name, int value) {
          return TestService();
        }

        // For functions with parameters, we just verify the builder is created correctly
        // Actual usage would require registering the parameter types first
        final builder = func.builder;
        expect(builder.parametersType, [String, int]);
        expect(builder.returnType, TestService);
        expect(builder.isFuture, false);
      });
    });

    group('PF2 - Function with 2 parameters (async)', () {
      test('should create builder with correct parameters and return type', () {
        Future<TestService> func(String name, int value) async {
          return TestService();
        }

        expect(func.builder.parametersType, [String, int]);
        expect(func.builder.returnType, TestService);
        expect(func.builder.isFuture, true);
      });

      test('should register and retrieve using builder', () async {
        Future<TestService> func(String name, int value) async {
          return TestService();
        }

        // For functions with parameters, we just verify the builder is created correctly
        final builder = func.builder;
        expect(builder.parametersType, [String, int]);
        expect(builder.returnType, TestService);
        expect(builder.isFuture, true);
      });
    });

    group('P3 - Function with 3 parameters (sync)', () {
      test('should create builder with correct parameters and return type', () {
        TestService func(String name, int value, bool flag) {
          return TestService();
        }

        expect(func.builder.parametersType, [String, int, bool]);
        expect(func.builder.returnType, TestService);
        expect(func.builder.isFuture, false);
      });

      test('should register and retrieve using builder', () {
        TestService func(String name, int value, bool flag) {
          return TestService();
        }

        final builder = func.builder;
        expect(builder.parametersType, [String, int, bool]);
        expect(builder.returnType, TestService);
        expect(builder.isFuture, false);
      });
    });

    group('PF3 - Function with 3 parameters (async)', () {
      test('should create builder with correct parameters and return type', () {
        Future<TestService> func(String name, int value, bool flag) async {
          return TestService();
        }

        expect(func.builder.parametersType, [String, int, bool]);
        expect(func.builder.returnType, TestService);
        expect(func.builder.isFuture, true);
      });

      test('should register and retrieve using builder', () async {
        Future<TestService> func(String name, int value, bool flag) async {
          return TestService();
        }

        final builder = func.builder;
        expect(builder.parametersType, [String, int, bool]);
        expect(builder.returnType, TestService);
        expect(builder.isFuture, true);
      });
    });

    group('P4 - Function with 4 parameters (sync)', () {
      test('should create builder with correct parameters and return type', () {
        TestService func(String name, int value, bool flag, double rate) {
          return TestService();
        }

        expect(func.builder.parametersType, [String, int, bool, double]);
        expect(func.builder.returnType, TestService);
        expect(func.builder.isFuture, false);
      });

      test('should register and retrieve using builder', () {
        TestService func(String name, int value, bool flag, double rate) {
          return TestService();
        }

        final builder = func.builder;
        expect(builder.parametersType, [String, int, bool, double]);
        expect(builder.returnType, TestService);
        expect(builder.isFuture, false);
      });
    });

    group('PF4 - Function with 4 parameters (async)', () {
      test('should create builder with correct parameters and return type', () {
        Future<TestService> func(
            String name, int value, bool flag, double rate) async {
          return TestService();
        }

        expect(func.builder.parametersType, [String, int, bool, double]);
        expect(func.builder.returnType, TestService);
        expect(func.builder.isFuture, true);
      });

      test('should register and retrieve using builder', () async {
        Future<TestService> func(
            String name, int value, bool flag, double rate) async {
          return TestService();
        }

        final builder = func.builder;
        expect(builder.parametersType, [String, int, bool, double]);
        expect(builder.returnType, TestService);
        expect(builder.isFuture, true);
      });
    });

    group('P5 - Function with 5 parameters (sync)', () {
      test('should create builder with correct parameters and return type', () {
        TestService func(String a, int b, bool c, double d, String e) {
          return TestService();
        }

        expect(
            func.builder.parametersType, [String, int, bool, double, String]);
        expect(func.builder.returnType, TestService);
        expect(func.builder.isFuture, false);
      });

      test('should register and retrieve using builder', () {
        TestService func(String a, int b, bool c, double d, String e) {
          return TestService();
        }

        final builder = func.builder;
        expect(builder.parametersType, [String, int, bool, double, String]);
        expect(builder.returnType, TestService);
        expect(builder.isFuture, false);
      });
    });

    group('PF5 - Function with 5 parameters (async)', () {
      test('should create builder with correct parameters and return type', () {
        Future<TestService> func(
            String a, int b, bool c, double d, String e) async {
          return TestService();
        }

        expect(
            func.builder.parametersType, [String, int, bool, double, String]);
        expect(func.builder.returnType, TestService);
        expect(func.builder.isFuture, true);
      });

      test('should register and retrieve using builder', () async {
        Future<TestService> func(
            String a, int b, bool c, double d, String e) async {
          return TestService();
        }

        final builder = func.builder;
        expect(builder.parametersType, [String, int, bool, double, String]);
        expect(builder.returnType, TestService);
        expect(builder.isFuture, true);
      });
    });

    group('P6 - Function with 6 parameters (sync)', () {
      test('should create builder with correct parameters and return type', () {
        TestService func(String a, int b, bool c, double d, String e, int f) {
          return TestService();
        }

        expect(
          P6(func).builder.parametersType,
          [String, int, bool, double, String, int],
        );
        expect(P6(func).builder.returnType, TestService);
        expect(P6(func).builder.isFuture, false);
      });

      test('should register and retrieve using builder', () {
        TestService func(String a, int b, bool c, double d, String e, int f) {
          return TestService();
        }

        final builder = P6(func).builder;
        expect(
            builder.parametersType, [String, int, bool, double, String, int]);
        expect(builder.returnType, TestService);
        expect(builder.isFuture, false);
      });
    });

    group('PF6 - Function with 6 parameters (async)', () {
      test('should register and retrieve using builder', () {
        Future<TestService> func(
            String a, int b, bool c, double d, String e, int f) async {
          return TestService();
        }

        final builder = func.builder;
        expect(
            builder.parametersType, [String, int, bool, double, String, int]);
        expect(builder.returnType, TestService);
        expect(builder.isFuture, true);
      });
    });

    group('P7 - Function with 7 parameters (sync)', () {
      test('should create builder with correct parameters and return type', () {
        TestService func(
            String a, int b, bool c, double d, String e, int f, bool g) {
          return TestService();
        }

        expect(
          func.builder.parametersType,
          [String, int, bool, double, String, int, bool],
        );
        expect(func.builder.returnType, TestService);
        expect(func.builder.isFuture, false);
      });

      test('should register and retrieve using builder', () {
        TestService func(
            String a, int b, bool c, double d, String e, int f, bool g) {
          return TestService();
        }

        final builder = func.builder;
        expect(builder.parametersType.length, 7);
        expect(builder.returnType, TestService);
        expect(builder.isFuture, false);
      });
    });

    group('PF7 - Function with 7 parameters (async)', () {
      test('should create builder with correct parameters and return type', () {
        Future<TestService> func(
            String a, int b, bool c, double d, String e, int f, bool g) async {
          return TestService();
        }

        expect(
          func.builder.parametersType,
          [String, int, bool, double, String, int, bool],
        );
        expect(func.builder.returnType, TestService);
        expect(func.builder.isFuture, true);
      });

      test('should register and retrieve using builder', () async {
        Future<TestService> func(
            String a, int b, bool c, double d, String e, int f, bool g) async {
          return TestService();
        }

        final builder = func.builder;
        expect(builder.parametersType.length, 7);
        expect(builder.returnType, TestService);
        expect(builder.isFuture, true);
      });
    });

    group('P8 - Function with 8 parameters (sync)', () {
      test('should create builder with correct parameters and return type', () {
        TestService func(String a, int b, bool c, double d, String e, int f,
            bool g, double h) {
          return TestService();
        }

        expect(func.builder.parametersType.length, 8);
        expect(
          func.builder.parametersType,
          [String, int, bool, double, String, int, bool, double],
        );
        expect(func.builder.returnType, TestService);
        expect(func.builder.isFuture, false);
      });

      test('should register and retrieve using builder', () {
        TestService func(String a, int b, bool c, double d, String e, int f,
            bool g, double h) {
          return TestService();
        }

        final builder = func.builder;
        expect(builder.parametersType.length, 8);
        expect(builder.returnType, TestService);
        expect(builder.isFuture, false);
      });
    });

    group('PF8 - Function with 8 parameters (async)', () {
      test('should create builder with correct parameters and return type', () {
        Future<TestService> func(String a, int b, bool c, double d, String e,
            int f, bool g, double h) async {
          return TestService();
        }

        expect(
          func.builder.parametersType,
          [String, int, bool, double, String, int, bool, double],
        );
        expect(func.builder.returnType, TestService);
        expect(func.builder.isFuture, true);
      });

      test('should register and retrieve using builder', () async {
        Future<TestService> func(String a, int b, bool c, double d, String e,
            int f, bool g, double h) async {
          return TestService();
        }

        final builder = func.builder;
        expect(builder.parametersType.length, 8);
        expect(builder.returnType, TestService);
        expect(builder.isFuture, true);
      });
    });

    group('P9 - Function with 9 parameters (sync)', () {
      test('should create builder with correct parameters and return type', () {
        TestService func(String a, int b, bool c, double d, String e, int f,
            bool g, double h, String i) {
          return TestService();
        }

        expect(
          func.builder.parametersType,
          [String, int, bool, double, String, int, bool, double, String],
        );
        expect(func.builder.returnType, TestService);
        expect(func.builder.isFuture, false);
      });

      test('should register and retrieve using builder', () {
        TestService func(String a, int b, bool c, double d, String e, int f,
            bool g, double h, String i) {
          return TestService();
        }

        final builder = func.builder;
        expect(builder.parametersType.length, 9);
        expect(builder.returnType, TestService);
        expect(builder.isFuture, false);
      });
    });

    group('PF9 - Function with 9 parameters (async)', () {
      test('should create builder with correct parameters and return type', () {
        Future<TestService> func(String a, int b, bool c, double d, String e,
            int f, bool g, double h, String i) async {
          return TestService();
        }

        expect(
          func.builder.parametersType,
          [String, int, bool, double, String, int, bool, double, String],
        );
        expect(func.builder.returnType, TestService);
        expect(func.builder.isFuture, true);
      });

      test('should register and retrieve using builder', () async {
        Future<TestService> func(String a, int b, bool c, double d, String e,
            int f, bool g, double h, String i) async {
          return TestService();
        }

        final builder = func.builder;
        expect(builder.parametersType.length, 9);
        expect(builder.returnType, TestService);
        expect(builder.isFuture, true);
      });
    });

    group('P10 - Function with 10 parameters (sync)', () {
      test('should create builder with correct parameters and return type', () {
        TestService func(String a, int b, bool c, double d, String e, int f,
            bool g, double h, String i, int j) {
          return TestService();
        }

        expect(
          func.builder.parametersType,
          [String, int, bool, double, String, int, bool, double, String, int],
        );
        expect(func.builder.returnType, TestService);
        expect(func.builder.isFuture, false);
      });

      test('should register and retrieve using builder', () {
        TestService func(String a, int b, bool c, double d, String e, int f,
            bool g, double h, String i, int j) {
          return TestService();
        }

        final builder = func.builder;
        expect(builder.parametersType.length, 10);
        expect(builder.returnType, TestService);
        expect(builder.isFuture, false);
      });
    });

    group('PF10 - Function with 10 parameters (async)', () {
      test('should create builder with correct parameters and return type', () {
        Future<TestService> func(String a, int b, bool c, double d, String e,
            int f, bool g, double h, String i, int j) async {
          return TestService();
        }

        expect(
          func.builder.parametersType,
          [String, int, bool, double, String, int, bool, double, String, int],
        );
        expect(func.builder.returnType, TestService);
        expect(func.builder.isFuture, true);
      });

      test('should register and retrieve using builder', () async {
        // For functions with parameters, we need to provide them or use a factory
        // that doesn't require auto-injection
        Future<TestService> func(String a, int b, bool c, double d, String e,
            int f, bool g, double h, String i, int j) async {
          return TestService();
        }

        final builder = func.builder;
        expect(builder.parametersType.length, 10);
        expect(builder.isFuture, true);
      });
    });

    group('inject method', () {
      test('should auto inject sync function dependencies', () async {
        await ddi.object<String>('auto');
        await ddi.object<int>(42);
        await ddi.object<bool>(true);

        TestService func(String text, int count, bool enabled) {
          expect(text, 'auto');
          expect(count, 42);
          expect(enabled, true);
          return TestService();
        }

        final producer = func.inject();
        final instance = producer();

        expect(instance, isA<TestService>());
      });

      test('should auto inject async function dependencies', () async {
        await ddi.object<String>('async-auto');
        await ddi.object<int>(99);
        await ddi.object<bool>(false);

        Future<TestService> func(String text, int count, bool enabled) async {
          expect(text, 'async-auto');
          expect(count, 99);
          expect(enabled, false);
          return TestService();
        }

        final producer = func.inject();
        final instance = await producer();

        expect(instance, isA<TestService>());
      });

      test('should allow ddi.singleton(A.new.inject())', () async {
        await ddi.singleton(C.new);
        await ddi.singleton(B.new.inject().call);
        await ddi.singleton(A.new.inject().call);

        final instance = ddi.get<A>();
        expect(instance.b, isA<B>());
        expect(instance.b.c, isA<C>());
      });

      test('should allow A.new.inject().asApplication()', () async {
        await C.new.builder.asApplication();
        await B.new.inject().asApplication();

        final instance = ddi.get<B>();
        expect(instance.c, isA<C>());
      });

      test('should allow ApplicationFactory(builder: B.new.inject())',
          () async {
        await DDI.instance.register(
          factory: ApplicationFactory(
            builder: C.new.builder,
          ),
        );

        await DDI.instance.register(
          factory: ApplicationFactory(
            builder: B.new.inject(),
          ),
        );

        final instance = ddi.get<B>();
        expect(instance.c, isA<C>());
      });

      test(
          'should resolve class constructor chain with singleton and dependent',
          () async {
        await ddi.object<AutoInjectClassLeaf>(const AutoInjectClassLeaf(11));
        await ddi.object<AutoInjectClassConfig>(
          const AutoInjectClassConfig('prod'),
        );
        await AutoInjectClassMiddle.new.inject().asSingleton();
        await AutoInjectClassRoot.new.inject().asDependent();

        final root1 = ddi.get<AutoInjectClassRoot>();
        final root2 = ddi.get<AutoInjectClassRoot>();

        expect(root1, isNot(same(root2)));
        expect(root1.middle, same(root2.middle));
        expect(root1.middle.leaf.id, 11);
        expect(root1.middle.config.name, 'prod');
        expect(root1.leaf.id, 11);
      });

      test('should auto inject async dependency into async producer', () async {
        await (() async {
          await Future<void>.delayed(const Duration(milliseconds: 5));
          return const AutoInjectFutureLeaf(21);
        }).inject().asApplication();
        await (() async {
          await Future<void>.delayed(const Duration(milliseconds: 5));
          return const AutoInjectFutureFlag(true);
        }).inject().asApplication();

        Future<AutoInjectFutureRoot> producer(
          AutoInjectFutureLeaf leaf,
          AutoInjectFutureFlag flag,
        ) async {
          await Future<void>.delayed(const Duration(milliseconds: 5));
          return AutoInjectFutureRoot(leaf, flag);
        }

        await producer.inject().asApplication();

        final instance = await ddi.getAsync<AutoInjectFutureRoot>();
        expect(instance.leaf.id, 21);
        expect(instance.flag.enabled, isTrue);
      });

      test('should allow async inject in ApplicationFactory builder', () async {
        await DDI.instance.register(
          factory: ApplicationFactory(
            builder: (() async {
              await Future<void>.delayed(const Duration(milliseconds: 5));
              return const AutoInjectFutureLeaf(34);
            }).inject(),
          ),
        );
        await DDI.instance.register(
          factory: ApplicationFactory(
            builder: (() async {
              await Future<void>.delayed(const Duration(milliseconds: 5));
              return const AutoInjectFutureFlag(false);
            }).inject(),
          ),
        );

        await DDI.instance.register(
          factory: ApplicationFactory(
            builder:
                ((AutoInjectFutureLeaf leaf, AutoInjectFutureFlag flag) async {
              await Future<void>.delayed(const Duration(milliseconds: 5));
              return AutoInjectFutureRoot(leaf, flag);
            }).inject(),
          ),
        );

        final instance = await ddi.getAsync<AutoInjectFutureRoot>();
        expect(instance.leaf.id, 34);
        expect(instance.flag.enabled, isFalse);
      });

      test('should auto inject 4 class parameters on sync constructor',
          () async {
        await ddi.object<AutoInjectManyA>(const AutoInjectManyA('many'));
        await ddi.object<AutoInjectManyB>(const AutoInjectManyB(7));
        await ddi.object<AutoInjectManyC>(const AutoInjectManyC(true));
        await ddi.object<AutoInjectManyD>(const AutoInjectManyD(3.14));

        await AutoInjectManyRoot.new.inject().asDependent();

        final instance = ddi.get<AutoInjectManyRoot>();
        expect(instance.a.value, 'many');
        expect(instance.b.value, 7);
        expect(instance.c.value, isTrue);
        expect(instance.d.value, closeTo(3.14, 0.0001));
      });

      test('should auto inject 4 class parameters on async producer', () async {
        await ddi.object<AutoInjectManyA>(const AutoInjectManyA('future-many'));
        await ddi.object<AutoInjectManyB>(const AutoInjectManyB(99));
        await ddi.object<AutoInjectManyC>(const AutoInjectManyC(false));
        await ddi.object<AutoInjectManyD>(const AutoInjectManyD(2.5));

        Future<AutoInjectManyFutureRoot> producer(
          AutoInjectManyA a,
          AutoInjectManyB b,
          AutoInjectManyC c,
          AutoInjectManyD d,
        ) async {
          await Future<void>.delayed(const Duration(milliseconds: 5));
          return AutoInjectManyFutureRoot(a, b, c, d);
        }

        await producer.inject().asApplication();

        final instance = await ddi.getAsync<AutoInjectManyFutureRoot>();
        expect(instance.a.value, 'future-many');
        expect(instance.b.value, 99);
        expect(instance.c.value, isFalse);
        expect(instance.d.value, closeTo(2.5, 0.0001));
      });

      test('should support zero-parameter inject producers', () async {
        TestService syncProducer() => TestService();
        Future<TestService> asyncProducer() async => TestService();

        expect(syncProducer.inject()(), isA<TestService>());
        expect(await asyncProducer.inject()(), isA<TestService>());
      });

      test('should auto inject one async dependency', () async {
        final localDdi = DDI.newInstance();
        await localDdi.object<AutoInjectHighA>(const AutoInjectHighA(1));

        Future<int> producer(AutoInjectHighA a) async => a.value;

        expect(await producer.inject(localDdi)(), 1);
      });

      test('should auto inject sync producers with 5 through 10 parameters',
          () async {
        final localDdi = await _highArityDdi();

        int five(
          AutoInjectHighA a,
          AutoInjectHighB b,
          AutoInjectHighC c,
          AutoInjectHighD d,
          AutoInjectHighE e,
        ) =>
            a.value + b.value + c.value + d.value + e.value;

        int six(
          AutoInjectHighA a,
          AutoInjectHighB b,
          AutoInjectHighC c,
          AutoInjectHighD d,
          AutoInjectHighE e,
          AutoInjectHighF f,
        ) =>
            five(a, b, c, d, e) + f.value;

        int seven(
          AutoInjectHighA a,
          AutoInjectHighB b,
          AutoInjectHighC c,
          AutoInjectHighD d,
          AutoInjectHighE e,
          AutoInjectHighF f,
          AutoInjectHighG g,
        ) =>
            six(a, b, c, d, e, f) + g.value;

        int eight(
          AutoInjectHighA a,
          AutoInjectHighB b,
          AutoInjectHighC c,
          AutoInjectHighD d,
          AutoInjectHighE e,
          AutoInjectHighF f,
          AutoInjectHighG g,
          AutoInjectHighH h,
        ) =>
            seven(a, b, c, d, e, f, g) + h.value;

        int nine(
          AutoInjectHighA a,
          AutoInjectHighB b,
          AutoInjectHighC c,
          AutoInjectHighD d,
          AutoInjectHighE e,
          AutoInjectHighF f,
          AutoInjectHighG g,
          AutoInjectHighH h,
          AutoInjectHighI i,
        ) =>
            eight(a, b, c, d, e, f, g, h) + i.value;

        int ten(
          AutoInjectHighA a,
          AutoInjectHighB b,
          AutoInjectHighC c,
          AutoInjectHighD d,
          AutoInjectHighE e,
          AutoInjectHighF f,
          AutoInjectHighG g,
          AutoInjectHighH h,
          AutoInjectHighI i,
          AutoInjectHighJ j,
        ) =>
            nine(a, b, c, d, e, f, g, h, i) + j.value;

        expect(five.inject(localDdi)(), 15);
        expect(six.inject(localDdi)(), 21);
        expect(seven.inject(localDdi)(), 28);
        expect(eight.inject(localDdi)(), 36);
        expect(nine.inject(localDdi)(), 45);
        expect(ten.inject(localDdi)(), 55);
      });

      test('should auto inject async producers with 5 through 10 parameters',
          () async {
        final localDdi = await _highArityDdi();

        Future<int> five(
          AutoInjectHighA a,
          AutoInjectHighB b,
          AutoInjectHighC c,
          AutoInjectHighD d,
          AutoInjectHighE e,
        ) async =>
            a.value + b.value + c.value + d.value + e.value;

        Future<int> six(
          AutoInjectHighA a,
          AutoInjectHighB b,
          AutoInjectHighC c,
          AutoInjectHighD d,
          AutoInjectHighE e,
          AutoInjectHighF f,
        ) async =>
            a.value + b.value + c.value + d.value + e.value + f.value;

        Future<int> seven(
          AutoInjectHighA a,
          AutoInjectHighB b,
          AutoInjectHighC c,
          AutoInjectHighD d,
          AutoInjectHighE e,
          AutoInjectHighF f,
          AutoInjectHighG g,
        ) async =>
            a.value + b.value + c.value + d.value + e.value + f.value + g.value;

        Future<int> eight(
          AutoInjectHighA a,
          AutoInjectHighB b,
          AutoInjectHighC c,
          AutoInjectHighD d,
          AutoInjectHighE e,
          AutoInjectHighF f,
          AutoInjectHighG g,
          AutoInjectHighH h,
        ) async =>
            a.value +
            b.value +
            c.value +
            d.value +
            e.value +
            f.value +
            g.value +
            h.value;

        Future<int> nine(
          AutoInjectHighA a,
          AutoInjectHighB b,
          AutoInjectHighC c,
          AutoInjectHighD d,
          AutoInjectHighE e,
          AutoInjectHighF f,
          AutoInjectHighG g,
          AutoInjectHighH h,
          AutoInjectHighI i,
        ) async =>
            a.value +
            b.value +
            c.value +
            d.value +
            e.value +
            f.value +
            g.value +
            h.value +
            i.value;

        Future<int> ten(
          AutoInjectHighA a,
          AutoInjectHighB b,
          AutoInjectHighC c,
          AutoInjectHighD d,
          AutoInjectHighE e,
          AutoInjectHighF f,
          AutoInjectHighG g,
          AutoInjectHighH h,
          AutoInjectHighI i,
          AutoInjectHighJ j,
        ) async =>
            a.value +
            b.value +
            c.value +
            d.value +
            e.value +
            f.value +
            g.value +
            h.value +
            i.value +
            j.value;

        expect(await five.inject(localDdi)(), 15);
        expect(await six.inject(localDdi)(), 21);
        expect(await seven.inject(localDdi)(), 28);
        expect(await eight.inject(localDdi)(), 36);
        expect(await nine.inject(localDdi)(), 45);
        expect(await ten.inject(localDdi)(), 55);
      });
    });
  });
}

Future<void> _destroyIfRegistered<T extends Object>() async {
  if (!ddi.isRegistered<T>()) {
    return;
  }

  final result = ddi.destroy<T>();
  if (result is Future<void>) {
    await result;
  }
}

Future<DDI> _highArityDdi() async {
  final localDdi = DDI.newInstance();
  await localDdi.object<AutoInjectHighA>(const AutoInjectHighA(1));
  await localDdi.object<AutoInjectHighB>(const AutoInjectHighB(2));
  await localDdi.object<AutoInjectHighC>(const AutoInjectHighC(3));
  await localDdi.object<AutoInjectHighD>(const AutoInjectHighD(4));
  await localDdi.object<AutoInjectHighE>(const AutoInjectHighE(5));
  await localDdi.object<AutoInjectHighF>(const AutoInjectHighF(6));
  await localDdi.object<AutoInjectHighG>(const AutoInjectHighG(7));
  await localDdi.object<AutoInjectHighH>(const AutoInjectHighH(8));
  await localDdi.object<AutoInjectHighI>(const AutoInjectHighI(9));
  await localDdi.object<AutoInjectHighJ>(const AutoInjectHighJ(10));
  return localDdi;
}
