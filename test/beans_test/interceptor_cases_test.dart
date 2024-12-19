import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/custom_interceptors.dart';

void intecertorCases() {
  group('DDI Interceptor Tests with int values', () {
    setUp(() async {
      // Registro de interceptores
      await ddi.register<AddInterceptor>(
        factory: ScopeFactory.singleton(
          builder: const CustomBuilder<AddInterceptor>(
            producer: AddInterceptor.new,
            parametersType: [],
            returnType: AddInterceptor,
            isFuture: false,
          ),
        ),
      );

      await ddi.register<MultiplyInterceptor>(
        factory: ScopeFactory.singleton(
          builder: const CustomBuilder<MultiplyInterceptor>(
            producer: MultiplyInterceptor.new,
            parametersType: [],
            returnType: MultiplyInterceptor,
            isFuture: false,
          ),
        ),
      );

      await ddi.register<AsyncAddInterceptor>(
        factory: ScopeFactory.singleton(
          builder: const CustomBuilder<AsyncAddInterceptor>(
            producer: AsyncAddInterceptor.new,
            parametersType: [],
            returnType: AsyncAddInterceptor,
            isFuture: false,
          ),
        ),
      );

      await ddi.register<ErrorInterceptor>(
        factory: ScopeFactory.singleton(
          builder: const CustomBuilder<ErrorInterceptor>(
            producer: ErrorInterceptor.new,
            parametersType: [],
            returnType: ErrorInterceptor,
            isFuture: false,
          ),
        ),
      );
    });

    tearDown(() async {
      // Limpeza do contêiner
      await ddi.destroy<AddInterceptor>();
      await ddi.destroy<MultiplyInterceptor>();
      await ddi.destroy<AsyncAddInterceptor>();
      await ddi.destroy<ErrorInterceptor>();
    });

    test('Interceptores aplicando soma e multiplicação', () async {
      await ddi.register<int>(
        factory: ScopeFactory.singleton(
          builder: CustomBuilder<int>(
            producer: () => 5,
            parametersType: const [],
            returnType: int,
            isFuture: false,
          ),
          interceptors: {AddInterceptor, MultiplyInterceptor},
        ),
      );

      final instance = ddi.get<int>();
      expect(instance, 30); // ((5 + 10) * 2)

      await ddi.destroy<int>();
    });

    test('Interceptores assíncronos com valores inteiros', () async {
      await ddi.register<int>(
        factory: ScopeFactory.singleton(
          builder: CustomBuilder<int>(
            producer: () => 10,
            parametersType: const [],
            returnType: int,
            isFuture: false,
          ),
          interceptors: {AsyncAddInterceptor},
        ),
      );

      final instance = await ddi.getAsync<int>();
      expect(instance, 30); // 10 + 20

      await ddi.destroy<int>();
    });

    test('Erro em interceptor ao criar valor', () async {
      await ddi.register<int>(
        factory: ScopeFactory.singleton(
          builder: CustomBuilder<int>(
            producer: () => 5,
            parametersType: const [],
            returnType: int,
            isFuture: false,
          ),
          interceptors: {ErrorInterceptor},
        ),
      );

      expect(() => ddi.get<int>(), throwsA(isA<Exception>()));

      await ddi.destroy<int>();
    });

    test('Combinação de decorators e interceptores', () async {
      await ddi.register<int>(
        factory: ScopeFactory.singleton(
          builder: CustomBuilder<int>(
            producer: () => 3,
            parametersType: const [],
            returnType: int,
            isFuture: false,
          ),
          interceptors: {AddInterceptor},
          decorators: [
            (instance) => instance * 3, // Multiplica o resultado por 3
          ],
        ),
      );

      final instance = ddi.get<int>();
      expect(instance, 39); // ((3 + 10) * 3)

      await ddi.destroy<int>();
    });

    test('Registro condicional de interceptores', () async {
      await ddi.register<int>(
        canRegister: () => Future.value(true), // Registro condicional
        factory: ScopeFactory.singleton(
          builder: CustomBuilder<int>(
            producer: () => 15,
            parametersType: const [],
            returnType: int,
            isFuture: false,
          ),
          interceptors: {AddInterceptor},
        ),
      );

      final instance = ddi.get<int>();
      expect(instance, 25); // 15 + 10

      await ddi.destroy<int>();
    });
  });
}
