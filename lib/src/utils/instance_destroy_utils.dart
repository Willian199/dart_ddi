import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';

final class InstanceDestroyUtils {
  static FutureOr<void> destroyInstance<BeanT extends Object>({
    required void Function() apply,
    required bool canDestroy,
    required BeanT? instance,
    required Set<Object> children,
    required Set<Object> interceptors,
  }) async {
    // Only destroy if canDestroy was registered with true
    if (!canDestroy) {
      return;
    }

    // Should call interceptors even if the instance is null
    for (final interceptor in interceptors) {
      if (ddi.isFuture(qualifier: interceptor)) {
        final inter =
            (await ddi.getAsync(qualifier: interceptor)) as DDIInterceptor;

        await inter.onDestroy(instance);
      } else {
        final inter = ddi.get(qualifier: interceptor) as DDIInterceptor;

        inter.onDestroy(instance);
      }
    }

    if (instance case final clazz? when clazz is PreDestroy) {
      return _runFutureOrPreDestroy<BeanT>(clazz, children, apply);
    } else if (instance is DDIModule) {
      if (children.isNotEmpty) {
        final List<Future<void>> futures = [];
        for (final Object child in children) {
          futures.add(ddi.destroy(qualifier: child) as Future<void>);
        }
        return Future.wait(
          futures,
          eagerError: true,
        ).then(
          (_) => apply(),
        );
      }
    }

    _destroyChildren<BeanT>(children);
    apply();
  }

  static FutureOr<void> _destroyChildren<BeanT extends Object>(
      Set<Object> children) {
    for (final Object child in children) {
      ddi.destroy(qualifier: child);
    }
  }

  static Future<void> _runFutureOrPreDestroy<BeanT extends Object>(
      PreDestroy clazz, Set<Object> children, void Function() apply) async {
    for (final Object child in children) {
      await ddi.destroy(qualifier: child);
    }

    await clazz.onPreDestroy();
    apply();
  }
}
