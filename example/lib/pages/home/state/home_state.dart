// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:perfumei/common/enum/genero_enum.dart';

class HomeState {
  HomeState({
    required this.tabSelecionada,
    this.pesquisa = '',
    this.dataChange = false,
  });

  final String pesquisa;
  final Set<Genero> tabSelecionada;
  final bool dataChange;

  HomeState copyWith({
    String? pesquisa,
    Set<Genero>? tabSelecionada,
    bool? dataChange,
  }) {
    return HomeState(
      pesquisa: pesquisa ?? this.pesquisa,
      tabSelecionada: tabSelecionada ?? this.tabSelecionada,
      dataChange: dataChange ?? this.dataChange,
    );
  }
}
