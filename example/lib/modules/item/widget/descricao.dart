import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:perfumei/config/services/injection.dart';
import 'package:perfumei/modules/item/mobx/item_mobx.dart';

class Descricao extends StatelessWidget {
  const Descricao({super.key});

  @override
  Widget build(BuildContext context) {
    final ObservableItem controller = ddi();
    return Observer(builder: (_) {
      if (controller.descricao.isEmpty) {
        return const SizedBox();
      }
      return AnimatedOpacity(
        opacity: controller.descricao.isEmpty ? 0 : 1,
        duration: const Duration(milliseconds: 500),
        child: Text(
          controller.descricao,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.primary,
            fontSize: 14,
            height: 1.8,
          ),
        ),
      );
    });
  }
}
