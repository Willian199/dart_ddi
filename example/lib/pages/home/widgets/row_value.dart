import 'package:flutter/material.dart';
import 'package:perfumei/common/model/layout.dart';
import 'package:perfumei/config/services/injection.dart';

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
