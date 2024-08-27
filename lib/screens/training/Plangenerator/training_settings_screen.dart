import 'package:flutter/material.dart';

class TrainingPlanSettingsScreen extends StatelessWidget {
  final String volumeType;
  final int trainingFrequency;
  final int volumePerDay;
  final double selectedDuration; // In Sekunden
  final String trainingExperience;
  final List<dynamic> muscleGroups;
  final Map<String, String> selection;

  TrainingPlanSettingsScreen({
    required this.volumeType,
    required this.volumePerDay,
    required this.trainingFrequency,
    required this.selectedDuration,
    required this.trainingExperience,
    required this.muscleGroups,
    required this.selection,
  });

  Map<String, double> _getRelativeVolumeProportion() {
    Map<String, double> relativeProportions = {};

    for (var muscleGroup in muscleGroups) {
      String muscleName = muscleGroup['name'];
      int minVolume;
      int maxVolume;

      switch (selection[muscleName]) {
        case 'Fokussieren':
          minVolume = muscleGroup['mav']['max'];
          maxVolume = muscleGroup['mrv']['min'];
          break;
        case 'Vernachlässigen':
          minVolume = muscleGroup['mev']['min'];
          maxVolume = muscleGroup['mev']['max'];
          break;
        default: // 'Normal'
          minVolume = muscleGroup['mav']['min'];
          maxVolume = muscleGroup['mav']['max'];
      }

      relativeProportions[muscleName] = (minVolume + maxVolume) / 2.0;
    }

    double totalVolume = relativeProportions.values.reduce((a, b) => a + b);
    relativeProportions.updateAll((muscle, volume) {
      return volume / totalVolume;
    });

    return relativeProportions;
  }

  Map<String, int> _calculateDailyVolumeDistribution() {
    Map<String, int> dailyVolumeDistribution = {};

    double totalTrainingTime = selectedDuration;

    Map<String, double> relativeProportions = _getRelativeVolumeProportion();

    for (var muscleGroup in muscleGroups) {
      double proportion = relativeProportions[muscleGroup['name']]!;
      double allocatedTimeForMuscle = proportion * totalTrainingTime;
      int assignedVolume = (allocatedTimeForMuscle / (3 * 60))
          .round(); // Durchschnittliche Satzdauer von 3 Minuten
      dailyVolumeDistribution[muscleGroup['name']] = assignedVolume;
    }

    return dailyVolumeDistribution;
  }

  Map<String, int> _calculateTotalVolumeDistribution(
      Map<String, int> dailyVolumeDistribution) {
    Map<String, int> totalVolumeDistribution = {};

    dailyVolumeDistribution.forEach((muscle, dailyVolume) {
      totalVolumeDistribution[muscle] = dailyVolume * trainingFrequency;
    });

    return totalVolumeDistribution;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, int> dailyVolumeDistribution =
        _calculateDailyVolumeDistribution();
    Map<String, int> totalVolumeDistribution =
        _calculateTotalVolumeDistribution(dailyVolumeDistribution);

    return Scaffold(
      appBar: AppBar(
        title: Text('Trainingsplan Einstellungen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gesamtes Volumen pro Muskelgruppe:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ...totalVolumeDistribution.entries.map((entry) {
              return Text('${entry.key}: ${entry.value} Sätze');
            }).toList(),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Aktion zum Speichern des Trainingsplans
                },
                icon: Icon(Icons.save, size: 24),
                label: Text('Plan Speichern'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  textStyle:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
