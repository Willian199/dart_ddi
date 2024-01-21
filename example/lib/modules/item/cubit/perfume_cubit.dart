import 'package:flutter/foundation.dart';
import 'package:perfumei/common/cubit_features/cubit_event_sender.dart';
import 'package:perfumei/common/enum/notas_enum.dart';
import 'package:perfumei/common/features/html_decode_page.dart';
import 'package:perfumei/common/model/dados_perfume.dart';
import 'package:perfumei/config/services/dio/request_service.dart';
import 'package:perfumei/modules/item/state/perfume_state.dart';

class PerfumeCubit extends CubitSender<PerfumeState> {
  PerfumeCubit() : super(PerfumeState(page: NotasEnum.TOPO.posicao));

  void carregarHtml(String link) async {
    final retorno = await RequestService.getHtml(url: link);

    //Cria uma Thread para evitar lag no app
    final DadosPerfume perfume =
        await compute(HtmlDecodePage.decode, retorno.data.toString());

    emit(state.copyWith(dadosPerfume: perfume), suppresListener: true);
  }

  void pageChange(int value) {
    emit(state.copyWith(page: value));
  }
}
