import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///Componente genérico para Fields

class GenericField extends StatelessWidget {
  /// Contrutor da classe
  const GenericField({
    required this.controller,
    required this.focus,
    super.key,
    this.onChanged,
    this.onFinish,
    this.obscureText = false,
    this.labelText = 'INFORME O LABEL TEXT',
    this.textoEsquerda = true,
    this.quantidadeMaximaCaracteres = 19,
    this.validator,
    this.inputIcon,
    this.decoration,
    this.expands = false,
    this.minLines,
    this.autoFocus = false,
    this.maxLines,
    this.obrigatorio = false,
    this.inputFormatters = const [],
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.words,
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
  final bool autoFocus;
  final InputDecoration? decoration;
  final Widget? inputIcon;
  final bool obscureText;
  final bool expands;
  final int? minLines;
  final int? maxLines;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter> inputFormatters;
  final Color cursorColor;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focus,
      onChanged: onChanged,
      onEditingComplete: onFinish,
      style: textStyle,
      textAlign: textoEsquerda ? TextAlign.left : TextAlign.right,
      obscureText: obscureText,
      expands: expands,
      minLines: minLines,
      maxLines: maxLines,
      enableInteractiveSelection: true,
      enabled: true,
      autofocus: autoFocus,
      cursorColor: cursorColor,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      textAlignVertical: TextAlignVertical.top,
      inputFormatters: inputFormatters,
      decoration: decoration ??
          InputDecoration(
            isDense: true,
            icon: inputIcon,
            labelText: labelText,
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            errorMaxLines: 1,
          ),
      validator: (String? value) {
        String? retorno;
        if (obrigatorio && (value?.isEmpty ?? true)) {
          retorno = 'CAMPO OBRIGATÓRIO';
        }

        retorno = validator?.call(value!);

        return retorno;
      },
    );
  }
}
