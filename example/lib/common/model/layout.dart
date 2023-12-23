import 'package:flutter/widgets.dart';

class Layout {
  Layout({
    required this.baseTextStyle,
    required this.subTituloTextStyle,
    required this.tituloTextStyle,
    required this.itemsTextStyle,
    required this.cardDegradeColors,
    required this.cardBackgroundColor,
    required this.onPrimary,
    required this.segmentedButtonSelected,
    required this.segmentedButtonDeselected,
    required this.notaUpColor,
    required this.notaDownColor,
  });

  final List<Color> cardDegradeColors;
  final TextStyle baseTextStyle;
  final TextStyle subTituloTextStyle;
  final TextStyle tituloTextStyle;
  final TextStyle itemsTextStyle;
  final Color cardBackgroundColor;
  final Color onPrimary;
  final Color segmentedButtonSelected;
  final Color segmentedButtonDeselected;
  final Color notaUpColor;
  final Color notaDownColor;
}
