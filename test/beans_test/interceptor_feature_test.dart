import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:test/test.dart';

import '../clazz_samples/g.dart';
import '../clazz_samples/h.dart';
import '../clazz_samples/i.dart';
import '../clazz_samples/j.dart';
import '../clazz_samples/logger_interceptor.dart';

void interceptorFeatures() {
  group('DDI Feature Interceptor Tests', () {
    test('ADD Interceptor with Logs Interceptors and Beans', () {
      ddi.register(
        factory: ScopeFactory.singleton(
          builder: LoggerInterceptor.new.builder,
        ),
      );

      ddi.register(
        factory: ScopeFactory.application(
          builder: CustomBuilder.of(J.new),
          interceptors: {LoggerInterceptor},
        ),
      );

      ///Where is Singleton, should the register in the correct order
      ddi.registerSingleton<G>(() => H(), interceptors: {J, LoggerInterceptor});

      print('pegando G');
      final G instance = ddi.get<G>();

      expect(instance.area(), 20);
      expect(instance is I, true);

      print('Disposing G');
      ddi.dispose<G>();
      ddi.dispose<J>();
      ddi.dispose<LoggerInterceptor>();

      print('destruindo G');
      ddi.destroy<G>();
      ddi.destroy<J>();
      ddi.destroy<LoggerInterceptor>();

      print('Validando');

      expect(() => ddi.get<G>(), throwsA(isA<BeanNotFoundException>()));
      expect(ddi.isRegistered<J>(), false);
      expect(ddi.isRegistered<LoggerInterceptor>(), false);
    });

    test('ADD Future Interceptor with Logs Interceptors and Beans', () async {
      ddi.register(
        factory: ScopeFactory.singleton(
          builder: () async {
            await Future.delayed(const Duration(milliseconds: 200));
            return LoggerInterceptor();
          }.builder,
        ),
      );

      ddi.register(
        factory: ScopeFactory.application(
          builder: CustomBuilder.ofFuture(() async {
            await Future.delayed(const Duration(milliseconds: 200));
            return J();
          }),
          interceptors: {LoggerInterceptor},
        ),
      );

      await ddi
          .registerApplication<G>(H.new, interceptors: {J, LoggerInterceptor});

      print('pegando G');
      final G instance = await ddi.getAsync<G>();

      expect(instance.area(), 20);
      expect(instance is I, true);

      print('Finalize G');
      // Dispose will only call the interceptors, but will stay a valid instance
      await ddi.dispose<G>();
      await ddi.destroy<G>();

      print('Finalize J');
      await ddi.dispose<J>();
      await ddi.destroy<J>();

      print('Finalize LoggerInterceptor');
      await ddi.dispose<LoggerInterceptor>();
      await ddi.destroy<LoggerInterceptor>();

      print('Validando');

      expect(() => ddi.get<G>(), throwsA(isA<BeanNotFoundException>()));
      expect(ddi.isRegistered<J>(), false);
      expect(ddi.isRegistered<LoggerInterceptor>(), false);
    });
  });
}
