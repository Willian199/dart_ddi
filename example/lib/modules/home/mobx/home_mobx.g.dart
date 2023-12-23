// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_mobx.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ObservableHome on _ObservableHomeBase, Store {
  late final _$pesquisaAtom =
      Atom(name: '_ObservableHomeBase.pesquisa', context: context);

  @override
  String get pesquisa {
    _$pesquisaAtom.reportRead();
    return super.pesquisa;
  }

  @override
  set pesquisa(String value) {
    _$pesquisaAtom.reportWrite(value, super.pesquisa, () {
      super.pesquisa = value;
    });
  }

  late final _$tabSelecionadaAtom =
      Atom(name: '_ObservableHomeBase.tabSelecionada', context: context);

  @override
  Set<Genero> get tabSelecionada {
    _$tabSelecionadaAtom.reportRead();
    return super.tabSelecionada;
  }

  @override
  set tabSelecionada(Set<Genero> value) {
    _$tabSelecionadaAtom.reportWrite(value, super.tabSelecionada, () {
      super.tabSelecionada = value;
    });
  }

  late final _$dadosAtom =
      Atom(name: '_ObservableHomeBase.dados', context: context);

  @override
  List<dynamic>? get dados {
    _$dadosAtom.reportRead();
    return super.dados;
  }

  @override
  set dados(List<dynamic>? value) {
    _$dadosAtom.reportWrite(value, super.dados, () {
      super.dados = value;
    });
  }

  late final _$_ObservableHomeBaseActionController =
      ActionController(name: '_ObservableHomeBase', context: context);

  @override
  void changePesquisa(String value) {
    final _$actionInfo = _$_ObservableHomeBaseActionController.startAction(
        name: '_ObservableHomeBase.changePesquisa');
    try {
      return super.changePesquisa(value);
    } finally {
      _$_ObservableHomeBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void changeTabSelecionada(Set<Genero> value) {
    final _$actionInfo = _$_ObservableHomeBaseActionController.startAction(
        name: '_ObservableHomeBase.changeTabSelecionada');
    try {
      return super.changeTabSelecionada(value);
    } finally {
      _$_ObservableHomeBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
pesquisa: ${pesquisa},
tabSelecionada: ${tabSelecionada},
dados: ${dados}
    ''';
  }
}
