import 'package:dart_ddi/dart_ddi.dart';

final class DisposeUtils {
  /// Dispose only clean the class Instance
  static Future<void> disposeBean<BeanT extends Object>(
      ScopeFactory<BeanT> factory) {
    if (factory.interceptors case final inter? when inter.isNotEmpty) {
      // Call onDispose before reset the instanceHolder
      // Should call interceptors even if the instance is null
      for (final interceptor in inter) {
        interceptor().onDispose(factory.instanceHolder);
      }
    }

    if (factory.instanceHolder case final clazz? when clazz is PreDispose) {
      return _runFutureOrPreDispose<BeanT>(factory, clazz);
    }

    _disposeChildren(factory.children);
    factory.instanceHolder = null;
    return Future.value();
  }

  static Future<void> _runFutureOrPreDispose<BeanT extends Object>(
      ScopeFactory<BeanT> factory, PreDispose clazz) async {
    disposeChildrenAsync<BeanT>(factory.children);

    await clazz.onPreDispose();

    factory.instanceHolder = null;

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
