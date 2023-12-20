import 'package:dart_di/features/ddi_interceptor.dart';
import 'package:flutter/widgets.dart';

class J<T> extends DDIInterceptor<T> {
  @override
  T aroundConstruct(T instance) {
    debugPrint('Inicializando classe F');

    return instance;
  }
}
