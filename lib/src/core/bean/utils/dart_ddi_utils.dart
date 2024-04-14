import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/data/factory_clazz.dart';
import 'package:dart_ddi/src/exception/bean_destroyed.dart';
import 'package:dart_ddi/src/exception/duplicated_bean.dart';
import 'package:dart_ddi/src/typedef/typedef.dart';

final class DartDDIUtils {
  static BeanT executarDecorators<BeanT extends Object>(
    BeanT clazz,
    ListDecorator<BeanT>? decorators,
  ) {
    if (decorators != null) {
      for (final decorator in decorators) {
        clazz = decorator(clazz);
      }
    }

    return clazz;
  }

  static Future<void> runFutureOrPostConstruct(
      Future<PostConstruct> register) async {
    final PostConstruct clazz = await register;

    return clazz.onPostConstruct();
  }

  static void validateDuplicated(Object effectiveQualifierName, bool debug) {
    if (debug) {
      // ignore: avoid_print
      print(
          'Is already registered a instance with Type ${effectiveQualifierName.toString()}');
    } else {
      throw DuplicatedBeanException(effectiveQualifierName.toString());
    }
  }

  static BeanT getSingleton<BeanT extends Object>(
      FactoryClazz<BeanT> factoryClazz, Object effectiveQualifierName) {
    if (factoryClazz.clazzInstance case var clazz?) {
      if (factoryClazz.interceptors case final inter? when inter.isNotEmpty) {
        for (final interceptor in inter) {
          clazz = interceptor().aroundGet(clazz);
        }
      }

      return clazz;
    }

    throw BeanDestroyedException(effectiveQualifierName.toString());
  }
}
