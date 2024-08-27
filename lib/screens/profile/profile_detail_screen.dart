import 'package:flutter/material.dart';
import 'package:evosync/models/profile.dart';
import 'package:evosync/screens/profile/training_level_evaluation_screen.dart';

class ProfileDetailScreen extends StatefulWidget {
  @override
  _ProfileDetailScreenState createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  String _gender = 'Männlich'; // Standardwert
  double _weight = 70.0;

  void _saveProfileDetails() async {
    Profile profile = Profile(
      gender: _gender,
      trainingExperience: '', // This will be set in the evaluation screen
      weight: _weight,
    );

    // Pass profile to TrainingLevelEvaluationScreen for evaluation
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingLevelEvaluationScreen(profile: profile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Geschlecht'),
            DropdownButton<String>(
              value: _gender,
              onChanged: (String? newValue) {
                setState(() {
                  _gender = newValue!;
                });
              },
              items: <String>['Männlich', 'Weiblich', 'Divers']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Körpergewicht (kg)'),
            Slider(
              value: _weight,
              min: 30.0,
              max: 150.0,
              divisions: 240,
              label: _weight.toStringAsFixed(1),
              onChanged: (double value) {
                setState(() {
                  _weight = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveProfileDetails,
              child: const Text('Weiter'),
            ),
          ],
        ),
      ),
    );
  }
}
