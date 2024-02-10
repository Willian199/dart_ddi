import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perfumei/common/components/notification/notificacao.dart';
import 'package:perfumei/common/features/remove_background.dart';

class ImagemCubit extends Cubit<bool> {
  ImagemCubit() : super(true);

  Uint8List? _imagem;

  Uint8List? get imagem => _imagem;

  void carregarImagem(Uint8List? bytes) async {
    _imagem = await compute(RemoveBackGround.removeWhiteBackground, bytes);

    emit(!state);

    Notificacao.close();
  }
}
