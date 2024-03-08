import 'package:dart_ddi/dart_ddi.dart';
import 'package:flutter/material.dart';
import 'package:perfumei/common/constants/injection_constants.dart';
import 'package:perfumei/common/constants/mensagens.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Notificacao {
  factory Notificacao() => _instance;

  Notificacao.internal();
  static final Notificacao _instance = Notificacao.internal();

  static bool _isOpen = false;

  static void close() {
    if (_isOpen) {
      Navigator.pop(ddi<GlobalKey<NavigatorState>>().currentContext!);
    }
    _isOpen = false;
  }

  static AlertStyle _alertStyle() {
    final ThemeData tema =
        Theme.of(ddi<GlobalKey<NavigatorState>>().currentContext!);
    final bool darkMode = ddi.get(qualifier: InjectionConstants.darkMode);

    return AlertStyle(
      constraints: const BoxConstraints(minHeight: 200),
      animationType: AnimationType.fromTop,
      isCloseButton: false,
      isOverlayTapDismiss: false,
      backgroundColor:
          darkMode ? tema.colorScheme.onSecondary : tema.colorScheme.secondary,
      animationDuration: const Duration(milliseconds: 300),
      overlayColor: tema.colorScheme.secondaryContainer.withOpacity(0.4),
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: darkMode ? Colors.white : tema.colorScheme.onPrimary,
        fontSize: 20,
      ),
      descStyle: TextStyle(
        color: darkMode ? Colors.white : tema.colorScheme.onSecondary,
        fontSize: 15,
      ),
    );
  }

  static void erro({String? mensagem, Function? callbackErro}) {
    if (_isOpen) {
      return;
    }
    if (mensagem == null || mensagem.isEmpty) {
      mensagem = Mensagens.ERRO_PROCESSAR_REQUISICAO;
    }
    _isOpen = true;

    final ThemeData tema =
        Theme.of(ddi<GlobalKey<NavigatorState>>().currentContext!);
    final bool darkMode = ddi.get<bool>(qualifier: InjectionConstants.darkMode);

    Alert(
      context: ddi<GlobalKey<NavigatorState>>().currentContext!,
      type: AlertType.error,
      title: Mensagens.ERRO,
      desc: mensagem,
      style: _alertStyle(),
      onWillPopActive: true,
      closeFunction: () {
        _isOpen = false;
        callbackErro?.call();
      },
      buttons: [
        DialogButton(
          onPressed: () {
            close();
            callbackErro?.call();
          },
          color: darkMode ? tema.colorScheme.onSecondary : tema.primaryColor,
          width: 100,
          child: const Text(
            Mensagens.OK,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
      ],
    ).show();
  }

  static void carregando({String mensagem = Mensagens.PROCESSANDO_REQUISICAO}) {
    if (_isOpen) {
      return;
    }

    _isOpen = true;
    Alert(
      context: ddi<GlobalKey<NavigatorState>>().currentContext!,
      type: AlertType.none,
      onWillPopActive: true,
      title: Mensagens.CARREGANDO,
      closeFunction: () {
        _isOpen = false;
      },
      desc: mensagem,
      style: _alertStyle(),
    ).show();
  }

  static void vazia({
    required BuildContext context,
    required Widget content,
    bool autoClose = true,
    bool buttonDefault = true,
    AlertType type = AlertType.none,
    List<DialogButton> buttons = const [],
    String? title,
    String? mensagem,
    Function? onClose,
    AlertStyle? style,
    Function? onSucess,
  }) {
    style ??= _alertStyle();

    if (buttonDefault) {
      final ThemeData tema = Theme.of(context);
      final bool darkMode =
          ddi.get<bool>(qualifier: InjectionConstants.darkMode);

      buttons = [
        DialogButton(
          onPressed: () {
            if (autoClose) {
              close();
            }
            onSucess?.call();
          },
          color: darkMode ? tema.colorScheme.onSecondary : tema.primaryColor,
          width: 100,
          child: const Text(
            Mensagens.OK,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        DialogButton(
          onPressed: () {
            close();

            onClose?.call();
          },
          color: Colors.grey,
          width: 100,
          child: const Text(
            Mensagens.CANCELAR,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ];
    }

    _isOpen = true;
    Alert(
      context: context,
      type: type,
      onWillPopActive: true,
      title: title,
      closeFunction: () {
        close();
        onClose?.call();
      },
      desc: mensagem,
      style: style,
      content: FittedBox(
        fit: BoxFit.fitHeight,
        child: content,
      ),
      buttons: buttons,
    ).show();
  }

  static void sucesso({
    String title = '',
    String mensagem = Mensagens.EXECUTADO_SUCESSO,
    Function? onClose,
  }) {
    if (_isOpen) {
      return;
    }

    final ThemeData tema =
        Theme.of(ddi<GlobalKey<NavigatorState>>().currentContext!);
    final bool darkMode = ddi.get<bool>(qualifier: InjectionConstants.darkMode);

    _isOpen = true;
    Alert(
      context: ddi<GlobalKey<NavigatorState>>().currentContext!,
      type: AlertType.success,
      title: title,
      onWillPopActive: true,
      closeFunction: () {
        _isOpen = false;
        onClose?.call();
      },
      desc: mensagem,
      style: _alertStyle(),
      buttons: [
        DialogButton(
          onPressed: () {
            close();
            onClose?.call();
          },
          color: darkMode ? tema.colorScheme.onSecondary : tema.primaryColor,
          width: 100,
          child: const Text(
            Mensagens.OK,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ],
    ).show();
  }
}
