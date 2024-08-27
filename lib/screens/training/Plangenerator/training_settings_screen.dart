import 'package:flutter/material.dart';

class TrainingPlanSettingsScreen extends StatelessWidget {
  final String volumeType;
  final int trainingFrequency;
  final int volumePerDay;
  final double selectedDuration; // In Sekunden
  final String trainingExperience;
  final List<dynamic> muscleGroups; // Hinzugefügt

  TrainingPlanSettingsScreen({
    required this.volumeType,
    required this.volumePerDay,
    required this.trainingFrequency,
    required this.selectedDuration,
    required this.trainingExperience,
    required this.muscleGroups, // Hinzugefügt
  });

  Map<String, double> _getRelativeVolumeProportion() {
    Map<String, double> relativeProportions = {};

    int totalMinVolume = 0;
    int totalMaxVolume = 0;

    for (var muscleGroup in muscleGroups) {
      int minVolume = muscleGroup['mav']['min'];
      int maxVolume = muscleGroup['mav']['max'];

      totalMinVolume += minVolume;
      totalMaxVolume += maxVolume;

      relativeProportions[muscleGroup['name']] = (minVolume + maxVolume) / 2.0;
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
                  // Nächste Aktion, z.B. Speichern des Trainingsplans
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
