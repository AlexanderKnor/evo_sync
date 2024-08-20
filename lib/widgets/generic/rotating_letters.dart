import 'package:flutter/material.dart';
import 'dart:math' as math;

class RotatingLetters extends StatefulWidget {
  final String text;
  final bool isDarkMode;

  const RotatingLetters({
    Key? key,
    required this.text,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  _RotatingLettersState createState() => _RotatingLettersState();
}

class _RotatingLettersState extends State<RotatingLetters>
    with TickerProviderStateMixin {
  late AnimationController _outerController;
  late Animation<double> _outerAnimation;
  late AnimationController _innerController;
  late Animation<double> _innerAnimation;
  late AnimationController _innermostController;
  late Animation<double> _innermostAnimation;
  late AnimationController _innerMostController;
  late Animation<double> _innerMostAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  double _outerTotalRotation = 0.0;
  double _innerTotalRotation = 0.0;
  double _innermostTotalRotation = 0.0;
  double _innerMostTotalRotation = 0.0;
  final double _maxLeaningAngle = 0.5; // Neigungswinkel

  @override
  void initState() {
    super.initState();

    // Äußere Rotation
    _outerController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _outerAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 60.0 / 360.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 60.0 / 360.0, end: -120.0 / 360.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 2,
      ),
    ]).animate(_outerController);

    _outerController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _outerTotalRotation += _outerAnimation.value * 2 * math.pi;
        _outerController.forward(from: 0.0);
      }
    });
    _outerController.forward();

    // Innere Rotation
    _innerController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _innerAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 60.0 / 360.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 60.0 / 360.0, end: -120.0 / 360.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 2,
      ),
    ]).animate(_innerController);

    _innerController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _innerTotalRotation += _innerAnimation.value * 2 * math.pi;
        _innerController.forward(from: 0.0);
      }
    });
    _innerController.forward();

    // Innerste Rotation
    _innermostController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _innermostAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 60.0 / 360.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 60.0 / 360.0, end: -120.0 / 360.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 2,
      ),
    ]).animate(_innermostController);

    _innermostController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _innermostTotalRotation += _innermostAnimation.value * 2 * math.pi;
        _innermostController.forward(from: 0.0);
      }
    });
    _innermostController.forward();

    // Kleinste Rotation
    _innerMostController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _innerMostAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 60.0 / 360.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 60.0 / 360.0, end: -120.0 / 360.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 2,
      ),
    ]).animate(_innerMostController);

    _innerMostController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _innerMostTotalRotation += _innerMostAnimation.value * 2 * math.pi;
        _innerMostController.forward(from: 0.0);
      }
    });
    _innerMostController.forward();

    // Pulsieren
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _outerController.dispose();
    _innerController.dispose();
    _innermostController.dispose();
    _innerMostController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outerLetters = (widget.text * 4).split("");
    final innerLetters = (widget.text * 3).split("");
    final innermostLetters = (widget.text * 2).split("");
    final innerMostLetters = (widget.text * 1).split("");

    final outerRadius = 180.0;
    final innerRadius = 140.0;
    final innermostRadius = 100.0;
    final innerMostRadius = 60.0;

    return Center(
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Äußerer Kreis
              AnimatedBuilder(
                animation: _outerAnimation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: _buildRotatingLetters(
                      outerLetters,
                      outerRadius * _pulseAnimation.value,
                      _outerTotalRotation,
                      _outerAnimation.value,
                      1.0, // Normale Deckkraft
                      applyLeaning: true,
                    ),
                  );
                },
              ),
              // Innerer Kreis
              AnimatedBuilder(
                animation: _innerAnimation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: _buildRotatingLetters(
                      innerLetters,
                      innerRadius * _pulseAnimation.value,
                      _innerTotalRotation,
                      _innerAnimation.value,
                      0.5, // Blassere Deckkraft
                      applyLeaning: false,
                    ),
                  );
                },
              ),
              // Innerster Kreis
              AnimatedBuilder(
                animation: _innermostAnimation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: _buildRotatingLetters(
                      innermostLetters,
                      innermostRadius * _pulseAnimation.value,
                      _innermostTotalRotation,
                      _innermostAnimation.value,
                      0.25, // Noch blassere Deckkraft
                      applyLeaning: true,
                    ),
                  );
                },
              ),
              // Kleinster Kreis
              AnimatedBuilder(
                animation: _innerMostAnimation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: _buildRotatingLetters(
                      innerMostLetters,
                      innerMostRadius * _pulseAnimation.value,
                      _innerMostTotalRotation,
                      _innerMostAnimation.value,
                      0.1, // Am blassesten
                      applyLeaning: false,
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildRotatingLetters(
    List<String> letters,
    double radius,
    double totalRotation,
    double animatedValue,
    double opacity, {
    required bool applyLeaning,
  }) {
    final angleStep = 2 * math.pi / letters.length;

    return List.generate(letters.length, (index) {
      final angle = angleStep * index;
      final rotationAngle = totalRotation + animatedValue * 2 * math.pi;

      double leaningAngle = 0.0;
      if (applyLeaning) {
        if (animatedValue <= 60.0 / 360.0) {
          leaningAngle = _maxLeaningAngle *
              math.sin((animatedValue / (60.0 / 360.0)) * math.pi);
        } else {
          leaningAngle = -_maxLeaningAngle *
              math.sin(
                  ((animatedValue - 60.0 / 360.0) / (120.0 / 360.0)) * math.pi);
        }
      }

      final double x = radius * math.cos(angle + rotationAngle);
      final double y = radius * math.sin(angle + rotationAngle);

      return Transform.translate(
        offset: Offset(x, y),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ(angle + rotationAngle + math.pi / 2)
            ..rotateZ(leaningAngle),
          child: Opacity(
            opacity: opacity,
            child: Text(
              letters[index],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: widget.isDarkMode
                    ? Colors.white.withOpacity(opacity)
                    : Colors.black87.withOpacity(opacity),
              ),
            ),
          ),
        ),
      );
    });
  }
}
