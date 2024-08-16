import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DarkModeNotifier extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.system;

  DarkModeNotifier() {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _saveThemeMode();
    notifyListeners();
  }

  void _saveThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _themeModeKey, _themeMode.toString().split('.').last);
    } catch (e) {
      // Fehler beim Speichern behandeln
      debugPrint('Fehler beim Speichern des ThemeMode: $e');
    }
  }

  void _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_themeModeKey);

      if (themeModeString != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString().split('.').last == themeModeString,
          orElse: () => ThemeMode.system,
        );
      }
      notifyListeners();
    } catch (e) {
      // Fehler beim Laden behandeln
      debugPrint('Fehler beim Laden des ThemeMode: $e');
    }
  }
}
