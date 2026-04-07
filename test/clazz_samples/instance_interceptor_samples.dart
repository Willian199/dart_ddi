import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';

import 'test_service.dart';

class InstanceModifierInterceptor extends DDIInterceptor<TestService> {
  InstanceModifierInterceptor(this.suffix);
  final String suffix;

  @override
  TestService onGet(TestService instance) {
    return ModifiedTestService(instance, suffix);
  }
}

class ModifiedTestService extends TestService {
  ModifiedTestService(this._original, this._suffix) : super();
  final TestService _original;
  final String _suffix;

  @override
  String doSomething() {
    return '${_original.doSomething()}$_suffix';
  }
}

class TrackingInterceptor extends DDIInterceptor<TestService> {
  int getCallCount = 0;
  int createCallCount = 0;

  @override
  TestService onCreate(TestService instance) {
    createCallCount++;
    return instance;
  }

  @override
  TestService onGet(TestService instance) {
    getCallCount++;
    return instance;
  }

  @override
  FutureOr<void> onDestroy(TestService? instance) {}
}
