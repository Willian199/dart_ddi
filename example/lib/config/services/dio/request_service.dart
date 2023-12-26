import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:perfumei/common/constants/injection_constants.dart';
import 'package:perfumei/common/extensions/map_extension.dart';
import 'package:perfumei/config/services/dio/service_interceptor/cache_options.dart';
import 'package:perfumei/config/services/dio/service_interceptor/error_interceptor.dart';
import 'package:perfumei/config/services/dio/service_interceptor/time_log_interceptor.dart';
import 'package:perfumei/config/services/injection.dart';

class RequestService {
  static Future<dynamic> get({
    required String url,
    void Function()? callbackErro,
    dynamic data,
    bool usarCache = true,
    dynamic Function(Map<String, dynamic>)? fromJson,
  }) async {
    final Dio dio = await _dioConstruct(url, callbackErro, usarCache);

    String urlCompose =
        ddi.get<String>(qualifier: InjectionConstants.url) + url;

    if (data is String) {
      urlCompose += '?$data';
    } else if (data is Map) {
      urlCompose += '?${data.mapToQueryString()}';
    }

    final Response retorno = await dio.get(urlCompose);

    if (fromJson != null) {
      return fromJson((retorno.data ?? {'': ''}) as Map<String, dynamic>);
    } else {
      return retorno;
    }
  }

  static Future<dynamic> getExternal({
    required String url,
    void Function()? callbackErro,
    dynamic valor,
    bool usarCache = true,
    dynamic Function(Map<String, dynamic>)? fromJson,
  }) async {
    final Dio dio = await _dioConstruct(url, callbackErro, usarCache);

    late Response retorno;
    if (valor == null || valor.toString().isEmpty) {
      retorno = await dio.get(url);
    } else {
      retorno = await dio.get('$url?queryParameters=$valor');
    }

    if (fromJson != null) {
      return fromJson((retorno.data ?? '') as Map<String, dynamic>);
    } else {
      return retorno;
    }
  }

  static Future<dynamic> getHtml({
    required String url,
    void Function()? callbackErro,
    dynamic valor,
    bool usarCache = true,
    dynamic Function(Map<String, dynamic>)? fromJson,
  }) async {
    final Dio dio = await _dioConstruct(url, callbackErro, usarCache);

    late Response retorno;
    if (valor == null || valor.toString().isEmpty) {
      retorno = await dio.get(url);
    } else {
      retorno = await dio.get('$url?queryParameters=$valor');
    }

    if (fromJson != null) {
      return fromJson((retorno.data ?? {'': ''}) as Map<String, dynamic>);
    } else {
      return retorno;
    }
  }

  static Future<dynamic> post({
    required String url,
    void Function()? callbackErro,
    dynamic data,
    bool usarCache = false,
    dynamic Function(Map<String, dynamic>)? fromJson,
  }) async {
    final Dio dio = await _dioConstruct(url, callbackErro, usarCache);

    final String api = ddi.get<String>(qualifier: InjectionConstants.url);

    late Response retorno;
    if (data == null) {
      retorno = await dio.post(api + url);
    } else {
      retorno = await dio.post(api + url, data: json.encode(data));
    }

    if (fromJson != null) {
      return fromJson((retorno.data ?? {'': ''}) as Map<String, dynamic>);
    } else {
      return retorno;
    }
  }

  static Future<dynamic> delete({
    required String url,
    void Function()? callbackErro,
    dynamic id,
  }) async {
    final Dio dio = await _dioConstruct(url, callbackErro, false);

    final String api = ddi.get<String>(qualifier: InjectionConstants.url);

    if (id == null) {
      return dio.delete(api + url);
    } else {
      return dio.delete('$api$url?id=$id');
    }
  }

  static Future<Dio> _dioConstruct(
    String url,
    void Function()? callbackErro,
    bool usarCache,
  ) async {
    final Dio dio = Dio();
    dio.options.baseUrl = ddi.get<String>(qualifier: InjectionConstants.url);
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(minutes: 2);
    dio.options.responseType = ResponseType.json;
    dio.options.contentType = 'application/json';

    // Converta a data para o fuso horário desejado
    final DateTime dataAtual = DateTime.now();

    dio.interceptors.add(ErrorInterceptor(callbackErro));

    if (usarCache) {
      dio.interceptors.add(
        DioCacheInterceptor(
          options: await DioCacheOptions.getCacheOptions(),
        ),
      );
    }

    dio.interceptors.add(TimeLogInterceptor(dataAtual));

    return dio;
  }
}
