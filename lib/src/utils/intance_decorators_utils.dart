import 'package:dart_ddi/src/typedef/typedef.dart';

final class InstanceDecoratorsUtils {
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
}
