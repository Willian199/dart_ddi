import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';

class DatabaseLog with PostConstruct, PreDispose {
  DatabaseLog();

  @override
  Future<void>? onPostConstruct() async {
    await Future.delayed(const Duration(milliseconds: 10));
    print('DatabaseLog onPostConstruct');
  }

  Future<void> salvar(String mensagem) async {
    await Future.delayed(const Duration(milliseconds: 10));

    print(mensagem);
  }

  @override
  FutureOr<void> onPreDispose() async {
    await Future.delayed(const Duration(milliseconds: 10));
    print('DatabaseLog onPreDispose');
  }
}
