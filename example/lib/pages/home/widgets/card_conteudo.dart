import 'package:dart_ddi/dart_ddi.dart';
import 'package:flutter/material.dart';
import 'package:perfumei/common/components/widgets/degrade.dart';
import 'package:perfumei/common/model/grid_model.dart';
import 'package:perfumei/common/model/layout.dart';
import 'package:perfumei/pages/home/widgets/row_value.dart';

class CardConteudo extends StatelessWidget {
  const CardConteudo({required this.grid, super.key});

  final GridModel grid;

  @override
  Widget build(BuildContext context) {
    final Layout layout = ddi<Layout>();

    return Container(
      margin: const EdgeInsets.fromLTRB(87.0, 12, 5, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(height: 4),
          FittedBox(
            child: Text(
              grid.nome,
              style: layout.tituloTextStyle,
            ),
          ),
          Container(height: 10),
          Text(
            grid.marca,
            style: layout.subTituloTextStyle,
          ),
          Container(
            decoration: Degrade.efeitoDegrade(
              cores: layout.cardDegradeColors,
              begin: Alignment.centerLeft,
              end: Alignment.topRight,
            ),
            margin: const EdgeInsets.symmetric(vertical: 6),
            height: 2,
          ),
          Row(
            children: [
              Expanded(
                child: RowValue(
                  value: 'Gênero: ${grid.genero}',
                  icon: Icons.directions,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: layout.onPrimary,
                    size: 12,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(
                      grid.avaliacao,
                      style: TextStyle(
                        color: layout.onPrimary,
                        fontSize: 12,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
          Expanded(
            child: RowValue(
              value: 'Ano de Lançamento: ${grid.anoLancamento}',
              icon: Icons.info,
            ),
          ),
        ],
      ),
    );
  }
}
