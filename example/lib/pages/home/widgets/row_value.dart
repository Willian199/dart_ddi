import 'package:dart_ddi/dart_ddi.dart';
import 'package:flutter/material.dart';
import 'package:perfumei/common/model/layout.dart';

class RowValue extends StatelessWidget {
  const RowValue({required this.value, required this.icon, super.key});
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final Layout layout = ddi<Layout>();

    return Row(
      children: <Widget>[
        Text(
          value,
          style: layout.itemsTextStyle,
        ),
      ],
    );
  }
}
