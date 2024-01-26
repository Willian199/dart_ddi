import 'package:perfumei/common/cubit_features/cubit_event_listener.dart';
import 'package:perfumei/common/enum/notas_enum.dart';
import 'package:perfumei/modules/item/state/perfume_state.dart';
import 'package:perfumei/modules/item/state/tab_state.dart';

class TabCubit extends CubitListener<TabState, PerfumeState> {
  TabCubit()
      : super(
          TabState(
            page: NotasEnum.TOPO.posicao,
            tabSelecionada: {NotasEnum.TOPO},
          ),
        );

  @override
  void onEvent(PerfumeState listen) {
    print('eventos');
    final NotasEnum? obj = NotasEnum.forIndex(listen.page);

    if (obj != null && state.page != listen.page) {
      emit(state.copyWith(page: obj.posicao, tabSelecionada: {obj}));
    }
  }

  void changeTabSelecionada(Set<NotasEnum> value) {
    emit(state.copyWith(page: value.first.posicao, tabSelecionada: value));
  }
}
