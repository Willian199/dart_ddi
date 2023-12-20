import 'package:flutter/material.dart';

import 'widget_b.dart';

class WidgetA extends StatelessWidget {
  const WidgetA({required this.widgetB, super.key});
  final WidgetB widgetB;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
