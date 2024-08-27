import 'package:flutter/material.dart';
import 'package:evosync/widgets/generic/rotating_letters.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: RotatingLetters(
          text: 'evosync',
          isDarkMode: isDarkMode,
        ),
      ),
    );
  }
}
