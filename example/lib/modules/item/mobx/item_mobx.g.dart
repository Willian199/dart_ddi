// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_mobx.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ObservableItem on _ObservableItemBase, Store {
  late final _$imagemAtom =
      Atom(name: '_ObservableItemBase.imagem', context: context);

  @override
  Uint8List? get imagem {
    _$imagemAtom.reportRead();
    return super.imagem;
  }

  @override
  set imagem(Uint8List? value) {
    _$imagemAtom.reportWrite(value, super.imagem, () {
      super.imagem = value;
    });
  }

  late final _$descricaoAtom =
      Atom(name: '_ObservableItemBase.descricao', context: context);

  @override
  String get descricao {
    _$descricaoAtom.reportRead();
    return super.descricao;
  }

  @override
  set descricao(String value) {
    _$descricaoAtom.reportWrite(value, super.descricao, () {
      super.descricao = value;
    });
  }

  late final _$tabSelecionadaAtom =
      Atom(name: '_ObservableItemBase.tabSelecionada', context: context);

  @override
  Set<NotasEnum> get tabSelecionada {
    _$tabSelecionadaAtom.reportRead();
    return super.tabSelecionada;
  }

  @override
  set tabSelecionada(Set<NotasEnum> value) {
    _$tabSelecionadaAtom.reportWrite(value, super.tabSelecionada, () {
      super.tabSelecionada = value;
    });
  }

  late final _$pageAtom =
      Atom(name: '_ObservableItemBase.page', context: context);

  @override
  int get page {
    _$pageAtom.reportRead();
    return super.page;
  }

  @override
  set page(int value) {
    _$pageAtom.reportWrite(value, super.page, () {
      super.page = value;
    });
  }

  late final _$acordesAtom =
      Atom(name: '_ObservableItemBase.acordes', context: context);

  @override
  List<String?>? get acordes {
    _$acordesAtom.reportRead();
    return super.acordes;
  }

  @override
  set acordes(List<String?>? value) {
    _$acordesAtom.reportWrite(value, super.acordes, () {
      super.acordes = value;
    });
  }

  late final _$notasTopoAtom =
      Atom(name: '_ObservableItemBase.notasTopo', context: context);

  @override
  Map<String, String>? get notasTopo {
    _$notasTopoAtom.reportRead();
    return super.notasTopo;
  }

  @override
  set notasTopo(Map<String, String>? value) {
    _$notasTopoAtom.reportWrite(value, super.notasTopo, () {
      super.notasTopo = value;
    });
  }

  late final _$notasCoracaoAtom =
      Atom(name: '_ObservableItemBase.notasCoracao', context: context);

  @override
  Map<String, String>? get notasCoracao {
    _$notasCoracaoAtom.reportRead();
    return super.notasCoracao;
  }

  @override
  set notasCoracao(Map<String, String>? value) {
    _$notasCoracaoAtom.reportWrite(value, super.notasCoracao, () {
      super.notasCoracao = value;
    });
  }

  late final _$notasBaseAtom =
      Atom(name: '_ObservableItemBase.notasBase', context: context);

  @override
  Map<String, String>? get notasBase {
    _$notasBaseAtom.reportRead();
    return super.notasBase;
  }

  @override
  set notasBase(Map<String, String>? value) {
    _$notasBaseAtom.reportWrite(value, super.notasBase, () {
      super.notasBase = value;
    });
  }

  late final _$_ObservableItemBaseActionController =
      ActionController(name: '_ObservableItemBase', context: context);

  @override
  void changeImagem(Uint8List value) {
    final _$actionInfo = _$_ObservableItemBaseActionController.startAction(
        name: '_ObservableItemBase.changeImagem');
    try {
      return super.changeImagem(value);
    } finally {
      _$_ObservableItemBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void pageChange(int value) {
    final _$actionInfo = _$_ObservableItemBaseActionController.startAction(
        name: '_ObservableItemBase.pageChange');
    try {
      return super.pageChange(value);
    } finally {
      _$_ObservableItemBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void changeTabSelecionada(Set<NotasEnum> value) {
    final _$actionInfo = _$_ObservableItemBaseActionController.startAction(
        name: '_ObservableItemBase.changeTabSelecionada');
    try {
      return super.changeTabSelecionada(value);
    } finally {
      _$_ObservableItemBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
imagem: ${imagem},
descricao: ${descricao},
tabSelecionada: ${tabSelecionada},
page: ${page},
acordes: ${acordes},
notasTopo: ${notasTopo},
notasCoracao: ${notasCoracao},
notasBase: ${notasBase}
    ''';
  }
}
