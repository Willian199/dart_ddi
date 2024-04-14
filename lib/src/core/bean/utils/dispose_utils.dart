import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/data/factory_clazz.dart';

final class DisposeUtils {
  /// Dispose only clean the class Instance
  static Future<void> disposeBean<BeanT>(
    FactoryClazz<BeanT> factoryClazz,
    Object effectiveQualifierName,
  ) {
    if (factoryClazz.clazzInstance case final clazz?) {
      if (factoryClazz.interceptors case final inter? when inter.isNotEmpty) {
        //Call aroundDispose before reset the clazzInstance
        for (final interceptor in inter) {
          interceptor().aroundDispose(clazz);
        }
      }

      if (clazz is PreDispose) {
        return _runFutureOrPreDispose<BeanT>(
            factoryClazz, clazz, effectiveQualifierName);
      }
    }

    _disposeChildren(factoryClazz);
    return Future.value();
  }

  static Future<void> _runFutureOrPreDispose<BeanT>(
      FactoryClazz<BeanT> factoryClazz,
      PreDispose clazz,
      Object effectiveQualifierName) async {
    await clazz.onPreDispose();

    _disposeChildren<BeanT>(factoryClazz);
  }

  static void _disposeChildren<BeanT>(FactoryClazz<BeanT> factoryClazz) {
    if (factoryClazz.children case final List<Object> children?
        when children.isNotEmpty) {
      for (final Object child in children) {
        ddi.dispose(qualifier: child);
      }
    }

    factoryClazz.clazzInstance = null;
  }
}
