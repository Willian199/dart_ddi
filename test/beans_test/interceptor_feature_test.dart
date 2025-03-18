import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:test/test.dart';

import '../clazz_samples/database_log.dart';
import '../clazz_samples/g.dart';
import '../clazz_samples/h.dart';
import '../clazz_samples/i.dart';
import '../clazz_samples/j.dart';
import '../clazz_samples/logger_future_interceptor.dart';
import '../clazz_samples/logger_interceptor.dart';
import '../clazz_samples/with_destroy_interceptor.dart';

void interceptorFeatures() {
  group('DDI Feature Interceptor Tests', () {
    test('ADD Interceptor with Logs Interceptors and Beans', () {
      ddi.register(
        factory: SingletonFactory(
          builder: LoggerInterceptor.new.builder,
        ),
      );

      ddi.register(
        factory: ApplicationFactory(
          builder: CustomBuilder.of(J.new),
          interceptors: {LoggerInterceptor},
        ),
      );

      ///Where is Singleton, should the register in the correct order
      ddi.singleton<G>(() => H(), interceptors: {J, LoggerInterceptor});

      final G instance = ddi.get<G>();

      expect(instance.area(), 20);
      expect(instance is I, true);

      ddi.dispose<G>();
      ddi.dispose<J>();
      ddi.dispose<LoggerInterceptor>();

      ddi.destroy<G>();
      ddi.destroy<J>();
      ddi.destroy<LoggerInterceptor>();

      expect(() => ddi.get<G>(), throwsA(isA<BeanNotFoundException>()));
      expect(ddi.isRegistered<J>(), false);
      expect(ddi.isRegistered<LoggerInterceptor>(), false);
    });

    test('ADD Future variation Interceptor with Logs Interceptors and Beans',
        () async {
      DatabaseLog.new.builder.asApplication();

      ddi.register(
        factory: ApplicationFactory(
          builder: LoggerFutureInterceptor.new.builder,
        ),
      );

      ddi.register(
        factory: ApplicationFactory(
          builder: CustomBuilder.ofFuture(J.new),
          interceptors: {LoggerFutureInterceptor},
        ),
      );

      ddi.application<G>(
        H.new,
        interceptors: {J, LoggerFutureInterceptor},
      );

      final G instance = await ddi.getAsync<G>();

      expect(instance.area(), 20);
      expect(instance is I, true);

      // Dispose will only call the interceptors, but will stay a valid instance
      await ddi.dispose<G>();
      await ddi.destroy<G>();

      await ddi.dispose<J>();
      await ddi.destroy<J>();

      await ddi.dispose<LoggerFutureInterceptor>();
      await ddi.destroy<LoggerFutureInterceptor>();

      await ddi.dispose<DatabaseLog>();
      ddi.destroy<DatabaseLog>();

      expect(() => ddi.getAsync<G>(), throwsA(isA<BeanNotFoundException>()));
      expect(ddi.isRegistered<J>(), false);
      expect(ddi.isRegistered<LoggerFutureInterceptor>(), false);
      expect(ddi.isRegistered<DatabaseLog>(), false);
    });

    test('ADD Future Interceptor with Logs Interceptors and Beans', () async {
      ddi.register(
        factory: SingletonFactory(
          builder: () async {
            await Future.delayed(const Duration(milliseconds: 200));
            return LoggerInterceptor();
          }.builder,
        ),
      );

      ddi.register(
        factory: ApplicationFactory(
          builder: CustomBuilder.ofFuture(() async {
            await Future.delayed(const Duration(milliseconds: 200));
            return J();
          }),
          interceptors: {LoggerInterceptor},
        ),
      );

      ddi.application<G>(H.new, interceptors: {J, LoggerInterceptor});

      final G instance = await ddi.getAsync<G>();

      expect(instance.area(), 20);
      expect(instance is I, true);

      // Dispose will only call the interceptors, but will stay a valid instance
      await ddi.dispose<G>();
      await ddi.destroy<G>();

      await ddi.dispose<J>();
      await ddi.destroy<J>();

      await ddi.dispose<LoggerInterceptor>();
      await ddi.destroy<LoggerInterceptor>();

      expect(() => ddi.get<G>(), throwsA(isA<BeanNotFoundException>()));
      expect(ddi.isRegistered<J>(), false);
      expect(ddi.isRegistered<LoggerInterceptor>(), false);
    });

    test('ADD Future Interceptor with destroy onGet', () async {
      await ddi.register(
        factory: SingletonFactory(
          builder: () async {
            await Future.delayed(const Duration(milliseconds: 200));
            return WithDestroyInterceptor();
          }.builder,
        ),
      );

      ddi.application<G>(H.new, interceptors: {WithDestroyInterceptor});

      expect(ddi.isRegistered<G>(), true);

      final G instance = await ddi.getAsync<G>();

      expect(ddi.isRegistered<G>(), false);

      expect(instance.area(), 10);

      await ddi.destroy<WithDestroyInterceptor>();

      expect(ddi.isRegistered<WithDestroyInterceptor>(), false);
    });
  });
}
