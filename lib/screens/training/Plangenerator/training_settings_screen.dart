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

  // Method to calculate the relative volume proportions
  Map<String, double> _getRelativeVolumeProportion() {
    Map<String, double> relativeProportions = {};

    for (var muscleGroup in muscleGroups) {
      String muscleName = muscleGroup['name'];
      int minVolume = 0;
      int maxVolume = 0;

      switch (selection[muscleName]) {
        case 'Fokussieren':
          minVolume = muscleGroup['mav']['max'];
          maxVolume = muscleGroup['mrv']['min'];
          break;
        case 'Etwas Fokussieren':
          minVolume = muscleGroup['mav']['min'];
          maxVolume = muscleGroup['mrv']['min'];
          break;
        case 'Normal':
          minVolume = muscleGroup['mav']['min'];
          maxVolume = muscleGroup['mav']['max'];
          break;
        case 'Vernachlässigen':
          minVolume = muscleGroup['mev']['max'];
          maxVolume = muscleGroup['mev']['min'];
          break;
        case 'Nicht Trainieren':
          minVolume = 0;
          maxVolume = 0;
          break;
      }

      relativeProportions[muscleName] = (minVolume + maxVolume) / 2.0;
    }

    double totalVolume = relativeProportions.values.reduce((a, b) => a + b);
    relativeProportions.updateAll((muscle, volume) {
      return volume / totalVolume;
    });

    return relativeProportions;
  }

  // Method to calculate daily volume distribution
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

  // Method to calculate total volume distribution for the week
  Map<String, int> _calculateTotalVolumeDistribution(
      Map<String, int> dailyVolumeDistribution) {
    Map<String, int> totalVolumeDistribution = {};

    dailyVolumeDistribution.forEach((muscle, dailyVolume) {
      totalVolumeDistribution[muscle] = dailyVolume * trainingFrequency;
    });

    return totalVolumeDistribution;
  }

  // Method to calculate the volume per training day
  Map<String, String> _calculateVolumePerTrainingDay(
      Map<String, int> totalVolumeDistribution) {
    Map<String, String> volumePerTrainingDay = {};

    for (var muscleGroup in muscleGroups) {
      String muscleName = muscleGroup['name'];
      int totalVolume = totalVolumeDistribution[muscleName] ?? 0;
      int frequencyMin = muscleGroup['frequency']['min'].round();
      int frequencyMax = muscleGroup['frequency']['max'].round();

      int minVolumePerDay = (totalVolume / frequencyMax).ceil();
      int maxVolumePerDay = (totalVolume / frequencyMin).ceil();

      volumePerTrainingDay[muscleName] =
          '$minVolumePerDay - $maxVolumePerDay Sätze/Tag';
    }

    return volumePerTrainingDay;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, int> dailyVolumeDistribution =
        _calculateDailyVolumeDistribution();
    Map<String, int> totalVolumeDistribution =
        _calculateTotalVolumeDistribution(dailyVolumeDistribution);
    Map<String, String> volumePerTrainingDay =
        _calculateVolumePerTrainingDay(totalVolumeDistribution);

    return Scaffold(
      appBar: AppBar(
        title: Text('Trainingsplan Einstellungen'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Volumen und Frequenz pro Muskelgruppe:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ...muscleGroups.map((muscleGroup) {
              final muscleName = muscleGroup['name'];
              final totalVolume = totalVolumeDistribution[muscleName] ?? 0;
              final frequencyMin = muscleGroup['frequency']['min'];
              final frequencyMax = muscleGroup['frequency']['max'];
              final dailyVolume = volumePerTrainingDay[muscleName];

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                    '$muscleName: $totalVolume Sätze/Woche (Frequenz: $frequencyMin - $frequencyMax x/Woche, $dailyVolume)',
                    style: TextStyle(fontSize: 16)),
              );
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
