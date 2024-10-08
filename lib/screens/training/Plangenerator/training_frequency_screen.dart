import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importiert das gesamte Paket für HapticFeedback
import 'package:evosync/models/profile.dart';
import 'package:evosync/screens/training/Plangenerator/training_duration_screen.dart';

class TrainingFrequencyScreen extends StatefulWidget {
  final Profile userProfile;

  const TrainingFrequencyScreen({required this.userProfile, Key? key})
      : super(key: key);

  @override
  _TrainingFrequencyScreenState createState() =>
      _TrainingFrequencyScreenState();
}

class _TrainingFrequencyScreenState extends State<TrainingFrequencyScreen>
    with SingleTickerProviderStateMixin {
  late int _selectedFrequency;
  late String _recommendationText;
  List<dynamic> muscleGroups = [];

  @override
  void initState() {
    super.initState();
    _setRecommendedFrequency();
    _loadMuscleGroups();
  }

  void _setRecommendedFrequency() {
    switch (widget.userProfile.trainingExperience) {
      case 'Novice':
        _selectedFrequency = 4;
        _recommendationText =
            'Untrainierten empfehlen wir 4 Workouts pro Woche';
        break;
      case 'Beginner':
        _selectedFrequency = 4;
        _recommendationText = 'Anfängern empfehlen wir 4 Workouts pro Woche';
        break;
      case 'Intermediate':
        _selectedFrequency = 5;
        _recommendationText =
            'Fortgeschrittenen empfehlen wir 5 Workouts pro Woche';
        break;
      case 'Advanced':
        _selectedFrequency = 6;
        _recommendationText = 'Profis empfehlen wir 6 Workouts pro Woche';
        break;
      case 'Very Advanced':
        _selectedFrequency = 6;
        _recommendationText =
            'Elite-Athleten empfehlen wir 6 Workouts pro Woche';
        break;
      default:
        _selectedFrequency = 3; // Fallback
        _recommendationText = '';
    }
  }

  Future<void> _loadMuscleGroups() async {
    final String response =
        await rootBundle.loadString('assets/database/training_volumes.json');
    final data = await json.decode(response);
    setState(() {
      muscleGroups = data['body_parts'];
    });
  }

  void _navigateToNextScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingDurationScreen(
          trainingExperience: widget.userProfile.trainingExperience,
          muscleGroups: muscleGroups, // Übergabe der geladenen Muskelgruppen
          trainingFrequency: _selectedFrequency, // Übergabe der Frequenz
          gender: widget.userProfile.gender, // Übergabe des Geschlechts
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Define the dark purple color for dark mode
    final Color darkModePurple = Colors.deepPurpleAccent.withOpacity(0.5);

    // Liste der Frequenzen von 2 bis 6
    final List<int> frequencies = [2, 3, 4, 5, 6];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainingsfrequenz'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Reduziertes Padding
          child: Column(
            children: [
              // Titel
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Wie oft möchtest du pro Woche trainieren?',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              // Auswahlkarten innerhalb eines Expanded Widgets
              Expanded(
                child: ListView.builder(
                  itemCount:
                      frequencies.length + 1, // +1 für den Empfehlungstext
                  padding: const EdgeInsets.only(bottom: 80.0), // Platz für FAB
                  itemBuilder: (context, index) {
                    if (index < frequencies.length) {
                      final frequency = frequencies[index];
                      final isSelected = _selectedFrequency == frequency;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6.0, horizontal: 4.0),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact(); // Haptisches Feedback
                            setState(() {
                              _selectedFrequency = frequency;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              gradient: isSelected
                                  ? LinearGradient(
                                      colors: [
                                        theme.colorScheme.primary
                                            .withOpacity(0.8),
                                        theme.colorScheme.primary,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null, // Kein Gradient, wenn nicht ausgewählt
                              color: isSelected
                                  ? null
                                  : theme
                                      .cardColor, // Nur bei nicht ausgewählten Karten
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.4),
                                        spreadRadius: 2,
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.black12,
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icon hinzufügen
                                Icon(
                                  Icons.fitness_center,
                                  color: isSelected
                                      ? theme.colorScheme.onPrimary
                                      : theme.iconTheme.color,
                                  size: 30,
                                ),
                                const SizedBox(width: 12),
                                // Text
                                Expanded(
                                  child: Text(
                                    '$frequency Mal pro Woche',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? theme.colorScheme.onPrimary
                                          : theme.textTheme.bodyLarge?.color,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                // Checkmark bei Auswahl (kleineres Icon)
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: theme.colorScheme.onPrimary,
                                    size: 24, // Reduzierte Größe
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      // Empfehlungstext als letztes Element
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 4.0),
                        child: Text(
                          _recommendationText,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 18, // Größere Schriftgröße
                            fontWeight: FontWeight.bold, // Fett für Betonung
                            color: theme.colorScheme
                                .secondary, // Akzentfarbe für Betonung
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // Floating Action Button mit ausreichend Abstand
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
            bottom: 20.0, right: 16.0), // Angepasster Abstand
        child: FloatingActionButton(
          onPressed: _navigateToNextScreen,
          backgroundColor: isDarkMode
              ? darkModePurple
              : theme.colorScheme.primary, // Anpassung für Dark Mode
          child: const Icon(Icons.check,
              color: Colors.white), // Weißes Icon für Sichtbarkeit
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
