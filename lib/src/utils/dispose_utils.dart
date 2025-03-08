import 'package:dart_ddi/dart_ddi.dart';

final class DisposeUtils {
  /// Dispose only clean the class Instance
  static Future<void> disposeBean<BeanT extends Object>(
      ScopeFactory<BeanT> factory) async {
    // Call onDispose before reset the instanceHolder
    // Should call interceptors even if the instance is null

    if (factory.interceptors case final inter? when inter.isNotEmpty) {
      for (final interceptor in inter) {
        if (ddi.isFuture(qualifier: interceptor)) {
          final instance =
              (await ddi.getAsync(qualifier: interceptor)) as DDIInterceptor;

          final exec = instance.onDispose(factory.instanceHolder);
          if (exec is Future) {
            await exec;
          }
        } else {
          final instance = ddi.get(qualifier: interceptor) as DDIInterceptor;

          instance.onDispose(factory.instanceHolder);
        }
      }
    }

    if (factory.instanceHolder case final clazz? when clazz is PreDispose) {
      return _runFutureOrPreDispose<BeanT>(factory, clazz);
    }

    if (factory.instanceHolder is DDIModule &&
        (factory.children?.isNotEmpty ?? false)) {
      await disposeChildrenAsync(factory);
      factory.instanceHolder = null;
    } else {
      final disposed = disposeChildrenAsync(factory);
      factory.instanceHolder = null;

      return disposed;
    }
  }

  static Future<void> _runFutureOrPreDispose<BeanT extends Object>(
      ScopeFactory<BeanT> factory, PreDispose clazz) async {
    await clazz.onPreDispose();

    await disposeChildrenAsync<BeanT>(factory);

    factory.instanceHolder = null;

    return Future.value();
  }

  static Future<void> disposeChildrenAsync<BeanT extends Object>(
    ScopeFactory<BeanT> factory,
  ) async {
    if (factory.children?.isNotEmpty ?? false) {
      final List<Future<void>> futures = [];
      for (final Object child in factory.children!) {
        futures.add(ddi.dispose(qualifier: child));
      }

      return Future.wait(futures).ignore();
    }
  }
}
