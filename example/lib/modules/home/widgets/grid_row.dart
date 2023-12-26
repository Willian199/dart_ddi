import 'package:flutter/material.dart';
import 'package:perfumei/common/components/widgets/cache_image.dart';
import 'package:perfumei/common/model/grid_model.dart';
import 'package:perfumei/common/model/layout.dart';
import 'package:perfumei/config/services/injection.dart';
import 'package:perfumei/modules/home/widgets/card_conteudo.dart';

class GridRow extends StatelessWidget {
  const GridRow({
    required this.grid,
    required this.onPressed,
    super.key,
    this.icon,
  });
  final GridModel grid;
  final IconData? icon;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    final Layout layout = ddi<Layout>();

    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: Container(
            height: 135.0,
            margin: const EdgeInsets.only(left: 50.0),
            decoration: BoxDecoration(
              color: layout.cardBackgroundColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 10,
                  offset: Offset(10, 10),
                ),
              ],
            ),
            child: MaterialButton(
              highlightElevation: 3,
              animationDuration: const Duration(seconds: 10),
              onPressed: () => onPressed(grid),
              child: CardConteudo(grid: grid),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: CacheImagem(
            imagemUrl: grid.capa,
            imagemBuilder: (context, imageProvider) {
              return Center(
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage: imageProvider,
                  radius: 60,
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
