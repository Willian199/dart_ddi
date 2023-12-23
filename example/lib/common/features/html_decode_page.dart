import 'dart:async';

import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:perfumei/common/model/dados_perfume.dart';

class HtmlDecodePage {
  static FutureOr<DadosPerfume> decode(String html) {
    final Document document = parse(html);

    //Não foi possivel pegar os valores dos gráficos
    /*var gosto = document
        .getElementById("main-content")
        ?.getElementsByClassName("grid-x grid-margin-x grid-margin-y")[3]
        .nodes[0];
    var estacao = document
        .getElementById("main-content")
        ?.getElementsByClassName("grid-x grid-margin-x grid-margin-y")[3]
        .nodes[1];
    var logevidade = document
        .getElementById("main-content")
        ?.getElementsByClassName("cell small-12")[23];
    var projecao = document
        .getElementById("main-content")
        ?.getElementsByClassName("cell small-12")[24];
    var genero = document
        .getElementById("main-content")
        ?.getElementsByClassName("cell small-12")[25];
    var preco = document
        .getElementById("main-content")
        ?.getElementsByClassName("cell small-12")[26];*/

    final List<String?> acordes =
        document.getElementById("main-content")?.getElementsByClassName("cell small-6")[1].nodes[2].nodes.map((item) => item.text).toList() ?? [];

    final Node? nodeNotas = document.getElementById("pyramid")?.nodes.first.nodes.first.nodes[1];

    return DadosPerfume(
      id: 1,
      descricao: _processarDescricao(document),
      acordes: acordes,
      notasTopo: _processarNotasTopo(nodeNotas),
      notasCoracao: _processarNotasCoracao(nodeNotas),
      notasBase: _processarNotasBase(nodeNotas),
    );
  }

  static String _processarDescricao(Document document) {
    final String? descricao = document.getElementById("main-content")?.getElementsByClassName("reviewstrigger").first.parent?.firstChild?.text;

    if (descricao?.isEmpty ?? true) {
      return "O Perfume não possui uma descrição";
    } else {
      //Para remover redundância de informações na descrição
      if (descricao?.contains("As notas de topo são:") ?? false) {
        return descricao?.split("As notas de topo são:").first ?? '';
      }

      return descricao?.split("A nota de topo é").first ?? '';
    }
  }

  static Map<String, String> _processarNotasTopo(Node? node) {
    late NodeList? nodeTopo;
    if ((node?.nodes.length ?? 0) > 2) {
      nodeTopo = node?.nodes[2].nodes.first.nodes;
    } else {
      nodeTopo = node?.nodes[1].nodes.first.nodes;
    }

    return _getItem(nodeTopo);
  }

  static Map<String, String> _processarNotasBase(Node? node) {
    late NodeList? nodeBase;
    if ((node?.nodes.length ?? 0) > 6) {
      nodeBase = node?.nodes[6].nodes.first.nodes;
    } else {
      nodeBase = node?.nodes[1].nodes.first.nodes;
    }

    return _getItem(nodeBase);
  }

  static Map<String, String> _processarNotasCoracao(Node? node) {
    late NodeList? nodeCoracao;
    if ((node?.nodes.length ?? 0) > 4) {
      nodeCoracao = node?.nodes[4].nodes.first.nodes;
    } else {
      nodeCoracao = node?.nodes[1].nodes.first.nodes;
    }

    return _getItem(nodeCoracao);
  }

  static Map<String, String> _getItem(NodeList? node) {
    final Map<String, String> map = {};
    if (node != null) {
      for (var item in node) {
        final String nome = item.text!;
        final String link = item.firstChild?.nodes.first.attributes['src'] ?? '';

        map[nome] = link;
      }
    }
    return map;
  }
}
