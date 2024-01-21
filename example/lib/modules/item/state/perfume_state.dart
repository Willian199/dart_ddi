// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:perfumei/common/model/dados_perfume.dart';

class PerfumeState {
  PerfumeState({
    required this.page,
    this.dadosPerfume,
  });

  final DadosPerfume? dadosPerfume;

  final int page;

  PerfumeState copyWith({
    DadosPerfume? dadosPerfume,
    int? page,
  }) {
    return PerfumeState(
      dadosPerfume: dadosPerfume ?? this.dadosPerfume,
      page: page ?? this.page,
    );
  }
}
