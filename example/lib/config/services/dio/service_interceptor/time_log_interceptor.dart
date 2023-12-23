import 'dart:developer';

import 'package:dio/dio.dart';

class TimeLogInterceptor extends Interceptor {
  TimeLogInterceptor(this.dataAtual);
  final DateTime dataAtual;

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    log('Tempo de execução: ${response.realUri.path} > ${DateTime.now().difference(dataAtual).inMilliseconds} milissegundos');
    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    log('Tempo de execução: ${err.response?.realUri.path} > ${DateTime.now().difference(dataAtual).inMilliseconds} milissegundos');

    return;
  }
}
