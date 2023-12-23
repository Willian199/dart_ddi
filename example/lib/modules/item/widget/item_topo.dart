import 'package:flutter/material.dart';
import 'package:perfumei/common/model/grid_model.dart';
import 'package:perfumei/modules/item/widget/descricao.dart';
import 'package:perfumei/modules/item/widget/imagem_perfume.dart';

class ItemTopo extends StatelessWidget {
  const ItemTopo({required this.item, super.key});

  final GridModel item;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final double width = MediaQuery.of(context).size.width - 140;

    return SizedBox(
      height: 500,
      child: Stack(
        children: [
          const ImagemPerfume(),
          Positioned(
            left: 0,
            top: 60,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20,
                top: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.marca,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: tema.colorScheme.tertiary,
                      fontSize: 14,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    width: width,
                    child: Text(
                      item.nome,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: tema.colorScheme.primary,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: tema.colorScheme.primaryContainer,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star,
                          color: tema.colorScheme.primary,
                          size: 12,
                        ),
                        Text(
                          item.avaliacao,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: tema.colorScheme.primary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 20),
                    width: width - 80,
                    child: const Descricao(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
