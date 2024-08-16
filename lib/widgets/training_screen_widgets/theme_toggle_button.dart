import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evosync/theme/dark_mode_notifier.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final darkModeNotifier = Provider.of<DarkModeNotifier>(context);
    final isDarkMode = darkModeNotifier.themeMode == ThemeMode.dark;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return RotationTransition(
          turns: child.key == const ValueKey('moon')
              ? Tween<double>(begin: 0.75, end: 1.0).animate(animation)
              : Tween<double>(begin: 1.0, end: 1.25).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: IconButton(
        key: ValueKey(isDarkMode ? 'moon' : 'sun'),
        icon: Icon(
          isDarkMode ? Icons.nights_stay : Icons.wb_sunny,
          color: Colors.blue,
        ),
        onPressed: darkModeNotifier.toggleTheme,
      ),
    );
  }
}
