import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';

class LoggerInterceptor implements DDIInterceptor {
  @override
  FutureOr<Object> onCreate(Object instance) {
    print("Creating ${instance.runtimeType}");
    return instance;
  }

  @override
  FutureOr<void> onDestroy(Object? instance) {
    print("Destroying ${instance.runtimeType}");
  }

  @override
  FutureOr<void> onDispose(Object? instance) {
    print("Disposing ${instance.runtimeType}");
  }

  @override
  FutureOr<Object> onGet(Object instance) {
    print("Getting ${instance.runtimeType}");
    return instance;
  }
}
