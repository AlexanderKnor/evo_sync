import 'dart:ui'; // Für Glassmorphism-Effekte
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:evosync/theme/dark_mode_notifier.dart';
import 'package:evosync/widgets/training/date_widget.dart';
import 'package:evosync/widgets/generic/theme_toggle_button.dart';
import 'package:evosync/screens/training/exercise_list_screen.dart';
import 'package:evosync/widgets/generic/custom_slide_transition.dart';
import 'package:evosync/screens/training/Plangenerator/profile_data_screen.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:animations/animations.dart';
import 'package:glassmorphism/glassmorphism.dart';

// Platzhalter für StatisticsScreen
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiken'),
      ),
      body: const Center(
        child: Text('Hier werden die Statistiken angezeigt.'),
      ),
    );
  }
}

// Platzhalter für HelpScreen
class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hilfe'),
      ),
      body: const Center(
        child: Text('Hier finden Sie Hilfe und Unterstützung.'),
      ),
    );
  }
}

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  _TrainingScreenState createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen>
    with TickerProviderStateMixin {
  bool _isInitialized = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _initializeDateFormatting();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  Future<void> _initializeDateFormatting() async {
    await initializeDateFormatting('de_DE', null);
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Beispielname des Benutzers
  String userName = "Alex";

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final darkModeNotifier = Provider.of<DarkModeNotifier>(context);
    final isDarkMode = darkModeNotifier.themeMode == ThemeMode.dark;

    return Scaffold(
      body: SafeArea(
        child: CustomSlideTransition(
          animation: _controller,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Begrüßung und Profil
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hallo, $userName 👋',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const ThemeToggleButton(),
                  ],
                ),
                const SizedBox(height: 20),
                // Fortschrittsanzeige oder Banner
                _buildProgressCard(isDarkMode),
                const SizedBox(height: 20),
                // Datumsauswahl als horizontale Scrollleiste
                _buildDateSelector(isDarkMode),
                const SizedBox(height: 20),
                // Funktionale Karten
                _buildFunctionalCards(isDarkMode),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Fortschrittsanzeige mit modernem Design und Animation
  Widget _buildProgressCard(bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        // Logik für Fortschrittsdetails
      },
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 180,
        borderRadius: 20,
        blur: 20,
        alignment: Alignment.bottomCenter,
        border: 2,
        linearGradient: LinearGradient(
          colors: [
            isDarkMode
                ? Colors.black.withOpacity(0.1)
                : Colors.white.withOpacity(0.1),
            isDarkMode
                ? Colors.black38.withOpacity(0.05)
                : Colors.white38.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.5),
            Colors.white.withOpacity(0.5),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Fortschrittsdiagramm mit animiertem Prozentindikator
              Flexible(
                flex: 2,
                child: CircularPercentIndicator(
                  radius: 50.0,
                  lineWidth: 10.0,
                  animation: true,
                  percent: 0.6,
                  center: Text(
                    "60%",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: isDarkMode ? Colors.white : Colors.black),
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  backgroundColor:
                      isDarkMode ? Colors.white10 : Colors.grey[200]!,
                  linearGradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.lightBlueAccent],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Fortschrittstext
              Flexible(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wöchentlicher Fortschritt',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Du hast 3 von 5 Trainings absolviert. Weiter so!',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Datumsauswahl
  Widget _buildDateSelector(bool isDarkMode) {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    List<DateTime> weekDates =
        List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weekDates.length,
        itemBuilder: (context, index) {
          DateTime date = weekDates[index];
          bool isToday = date.day == now.day &&
              date.month == now.month &&
              date.year == now.year;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DateWidget(
              date: date,
              isToday: isToday,
              isDarkMode: isDarkMode,
              onTap: () {
                // Logik für Datumsauswahl
              },
            ),
          );
        },
      ),
    );
  }

  // Funktionale Karten mit modernem Design und animierten Übergängen
  Widget _buildFunctionalCards(bool isDarkMode) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFunctionalCard(
                icon: Icons.fitness_center,
                title: 'Übungen',
                color: Colors.orangeAccent,
                destinationPage: const ExerciseListScreen(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFunctionalCard(
                icon: Icons.schedule,
                title: 'Plan erstellen',
                color: Colors.greenAccent,
                destinationPage: ProfileDataScreen(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildFunctionalCard(
                icon: Icons.bar_chart,
                title: 'Statistiken',
                color: Colors.purpleAccent,
                destinationPage: const StatisticsScreen(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFunctionalCard(
                icon: Icons.help_outline,
                title: 'Hilfe',
                color: Colors.redAccent,
                destinationPage: const HelpScreen(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Einzelne funktionale Karte mit animiertem Übergang
  Widget _buildFunctionalCard({
    required IconData icon,
    required String title,
    required Color color,
    required Widget destinationPage,
  }) {
    return OpenContainer(
      closedElevation: 0,
      openElevation: 0,
      transitionType: ContainerTransitionType.fadeThrough,
      closedColor: Colors.transparent,
      openColor: Colors.transparent,
      clipBehavior: Clip.none,
      closedBuilder: (context, action) {
        return Container(
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.8),
                color.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -20,
                right: -20,
                child: Icon(
                  icon,
                  size: 80,
                  color: Colors.white24,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      openBuilder: (context, action) {
        return destinationPage;
      },
    );
  }
}
