import 'package:dart_ddi/dart_di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:perfumei/common/components/widgets/slide_animation.dart';
import 'package:perfumei/modules/item/mobx/item_mobx.dart';

class ImagemPerfume extends StatelessWidget {
  const ImagemPerfume({super.key});

  @override
  Widget build(BuildContext context) {
    final ObservableItem controller = context.ddi();
    return Observer(builder: (_) {
      if (controller.imagem?.isNotEmpty ?? false) {
        return Positioned(
          right: 0,
          top: 30,
          child: SizedBox(
            width: 190,
            child: SlideAnimation(
              child: Image.memory(
                controller.imagem!,
              ),
            ),
          ),
        );
      }
      return const SizedBox();
    });
  }
}
