import 'package:flutter/material.dart';

import 'widget_b.dart';

class WidgetA extends StatelessWidget {
  final WidgetB widgetB;
  const WidgetA({required this.widgetB, super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
