import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:evosync/theme/dark_mode_notifier.dart';
import 'package:evosync/widgets/training/date_widget.dart';
import 'package:evosync/widgets/training/create_plan_button.dart';
import 'package:evosync/widgets/generic/theme_toggle_button.dart';
import 'package:evosync/screens/training/exercise_list_screen.dart';
import 'package:evosync/widgets/generic/custom_slide_transition.dart';
import 'package:evosync/screens/training/Plangenerator/profile_data_screen.dart'; // Importiere den Profil-Data-Screen

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  _TrainingScreenState createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen>
    with SingleTickerProviderStateMixin {
  bool _isInitialized = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _initializeDateFormatting();
  }

  Future<void> _initializeDateFormatting() async {
    await initializeDateFormatting('de_DE', null);
    setState(() {
      _isInitialized = true;
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final darkModeNotifier = Provider.of<DarkModeNotifier>(context);
    final isDarkMode = darkModeNotifier.themeMode == ThemeMode.dark;

    return Scaffold(
      body: CustomSlideTransition(
        animation: _controller,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 85),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[850] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.black.withOpacity(0.5)
                              : Colors.grey.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _buildDateWidgets(isDarkMode),
                    ),
                  ),
                  const SizedBox(height: 50),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Center(
                      key: ValueKey<bool>(isDarkMode),
                      child: Text(
                        'Bring dein Training\nauf ein neues Level!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                          height: 1.3,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        _createRoute(const ExerciseListScreen()),
                      );
                    },
                    child: const Text(
                      'Übungen',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Logik für "Hilfe"
                    },
                    child: const Text(
                      'Hilfe',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Column(
                      children: [
                        CreatePlanButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ProfileDataScreen()), // Navigiere zum ProfileDataScreen
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: Row(
                children: [
                  const ThemeToggleButton(),
                  TextButton(
                    onPressed: () {
                      // Logik für "Erstellen"
                    },
                    child: const Text(
                      'Erstellen',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDateWidgets(bool isDarkMode) {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    List<DateTime> weekDates =
        List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    return weekDates.map((date) {
      bool isToday =
          DateFormat('EEEE').format(date) == DateFormat('EEEE').format(now);
      return DateWidget(
        date: date,
        isToday: isToday,
        isDarkMode: isDarkMode,
        onTap: () {
          // Logik für das Anklicken eines Datums
        },
      );
    }).toList();
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return CustomSlideTransition(
          animation: animation,
          child: child,
        );
      },
    );
  }
}
