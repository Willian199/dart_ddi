import 'package:flutter/material.dart';

class ButtonNeomorphism extends StatefulWidget {
  const ButtonNeomorphism({
    required this.backgroundColor,
    required this.lightColor,
    required this.darkColor,
    this.height = 50,
    this.width = 100,
    this.callback,
    this.child,
    super.key,
  });
  final Function? callback;
  final double height;
  final double width;

  ///Mesma cor de background do componente pai
  final Color backgroundColor;

  ///Mesma cor do background, porém levemente mais clara
  final Color lightColor;

  ///Mesma cor do background, porém levemente mais escura
  final Color darkColor;
  final Widget? child;

  @override
  State<ButtonNeomorphism> createState() => _ButtonneomoNphismState();
}

class _ButtonneomoNphismState extends State<ButtonNeomorphism> {
  bool _isElevated = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isElevated = !_isElevated;
        });

        if (widget.callback != null) {
          widget.callback!();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 200,
        ),
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(50),
          boxShadow: _isElevated
              ? [
                  BoxShadow(
                    color: widget.darkColor,
                    offset: const Offset(4, 4),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: widget.lightColor,
                    offset: const Offset(-4, -4),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: widget.child,
      ),
    );
  }
}
