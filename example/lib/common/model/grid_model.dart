class GridModel {
  GridModel.fromJson(json) {
    id = json["objectID"].toString();
    capa = setImagem(json["objectID"].toString());
    marca = json["dizajner"].toString();
    anoLancamento = json["godina"].toString();
    genero = setGenero(json["spol"].toString());
    avaliacao = setAvaliacao(json['rating'].toString());
    nome = setNome(json["naslov"].toString());
    link = json["url"]["PT"][0].toString();
  }

  late String id;
  late String nome;
  late String marca;
  late String genero;
  late String capa;
  late String anoLancamento;
  late String avaliacao;
  late String link;

  String setGenero(String info) {
    String retorno = '';
    switch (info) {
      case 'male':
        retorno = 'Masculino';
        break;
      case 'female':
        retorno = 'Feminino';
        break;
      case 'unisex':
        retorno = 'Unissex';
        break;
    }
    return retorno;
  }

  String setImagem(String id) {
    return 'https://fimgs.net/mdimg/perfume/375x500.$id.jpg';
  }

  String setNome(String nome) {
    return nome
        .replaceAll('Eau de Parfum', 'EDP')
        .replaceAll('Eau de Toilette', 'EDT')
        .replaceAll(marca, '')
        .replaceAll(anoLancamento, '')
        .replaceAll('()', '')
        .trim();
  }

  String setAvaliacao(String avaliacao) {
    return avaliacao == '0' ? 'N/A' : avaliacao.padRight(4, '0').substring(0, 4);
  }
}
