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
        _selectedFrequency = 3;
        _recommendationText =
            'Untrainierten empfehlen wir 3+ Workouts pro Woche.';
        break;
      case 'Beginner':
        _selectedFrequency = 4;
        _recommendationText = 'Anfängern empfehlen wir 4+ Workouts pro Woche.';
        break;
      case 'Intermediate':
        _selectedFrequency = 5;
        _recommendationText =
            'Fortgeschrittenen empfehlen wir 5+ Workouts pro Woche.';
        break;
      case 'Advanced':
        _selectedFrequency = 6;
        _recommendationText = 'Profis empfehlen wir 6+ Workouts pro Woche.';
        break;
      case 'Very Advanced':
        _selectedFrequency = 6;
        _recommendationText =
            'Elite-Athleten empfehlen wir 5+ Workouts pro Woche.';
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainingsfrequenz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wie oft möchtest du pro Woche trainieren?',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            DropdownButton<int>(
              value: _selectedFrequency,
              onChanged: (int? newValue) {
                setState(() {
                  _selectedFrequency = newValue!;
                });
              },
              items: List.generate(7, (index) => index + 1)
                  .map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value Mal pro Woche'),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              _recommendationText,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _navigateToNextScreen,
              child: const Text('Weiter'),
            ),
          ],
        ),
      ),
    );
  }
}
