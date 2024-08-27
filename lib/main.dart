import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_screen.dart';
import 'screens/profile/profile_detail_screen.dart';
import 'theme/dark_mode_notifier.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    if (isFirstLaunch) {
      await prefs.setBool('isFirstLaunch', false);
    }
    return isFirstLaunch;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isFirstLaunch(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else {
          final isFirstLaunch = snapshot.data ?? false;
          return ChangeNotifierProvider(
            create: (_) => DarkModeNotifier(),
            child: Consumer<DarkModeNotifier>(
              builder: (context, darkModeNotifier, child) {
                return MaterialApp(
                  title: 'Training App',
                  theme: ThemeData.light(),
                  darkTheme: ThemeData.dark(),
                  themeMode: darkModeNotifier.themeMode,
                  home: isFirstLaunch
                      ? ProfileDetailScreen() // Starte mit ProfileDetailScreen
                      : const MainScreen(),
                );
              },
            ),
          );
        }
      },
    );
  }
}
