import 'package:dart_ddi/dart_ddi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perfumei/common/components/notification/notificacao.dart';
import 'package:perfumei/common/components/notification/notificacao_padrao.dart';
import 'package:perfumei/common/enum/genero_enum.dart';
import 'package:perfumei/config/services/dio/request_service.dart';
import 'package:perfumei/modules/home/state/home_state.dart';

class HomeCubit extends Cubit<HomeState> with PostConstruct {
  HomeCubit() : super(HomeState(tabSelecionada: {Genero.TODOS}));
  TextEditingController pesquisaController = TextEditingController();
  FocusNode pesquisaFocus = FocusNode();

  List? dados;

  @override
  void onPostConstruct() {
    Future.delayed(const Duration(milliseconds: 1), () {
      carregarDados();
    });
  }

  void changePesquisa(String value) {
    emit(state.copyWith(pesquisa: value));
  }

  void changeTabSelecionada(Set<Genero> value) {
    emit(state.copyWith(tabSelecionada: value));
    pesquisaFocus.unfocus();
  }

  void carregarDados() async {
    pesquisaFocus.unfocus();
    NotificacaoPadrao.carregando();

    const String attributesToRetrieve =
        '["naslov","dizajner","godina","url.PT","rating","spol"]';

    const String facets =
        '"spol","dizajner","godina","ingredients.PT","rating_rounded","nosevi","osobine.PT","designer_meta.country","designer_meta.category","designer_meta.parent_company","designer_meta.main_activity"]';

    final String filter = state.tabSelecionada.first.nome.isEmpty
        ? ''
        : 'facetFilters=%5B%5B%22spol%3A${state.tabSelecionada.first.nome}%22%5D%5D&';

    const String highlight =
        'highlightPostTag=__/ais-highlight__&highlightPreTag=__ais-highlight__';

    const String hitsPerPage = 'hitsPerPage=80&maxValuesPerFacet=10';

    const String page = 'page=0&tagFilters=';

    String params =
        'attributesToRetrieve=$attributesToRetrieve&facets=$facets&$filter';

    params += '$highlight&$hitsPerPage&$page';

    params += '&query=${state.pesquisa}';

    final obj = {
      "requests": [
        {"indexName": "fragrantica_perfumes", "params": params}
      ]
    };

    const String applicationId = 'FGVI612DFZ';
    const String applicatinoKey =
        'MzM1YmRkM2RhNjllNzU5YmEyMmFjNjA0MGZmOWMwNzk1MzYwNWYwOTg4ZThkNDM1NDM0MWM2ODk4OTQxMjZkYnZhbGlkVW50aWw9MTcwNjY0MjAwNg==';

    final retorno = await RequestService.post(
        url:
            '/1/indexes/*/queries?x-algolia-api-key=$applicatinoKey&x-algolia-application-id=$applicationId',
        data: obj,
        usarCache: true,
        callbackErro: () {
          dados = [];
          emit(state.copyWith(dataChange: !state.dataChange));
        });

    dados = retorno.data['results'][0]['hits'] as List;

    emit(state.copyWith(dataChange: !state.dataChange));

    Future.delayed(const Duration(milliseconds: 500), () {
      Notificacao.close();
      pesquisaFocus.unfocus();
    });
  }
}
