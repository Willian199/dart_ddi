import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perfumei/common/components/widgets/slide_animation.dart';
import 'package:perfumei/config/services/injection.dart';
import 'package:perfumei/modules/item/cubit/imagem_cubit.dart';

class ImagemPerfume extends StatefulWidget {
  const ImagemPerfume({this.bytes, super.key});
  final Uint8List? bytes;

  @override
  State<ImagemPerfume> createState() => _ImagemPerfumeState();
}

class _ImagemPerfumeState extends State<ImagemPerfume> {
  final ImagemCubit _cubit = ddi();

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      _cubit.carregarImagem(widget.bytes);
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('building ImagemPerfume');
    return BlocProvider<ImagemCubit>(
      create: (_) => _cubit,
      child: BlocBuilder<ImagemCubit, bool>(
        builder: (_, __) {
          if (_cubit.imagem?.isNotEmpty ?? false) {
            return Positioned(
              right: 0,
              top: 30,
              child: SizedBox(
                width: 190,
                child: SlideAnimation(
                  child: Image.memory(
                    _cubit.imagem!,
                  ),
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
