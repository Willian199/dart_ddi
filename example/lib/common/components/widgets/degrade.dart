import 'package:flutter/material.dart';

class Degrade {
  Degrade();

  ///
  /// @return BoxDecoration()
  ///
  static BoxDecoration efeitoDegrade(
      {List<Color> cores = const [Color.fromRGBO(21, 101, 192, 1), Color.fromRGBO(130, 177, 255, 1)],
      Alignment begin = Alignment.topCenter,
      Alignment end = Alignment.bottomCenter}) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: cores,
        begin: begin,
        end: end,
      ),
    );
  }

  ///
  /// @return Container()
  ///
  static Widget containerEfeitoDegrade({List<Color>? cores, Alignment? begin, Alignment? end}) {
    return Container(
      decoration: efeitoDegrade(
        cores: cores!,
        begin: begin!,
        end: end!,
      ),
    );
  }
}
