import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:perfumei/common/components/notification/notificacao.dart';
import 'package:perfumei/common/enum/notas_enum.dart';
import 'package:perfumei/common/features/html_decode_page.dart';
import 'package:perfumei/common/features/remove_background.dart';
import 'package:perfumei/common/model/dados_perfume.dart';
import 'package:perfumei/config/services/dio/request_service.dart';

part 'item_mobx.g.dart';

class ObservableItem = _ObservableItemBase with _$ObservableItem;

abstract class _ObservableItemBase with Store {
  final PageController pageController = PageController(
    initialPage: NotasEnum.TOPO.posicao,
  );

  @observable
  Uint8List? imagem;

  @observable
  String descricao = '';

  @observable
  Set<NotasEnum> tabSelecionada = {NotasEnum.TOPO};

  @observable
  int page = NotasEnum.TOPO.posicao;

  @observable
  List<String?>? acordes;

  @observable
  Map<String, String>? notasTopo;

  @observable
  Map<String, String>? notasCoracao;

  @observable
  Map<String, String>? notasBase;

  @action
  void changeImagem(Uint8List value) {
    imagem = value;
  }

  @action
  void pageChange(int value) {
    final NotasEnum? obj = NotasEnum.forIndex(value);

    if (obj != null) {
      tabSelecionada = {obj};
      page = value;
    }
  }

  @action
  void changeTabSelecionada(Set<NotasEnum> value) {
    tabSelecionada = value;
    page = value.first.posicao;
    _navigate();
  }

  void _navigate() {
    pageController.animateToPage(page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn);
  }

  void clear() {
    descricao = '';
    acordes = null;
    notasTopo = null;
    notasCoracao = null;
    notasBase = null;
    imagem = null;
    page = 0;
    tabSelecionada = {NotasEnum.TOPO};
  }

  void carregarHtml(String link) async {
    final retorno = await RequestService.getHtml(url: link);

    //Cria uma Thread para evitar lag no app
    final DadosPerfume perfume =
        await compute(HtmlDecodePage.decode, retorno.data.toString());

    descricao = perfume.descricao;

    acordes = perfume.acordes;

    notasTopo = perfume.notasTopo;

    notasCoracao = perfume.notasCoracao;

    notasBase = perfume.notasBase;
  }

  void carregarImagem(Uint8List? bytes) async {
    imagem = await compute(RemoveBackGround.removeWhiteBackground, bytes);

    Notificacao.close();
  }
}
