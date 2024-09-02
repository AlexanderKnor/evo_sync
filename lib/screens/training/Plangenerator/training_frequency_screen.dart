import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
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

class _TrainingFrequencyScreenState extends State<TrainingFrequencyScreen> {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainingsfrequenz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wie oft möchtest du pro Woche trainieren?',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap:
                    true, // Ensures the GridView does not expand infinitely
                physics:
                    const NeverScrollableScrollPhysics(), // Disable GridView's scrolling
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio:
                      1.5, // Adjust this value to tweak card height
                ),
                itemCount: 6, // 6 cards to exclude "1 Mal pro Woche"
                itemBuilder: (context, index) {
                  final frequency = index + 2; // Start from 2 times per week
                  final isSelected = _selectedFrequency == frequency;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFrequency = frequency;
                      });
                    },
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary.withOpacity(0.8),
                                    theme.colorScheme.primary,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
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
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            '$frequency Mal pro Woche',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Enhanced Recommendation Text
              Text(
                _recommendationText,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 15, // Slightly larger font size
                  fontWeight: FontWeight.bold, // Bold text for emphasis
                  color:
                      theme.colorScheme.secondary, // Accent color for emphasis
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ),
      // Floating Action Button with padding and specific dark mode color
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
            bottom: 30.0,
            right: 16.0), // Padding to match the ProfileDataScreen
        child: FloatingActionButton(
          onPressed: _navigateToNextScreen,
          backgroundColor: isDarkMode
              ? darkModePurple
              : theme.colorScheme
                  .primary, // Dark purple in dark mode, primary in light mode
          child: const Icon(Icons.check,
              color: Colors.white), // White icon color for visibility
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
