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
  // Map zum Speichern der Schiebereglerwerte für jede Muskelgruppe
  Map<String, double> muscleSliderValues = {};

  @override
  void initState() {
    super.initState();
    // Initialisieren der Schiebereglerwerte für jede Muskelgruppe auf 0,5 (Mitte)
    for (var muscleGroup in widget.muscleGroups) {
      muscleSliderValues[muscleGroup['name']] = 0.5;
    }
  }

  void _navigateToTrainingPlanSettings() {
    // Vorbereiten der Auswahl für den nächsten Bildschirm
    Map<String, String> selection = {};
    widget.muscleGroups.forEach((muscleGroup) {
      String muscleName = muscleGroup['name'];
      double sliderValue = muscleSliderValues[muscleName] ?? 0.5;

      if (sliderValue == 1.0) {
        selection[muscleName] = 'Fokussieren';
      } else if (sliderValue == 0.75) {
        selection[muscleName] = 'Etwas Fokussieren';
      } else if (sliderValue == 0.5) {
        selection[muscleName] = 'Normal';
      } else if (sliderValue == 0.25) {
        selection[muscleName] = 'Vernachlässigen';
      } else if (sliderValue == 0.0) {
        selection[muscleName] = 'Nicht Trainieren';
      }
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingPlanSettingsScreen(
          volumeType: 'Benutzerdefiniert',
          volumePerDay: (widget.selectedDuration / 180).ceil(),
          trainingFrequency: widget.trainingFrequency,
          selectedDuration: widget.selectedDuration,
          trainingExperience: widget.trainingExperience,
          muscleGroups: widget.muscleGroups,
          selection: selection,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muskelgruppen Priorisieren'),
      ),
      body: widget.muscleGroups.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: widget.muscleGroups.length,
              itemBuilder: (context, index) {
                final muscleGroup = widget.muscleGroups[index];
                final muscleName = muscleGroup['name'];
                final sliderValue = muscleSliderValues[muscleName] ?? 0.5;

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
                      Slider(
                        value: sliderValue,
                        min: 0.0,
                        max: 1.0,
                        divisions: 4, // Positionen: 0, 0.25, 0.5, 0.75, 1.0
                        label: sliderValue == 1.0
                            ? 'Fokussieren'
                            : sliderValue == 0.75
                                ? 'Etwas Fokussieren'
                                : sliderValue == 0.5
                                    ? 'Normal'
                                    : sliderValue == 0.25
                                        ? 'Vernachlässigen'
                                        : 'Nicht Trainieren',
                        onChanged: (newValue) {
                          setState(() {
                            muscleSliderValues[muscleName] = newValue;
                          });
                        },
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
