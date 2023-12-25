import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:perfumei/common/components/fields/generic_field.dart';

///Esse componente somente aceita números e letras

class AlphaNumericField extends StatelessWidget {
  /// Contrutor da classe
  ///
  const AlphaNumericField({
    required this.controller,
    required this.focus,
    super.key,
    this.onChanged,
    this.onFinish,
    this.labelText = 'INFORME O LABEL TEXT',
    this.textoEsquerda = true,
    this.quantidadeMaximaCaracteres = 50,
    this.validator,
    this.inputIcon,
    this.decoration,
    this.permiteNumeros = true,
    this.obrigatorio = false,
    this.autoFocus = false,
    this.textStyle = const TextStyle(color: Colors.black),
    this.cursorColor = Colors.black,
  });
  final TextEditingController controller;
  final FocusNode focus;
  final void Function(String)? onChanged;
  final void Function()? onFinish;
  final String? Function(String?)? validator;
  final TextStyle textStyle;
  final String labelText;
  final bool textoEsquerda;
  final int quantidadeMaximaCaracteres;
  final bool obrigatorio;
  final bool permiteNumeros;
  final bool autoFocus;
  final InputDecoration? decoration;
  final Widget? inputIcon;
  final Color cursorColor;

  @override
  Widget build(BuildContext context) {
    return GenericField(
      controller: controller,
      focus: focus,
      textoEsquerda: textoEsquerda,
      validator: validator,
      quantidadeMaximaCaracteres: quantidadeMaximaCaracteres,
      inputIcon: inputIcon,
      labelText: labelText,
      inputFormatters: [
        LengthLimitingTextInputFormatter(quantidadeMaximaCaracteres),
        FilteringTextInputFormatter.allow(
            permiteNumeros ? RegExp('[a-zA-Z0-9 ]') : RegExp('[a-zA-Z ]')),
      ],
      decoration: decoration,
      onChanged: onChanged,
      onFinish: onFinish,
      obrigatorio: obrigatorio,
      textCapitalization: TextCapitalization.none,
      textStyle: textStyle,
      minLines: 1,
      maxLines: 1,
      autoFocus: autoFocus,
      cursorColor: cursorColor,
    );
  }
}
