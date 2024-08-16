import 'package:flutter/material.dart';

class SlideFadeTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const SlideFadeTransition({
    Key? key,
    required this.animation,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.ease;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    var fadeAnimation =
        CurvedAnimation(parent: animation, curve: Curves.easeInOut);

    return SlideTransition(
      position: animation.drive(tween),
      child: FadeTransition(
        opacity: fadeAnimation,
        child: child,
      ),
    );
  }
}
