import 'package:flutter/material.dart';
import 'package:evosync/screens/training/Plangenerator/training_settings_screen.dart';

class MuscleGroupSelectionScreen extends StatefulWidget {
  final String trainingExperience;
  final List<dynamic> muscleGroups;
  final int trainingFrequency;
  final double selectedDuration;

  const MuscleGroupSelectionScreen({
    required this.trainingExperience,
    required this.muscleGroups,
    required this.trainingFrequency,
    required this.selectedDuration,
    Key? key,
  }) : super(key: key);

  @override
  _MuscleGroupSelectionScreenState createState() =>
      _MuscleGroupSelectionScreenState();
}

class _MuscleGroupSelectionScreenState
    extends State<MuscleGroupSelectionScreen> {
  Map<String, bool> focusedMuscleGroups = {};
  Map<String, bool> neglectedMuscleGroups = {};
  late List<dynamic> muscleGroups;

  @override
  void initState() {
    super.initState();
    muscleGroups = widget.muscleGroups; // Muskelgruppen laden
  }

  void _navigateToTrainingPlanSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingPlanSettingsScreen(
          volumeType: 'Benutzerdefiniert',
          volumePerDay: (widget.selectedDuration / 180).ceil(),
          trainingFrequency: widget.trainingFrequency,
          selectedDuration: widget.selectedDuration,
          trainingExperience: widget.trainingExperience,
          muscleGroups: muscleGroups, // Muskelgruppen übergeben
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muskelgruppen Auswahl'),
      ),
      body: muscleGroups.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: muscleGroups.length,
              itemBuilder: (context, index) {
                final muscleGroup = muscleGroups[index];
                final muscleName = muscleGroup['name'];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        muscleName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: focusedMuscleGroups[muscleName] ?? false,
                            onChanged: (bool? value) {
                              setState(() {
                                focusedMuscleGroups[muscleName] = value!;
                                if (value) {
                                  neglectedMuscleGroups[muscleName] = false;
                                }
                              });
                            },
                          ),
                          const Text('Fokussieren'),
                          const Spacer(),
                          Checkbox(
                            value: neglectedMuscleGroups[muscleName] ?? false,
                            onChanged: (bool? value) {
                              setState(() {
                                neglectedMuscleGroups[muscleName] = value!;
                                if (value) {
                                  focusedMuscleGroups[muscleName] = false;
                                }
                              });
                            },
                          ),
                          const Text('Vernachlässigen'),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _navigateToTrainingPlanSettings,
          child: const Text('Weiter'),
        ),
      ),
    );
  }
}
