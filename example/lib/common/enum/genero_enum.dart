import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum Genero {
  MASCULINO('male', FontAwesomeIcons.mars),
  FEMININO('female', FontAwesomeIcons.venus),
  UNISEX('unisex', FontAwesomeIcons.marsAndVenus),
  TODOS('', FontAwesomeIcons.peopleGroup);

  const Genero(this.nome, this.icone);
  final String nome;
  final IconData icone;

  static final Map<String, Genero> _types = Map.fromEntries(Genero.values.map((value) => MapEntry(value.nome, value)));

  static Genero? forValue(String value) => _types[value];
}
