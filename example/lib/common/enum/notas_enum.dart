enum NotasEnum {
  TOPO('TOPO', 0),
  CORACAO('CORAÇÃO', 1),
  BASE('BASE', 2);

  const NotasEnum(this.nome, this.posicao);
  final String nome;
  final int posicao;

  static final Map<String, NotasEnum> _findByNome = Map.fromEntries(NotasEnum.values.map((value) => MapEntry(value.nome, value)));

  static final Map<int, NotasEnum> _findByPosicao = Map.fromEntries(NotasEnum.values.map((value) => MapEntry(value.posicao, value)));

  static NotasEnum? forValue(String value) => _findByNome[value];

  static NotasEnum? forIndex(int value) => _findByPosicao[value];
}
