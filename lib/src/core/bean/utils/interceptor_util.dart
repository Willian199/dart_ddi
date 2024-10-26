import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';

final class InterceptorUtil {
  static BeanT create<BeanT extends Object>(
    ScopeFactory<BeanT> factory,
    BeanT applicationClazz,
  ) {
    if (factory.interceptors case final inter? when inter.isNotEmpty) {
      for (final interceptor in inter) {
        final instance =
            ddi.get(qualifier: interceptor) as DDIInterceptor<BeanT>;

        applicationClazz = instance.onCreate(applicationClazz) as BeanT;
      }
    }

    return applicationClazz;
  }

  static BeanT onCreate<BeanT extends Object>(
    Object interceptor,
    BeanT clazz,
  ) {
    final instance = ddi.get(qualifier: interceptor) as DDIInterceptor;

    return instance.onCreate(clazz) as BeanT;
  }

  static FutureOr<BeanT> createAsync<BeanT extends Object>(
    ScopeFactory<BeanT> factory,
    BeanT applicationClazz,
  ) async {
    if (factory.interceptors case final inter? when inter.isNotEmpty) {
      for (final interceptor in inter) {
        final DDIInterceptor<BeanT> instance =
            await ddi.getAsync<DDIInterceptor<BeanT>>(qualifier: interceptor);

        final FutureOr<BeanT> exec = instance.onCreate(applicationClazz);

        applicationClazz = exec is Future ? await exec : exec;
      }
    }

    return applicationClazz;
  }

  static BeanT get<BeanT extends Object>(
    ScopeFactory<BeanT> factory,
    BeanT applicationClazz,
  ) {
    if (factory.interceptors case final inter? when inter.isNotEmpty) {
      for (final interceptor in inter) {
        final instance = ddi.get(qualifier: interceptor) as DDIInterceptor;

        applicationClazz = instance.onGet(applicationClazz) as BeanT;
      }
    }

    return applicationClazz;
  }

  static FutureOr<BeanT> getAsync<BeanT extends Object>(
    ScopeFactory<BeanT> factory,
    BeanT applicationClazz,
  ) async {
    if (factory.interceptors case final inter? when inter.isNotEmpty) {
      for (final interceptor in inter) {
        final DDIInterceptor<BeanT> instance =
            await ddi.getAsync<DDIInterceptor<BeanT>>(qualifier: interceptor);

        final FutureOr<BeanT> exec = instance.onGet(applicationClazz);

        applicationClazz = exec is Future ? await exec : exec;
      }
    }

    return applicationClazz;
  }

  static FutureOr<void> disposeAsync<BeanT extends Object>(
    ScopeFactory<BeanT> factory,
    BeanT? applicationClazz,
  ) async {
    if (factory.interceptors case final inter? when inter.isNotEmpty) {
      for (final interceptor in inter) {
        final DDIInterceptor<BeanT> instance =
            await ddi.getAsync<DDIInterceptor<BeanT>>(qualifier: interceptor);

        final exec = instance.onDispose(applicationClazz);
        if (exec is Future) {
          await exec;
        }
      }
    }
  }
}
