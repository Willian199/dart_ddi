import 'dart:io';

import 'package:dio/dio.dart';
import 'package:perfumei/common/components/notification/notificacao.dart';
import 'package:perfumei/common/components/notification/notificacao_padrao.dart';
import 'package:perfumei/common/constants/mensagens.dart';

class ErrorInterceptor extends Interceptor {
  ErrorInterceptor(this.callbackErro);

  final void Function()? callbackErro;

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    Notificacao.close();
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        NotificacaoPadrao.connectionTimeout(callbackErro: callbackErro);
        break;
      case DioExceptionType.receiveTimeout:
        NotificacaoPadrao.responseTimeout(callbackErro: callbackErro);
        break;
      case DioExceptionType.connectionError:
        NotificacaoPadrao.semInternet(callbackErro: callbackErro);
        break;
      case DioExceptionType.unknown:
      case DioExceptionType.badResponse:
        if (err.message?.contains("Failed host lookup") ?? false) {
          NotificacaoPadrao.semInternet(callbackErro: callbackErro);
          return;
        }
        switch (err.response?.statusCode) {
          case HttpStatus.forbidden:
          case HttpStatus.unauthorized:
            Notificacao.erro(
                mensagem:
                    err.response?.data?['mensagem']?.toString().isEmpty ?? true
                        ? Mensagens.CHAVE_EXPIRADA
                        : err.response?.data['mensagem'].toString(),
                callbackErro: () {
                  //TODO Clear user data
                });
            break;
          case HttpStatus.badRequest:
            NotificacaoPadrao.badRequest(
              mensagem: (err.response?.data ?? {})['mensagem']?.toString() ??
                  Mensagens.ERRO_PROCESSAR_REQUISICAO,
              callbackErro: callbackErro,
            );
            break;
          case HttpStatus.noContent:
            NotificacaoPadrao.semDados(callbackErro: callbackErro);
            break;
          case HttpStatus.notAcceptable:
            Notificacao.erro(
              callbackErro: callbackErro,
              mensagem:
                  'Não foi possivel prosseguir com a sua solicitação.',
            );
            break;
          default:
            Notificacao.erro(callbackErro: callbackErro);
        }
        break;
      case DioExceptionType.sendTimeout:
        // TODO: Handle this case.
        break;
      case DioExceptionType.cancel:
        // TODO: Handle this case.
        break;
      case DioExceptionType.badCertificate:
        // TODO: Handle this case.
        break;
    }

    handler.next(err);
  }
}
