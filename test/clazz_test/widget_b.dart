import 'package:flutter/material.dart';

import 'widget_c.dart';

class WidgetB extends StatelessWidget {
  const WidgetB({required this.widgetC, super.key});
  final WidgetC widgetC;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
