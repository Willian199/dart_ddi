import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/data/factory_clazz.dart';

final class DisposeUtils {
  /// Dispose only clean the class Instance
  static Future<void> disposeBean<BeanT extends Object>(
      FactoryClazz<BeanT> factoryClazz) {
    if (factoryClazz.interceptors case final inter? when inter.isNotEmpty) {
      // Call aroundDispose before reset the clazzInstance
      // Should call interceptors even if the instance is null
      for (final interceptor in inter) {
        interceptor().aroundDispose(factoryClazz.clazzInstance);
      }
    }

    if (factoryClazz.clazzInstance case final clazz? when clazz is PreDispose) {
      return _runFutureOrPreDispose<BeanT>(factoryClazz, clazz);
    }

    _disposeChildren(factoryClazz.children);
    factoryClazz.clazzInstance = null;
    return Future.value();
  }

  static Future<void> _runFutureOrPreDispose<BeanT extends Object>(
      FactoryClazz<BeanT> factoryClazz, PreDispose clazz) async {
    disposeChildrenAsync<BeanT>(factoryClazz.children);

    await clazz.onPreDispose();

    factoryClazz.clazzInstance = null;

    return Future.value();
  }

  static void _disposeChildren<BeanT extends Object>(Set<Object>? children) {
    if (children?.isNotEmpty ?? false) {
      for (final Object child in children!) {
        ddi.dispose(qualifier: child);
      }
    }
  }

  static Future<void> disposeChildrenAsync<BeanT extends Object>(
      Set<Object>? children) async {
    if (children?.isNotEmpty ?? false) {
      for (final Object child in children!) {
        await ddi.dispose(qualifier: child);
      }
    }
  }
}
