// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:perfumei/common/model/dados_perfume.dart';

class PerfumeState {
  PerfumeState({
    this.dadosPerfume,
  });

  final DadosPerfume? dadosPerfume;

  PerfumeState copyWith({
    DadosPerfume? dadosPerfume,
  }) {
    return PerfumeState(
      dadosPerfume: dadosPerfume ?? this.dadosPerfume,
    );
  }
}
