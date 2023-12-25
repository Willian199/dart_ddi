class DadosPerfume {
  DadosPerfume({
    required this.id,
    required this.descricao,
    required this.notasTopo,
    required this.notasCoracao,
    required this.notasBase,
    required this.acordes,
  });
  int id;
  String descricao;
  Map<String, String> notasTopo;
  Map<String, String> notasCoracao;
  Map<String, String> notasBase;
  List<String?>? acordes;
}
