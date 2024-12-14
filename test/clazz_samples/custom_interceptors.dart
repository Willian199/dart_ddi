import 'package:dart_ddi/dart_ddi.dart';

class AddInterceptor extends DDIInterceptor<int> {
  @override
  int onCreate(int instance) {
    return instance + 10;
  }
}

class MultiplyInterceptor extends DDIInterceptor<int> {
  @override
  int onGet(int instance) {
    return instance * 2;
  }
}

class AsyncAddInterceptor extends DDIInterceptor<int> {
  @override
  Future<int> onCreate(int instance) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return instance + 20;
  }
}

class ErrorInterceptor extends DDIInterceptor<int> {
  @override
  int onGet(int instance) {
    throw Exception("Interceptor Error");
  }
}
