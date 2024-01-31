import 'package:dart_ddi/dart_ddi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perfumei/common/enum/notas_enum.dart';
import 'package:perfumei/modules/item/state/tab_state.dart';

class TabCubit extends Cubit<TabState> with PostConstruct {
  TabCubit()
      : super(
          TabState(
            page: NotasEnum.TOPO.posicao,
            tabSelecionada: {NotasEnum.TOPO},
          ),
        );

  void changeTabSelecionada(Set<NotasEnum> value) {
    emit(state.copyWith(page: value.first.posicao, tabSelecionada: value));
  }

  @override
  void onPostConstruct() {
    DDIStream.instance.subscribe<int>(
      qualifier: 'page_view',
      callback: (int newPAge) {
        debugPrint('pageChange');
        final NotasEnum? notaEnum = NotasEnum.forIndex(newPAge);

        if (notaEnum != null) {
          emit(state.copyWith(page: newPAge, tabSelecionada: {notaEnum}));
        }
      },
    );
  }

  @override
  Future<void> close() async {
    debugPrint('Destruindo a stream teste');
    DDIStream.instance.close(qualifier: 'teste');
    super.close();
  }
}
