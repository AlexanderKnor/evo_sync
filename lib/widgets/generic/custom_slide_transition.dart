import 'package:flutter/material.dart';

class CustomSlideTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final Offset beginOffset;
  final bool fade;

  const CustomSlideTransition({
    Key? key,
    required this.animation,
    required this.child,
    this.beginOffset =
        const Offset(1.0, 0.0), // Standardmäßiger Startpunkt (von rechts)
    this.fade = true, // Option für Fade-Effekt, standardmäßig aktiviert
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final offsetTween = Tween(begin: beginOffset, end: Offset.zero)
        .chain(CurveTween(curve: Curves.ease));
    final fadeAnimation =
        CurvedAnimation(parent: animation, curve: Curves.easeInOut);

    return SlideTransition(
      position: animation.drive(offsetTween),
      child: fade
          ? FadeTransition(
              opacity: fadeAnimation,
              child: child,
            )
          : child,
    );
  }
}
