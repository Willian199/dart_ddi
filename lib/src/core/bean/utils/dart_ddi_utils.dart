import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_destroyed.dart';
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

  static BeanT getSingleton<BeanT extends Object>(
      ScopeFactory<BeanT> factory, Object effectiveQualifierName) {
    if (factory.instanceHolder case var clazz?) {
      if (factory.interceptors case final inter? when inter.isNotEmpty) {
        for (final interceptor in inter) {
          clazz = interceptor().onGet(clazz);
        }
      }

      return clazz;
    }

    throw BeanDestroyedException(effectiveQualifierName.toString());
  }
}
