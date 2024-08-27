import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:evosync/models/profile.dart';
import 'package:evosync/database_helper.dart';
import 'package:evosync/screens/main_screen.dart';

class TrainingLevelEvaluationScreen extends StatefulWidget {
  final Profile profile;

  const TrainingLevelEvaluationScreen({Key? key, required this.profile})
      : super(key: key);

  @override
  _TrainingLevelEvaluationScreenState createState() =>
      _TrainingLevelEvaluationScreenState();
}

class _TrainingLevelEvaluationScreenState
    extends State<TrainingLevelEvaluationScreen> {
  List<dynamic> _questions = [];
  Map<String, dynamic> _evaluation = {};
  List<int?> _answers = [];
  bool _showInitialQuestion = true;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final String response = await rootBundle
        .loadString('assets/database/fragenkatalog_experience.json');
    final data = json.decode(response);
    setState(() {
      _questions = data['questions'];
      _evaluation = data['evaluation'];
      _answers = List.filled(_questions.length, null);
    });
  }

  void _handleInitialQuestion(bool hasTrainingExperience) {
    if (hasTrainingExperience) {
      setState(() {
        _showInitialQuestion = false;
      });
    } else {
      _saveAndNavigate('Novice');
    }
  }

  void _calculateTrainingLevel() {
    if (_answers.contains(null)) {
      _showValidationError();
      return;
    }

    // Calculate total score
    int totalScore = _answers.reduce((a, b) => a! + b!)!;

    // Determine the training level based on the score
    String trainingLevel = _determineTrainingLevel(totalScore);

    // Save and navigate to next screen
    _saveAndNavigate(trainingLevel);
  }

  String _determineTrainingLevel(int totalScore) {
    for (var entry in _evaluation.entries) {
      if (totalScore >= entry.value['min'] &&
          totalScore <= entry.value['max']) {
        return entry.key;
      }
    }
    return 'Unknown'; // Fallback if no level is found
  }

  Future<void> _saveAndNavigate(String trainingLevel) async {
    Profile updatedProfile = widget.profile.copyWith(
      trainingExperience: trainingLevel,
    );

    // Save profile to database
    try {
      if (updatedProfile.id == null) {
        int newId = await _dbHelper.insertProfile(updatedProfile);
        updatedProfile = updatedProfile.copyWith(id: newId);
      } else {
        await _dbHelper.updateProfile(updatedProfile);
      }

      // Show dialog and navigate to main screen
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Dein Trainingslevel: $trainingLevel'),
            content: Text(_getLevelMessage(trainingLevel)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => MainScreen(),
                  ));
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error saving profile: $e');
    }
  }

  String _getLevelMessage(String trainingLevel) {
    switch (trainingLevel) {
      case 'Novice':
        return "Du bist ein Anfänger und hast noch viel Potenzial für schnelle Fortschritte.";
      case 'Beginner':
        return "Du hast etwas Erfahrung, aber es gibt noch viel Raum für Wachstum.";
      case 'Intermediate':
        return "Du hast bereits einige Jahre Erfahrung und das Training muss sorgfältig geplant werden, um weitere Fortschritte zu erzielen.";
      case 'Advanced':
        return "Du bist ein fortgeschrittener Athlet, bei dem Fortschritte schwieriger zu erzielen sind und eine hohe Trainingsgenauigkeit erforderlich ist.";
      case 'Very Advanced':
        return "Du bist auf einem sehr hohen Niveau, wo es schwierig ist, weitere signifikante Fortschritte zu erzielen, und das Ziel häufig darin besteht, das aktuelle Niveau zu halten.";
      default:
        return "Unbekanntes Level.";
    }
  }

  void _showValidationError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unvollständige Antworten'),
        content: const Text(
            'Bitte beantworten Sie alle Fragen, bevor Sie fortfahren.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Training Level Evaluierung')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _showInitialQuestion
            ? _buildInitialQuestion()
            : _buildQuestionnaire(),
      ),
    );
  }

  Widget _buildInitialQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hast du in den letzten 6 Monaten regelmäßig (mindestens 2-3 Mal pro Woche) eine Form von systematischem Training (z.B. Krafttraining, Ausdauertraining, Sportarten mit strukturiertem Training) betrieben?',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _handleInitialQuestion(true),
          child: const Text('Ja'),
        ),
        ElevatedButton(
          onPressed: () => _handleInitialQuestion(false),
          child: const Text('Nein'),
        ),
      ],
    );
  }

  Widget _buildQuestionnaire() {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_questions[index]['question']),
                    Column(
                      children:
                          (_questions[index]['options'] as List).map((option) {
                        return RadioListTile<int?>(
                          title: Text(option['description']),
                          value: option['value'],
                          groupValue: _answers[index],
                          onChanged: (value) {
                            setState(() {
                              _answers[index] = value;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _calculateTrainingLevel,
            child: const Text('Weiter'),
          ),
        ],
      ),
    );
  }
}
