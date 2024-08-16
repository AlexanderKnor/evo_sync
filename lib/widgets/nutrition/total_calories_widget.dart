import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evosync/theme/dark_mode_notifier.dart';
import 'package:evosync/screens/nutrition/calories_breakdown_screen.dart';

class TotalCaloriesWidget extends StatefulWidget {
  final double rmr;
  final double neat;
  final double krafttraining;

  const TotalCaloriesWidget({
    Key? key,
    required this.rmr,
    required this.neat,
    required this.krafttraining,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TotalCaloriesWidgetState createState() => _TotalCaloriesWidgetState();
}

class _TotalCaloriesWidgetState extends State<TotalCaloriesWidget>
    with SingleTickerProviderStateMixin {
  double _totalCalories = 0.0;
  double _tef = 0.0;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _calculateTotalCalories();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant TotalCaloriesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rmr != widget.rmr ||
        oldWidget.neat != widget.neat ||
        oldWidget.krafttraining != widget.krafttraining) {
      _calculateTotalCalories();
    }
  }

  void _calculateTotalCalories() {
    double cumulativeCalories = widget.rmr + widget.neat + widget.krafttraining;
    _totalCalories = cumulativeCalories / 0.90; // TEF 10%
    _tef = _totalCalories - cumulativeCalories; // Berechne TEF
  }

  void _navigateToCaloriesBreakdownScreen() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(seconds: 1),
        pageBuilder: (context, animation, secondaryAnimation) =>
            CaloriesBreakdownScreen(
          rmr: widget.rmr,
          neat: widget.neat,
          krafttraining: widget.krafttraining,
          tef: _tef,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Provider.of<DarkModeNotifier>(context).themeMode == ThemeMode.dark;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _navigateToCaloriesBreakdownScreen,
            child: Hero(
              tag: 'caloriesHero',
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(18.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDarkMode
                            ? Colors.orangeAccent.withOpacity(0.2)
                            : Colors.orange.withOpacity(0.1), // Anpassung hier
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode
                                ? Colors.black.withOpacity(0.5)
                                : Colors.orange
                                    .withOpacity(0.3), // Anpassung hier
                            blurRadius: 15, // Anpassung hier
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.local_fire_department,
                        color: isDarkMode ? Colors.orangeAccent : Colors.orange,
                        size: 70.0,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          FadeTransition(
            opacity: _controller.drive(Tween<double>(begin: 0.9, end: 1.0)),
            child: Text(
              '${_totalCalories.toStringAsFixed(0)} kcal',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.orangeAccent : Colors.orange,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
