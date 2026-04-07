import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';

class ExampleService {}

class ExampleInterceptor implements DDIInterceptor {
  int onCreateCalled = 0;
  int onGetCalled = 0;

  @override
  Object onCreate(Object instance) {
    onCreateCalled++;
    return instance;
  }

  @override
  Object onGet(Object instance) {
    onGetCalled++;
    return instance;
  }

  @override
  void onDispose(Object? instance) {}

  @override
  FutureOr<void> onDestroy(Object? instance) {}
}
