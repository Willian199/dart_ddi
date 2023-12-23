import 'package:flutter/material.dart';

class SlideAnimation extends StatefulWidget {
  const SlideAnimation({required this.child, super.key});
  final Widget child;

  @override
  State<SlideAnimation> createState() => _SlideAnimationState();
}

class _SlideAnimationState extends State<SlideAnimation>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: const Offset(0, 0),
      ).animate(CurvedAnimation(
        parent: AnimationController(
          duration: const Duration(seconds: 1),
          vsync: this,
        )..forward(),
        curve: Curves.easeInCubic,
      )),
      child: widget.child,
    );
  }
}
