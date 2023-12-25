import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:perfumei/common/components/button_navigation/button_neomorphism.dart';
import 'package:perfumei/common/components/notification/notificacao.dart';
import 'package:perfumei/common/constants/injection_constants.dart';
import 'package:perfumei/common/constants/mensagens.dart';
import 'package:perfumei/config/services/injection.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class NotificacaoPadrao {
  static void semInternet({void Function()? callbackErro}) {
    _default(
      asset: "assets/no_internet.json",
      mensagem: Mensagens.SEM_INTERNET,
      callbackErro: callbackErro,
    );
  }

  static void connectionTimeout({Function? callbackErro}) {
    _default(
        asset: "assets/connection_timeout.json",
        mensagem: Mensagens.SEM_CONEXAO,
        callbackErro: callbackErro,
        repeat: true);
  }

  static void responseTimeout({Function? callbackErro}) {
    _default(
        asset: "assets/response_timeout.json",
        mensagem: Mensagens.SEM_RESPOSTA,
        callbackErro: callbackErro,
        repeat: true);
  }

  static void badRequest({required String mensagem, Function? callbackErro}) {
    _default(
        asset: "assets/bad_request.json",
        mensagem: mensagem,
        callbackErro: callbackErro,
        repeat: true);
  }

  static void semDados({Function? callbackErro}) {
    _default(
      asset: "assets/no_data.json",
      mensagem: Mensagens.NAO_HA_DADOS,
      callbackErro: callbackErro,
    );
  }

  static void custom({
    required String mensagem,
    required String asset,
    Function? callbackErro,
  }) {
    _default(
      asset: 'assets/$asset.json',
      mensagem: mensagem,
      callbackErro: callbackErro,
    );
  }

  static void carregando() {
    final BuildContext context =
        ddi<GlobalKey<NavigatorState>>().currentContext!;
    final ThemeData tema = Theme.of(context);

    Notificacao.vazia(
      context: context,
      buttonDefault: false,
      content: SizedBox(
        height: 200,
        width: 300,
        child: Lottie.asset(
          "assets/loading.json",
          fit: BoxFit.scaleDown,
          frameRate: FrameRate.max,
          height: 200,
          repeat: true,
        ),
      ),
      style: AlertStyle(
        constraints: const BoxConstraints(minHeight: 200),
        animationType: AnimationType.grow,
        isCloseButton: false,
        isOverlayTapDismiss: false,
        backgroundColor: Colors.transparent,
        animationDuration: const Duration(milliseconds: 300),
        overlayColor: tema.colorScheme.secondaryContainer.withOpacity(0.4),
        alertElevation: 0,
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  static void _default({
    required String asset,
    required String mensagem,
    Function? callbackErro,
    bool repeat = false,
  }) {
    Notificacao.close();

    final BuildContext context =
        ddi<GlobalKey<NavigatorState>>().currentContext!;

    final ThemeData tema = Theme.of(context);
    final bool darkMode = ddi.get(qualifierName: InjectionConstants.darkMode);

    final Color buttonColor =
        darkMode ? tema.colorScheme.onSecondary : tema.colorScheme.secondary;

    Notificacao.vazia(
        context: context,
        buttonDefault: false,
        onClose: callbackErro,
        content: Column(
          children: [
            Lottie.asset(
              asset,
              fit: BoxFit.scaleDown,
              frameRate: FrameRate.max,
              height: 200,
              repeat: repeat,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                mensagem,
                style: TextStyle(
                  color: darkMode ? Colors.white : tema.colorScheme.onSecondary,
                  fontSize: 15,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ButtonNeomorphism(
                backgroundColor: buttonColor,
                lightColor:
                    buttonColor.withAlpha(50).withBlue(10).withGreen(50),
                darkColor:
                    buttonColor.withAlpha(50).withBlue(250).withGreen(50),
                child: Center(
                  child: Text(
                    Mensagens.OK,
                    style: TextStyle(
                      color:
                          darkMode ? Colors.white : tema.colorScheme.onPrimary,
                    ),
                  ),
                ),
                callback: () {
                  Notificacao.close();
                  callbackErro?.call();
                },
              ),
            )
          ],
        ));
  }
}
