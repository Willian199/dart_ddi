// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:perfumei/common/enum/notas_enum.dart';

class TabState {
  TabState({
    required this.page,
    required this.tabSelecionada,
  });

  final Set<NotasEnum> tabSelecionada;
  final int page;

  TabState copyWith({
    Set<NotasEnum>? tabSelecionada,
    int? page,
  }) {
    return TabState(
      tabSelecionada: tabSelecionada ?? this.tabSelecionada,
      page: page ?? this.page,
    );
  }
}
