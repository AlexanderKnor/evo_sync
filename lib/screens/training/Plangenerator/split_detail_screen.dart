// split_detail_screen.dart

import 'package:flutter/material.dart';

class SplitDetailScreen extends StatelessWidget {
  final Map<String, dynamic> split;
  final Map<String, Map<String, int>> distributedVolume;

  // Zusätzliche Variablen
  final String volumeType;
  final int trainingFrequency;
  final int volumePerDay;
  final double selectedDuration; // In Sekunden
  final String trainingExperience;
  final List<dynamic> muscleGroups;
  final Map<String, String> selection;

  SplitDetailScreen({
    required this.split,
    required this.distributedVolume,
    required this.volumeType,
    required this.trainingFrequency,
    required this.volumePerDay,
    required this.selectedDuration,
    required this.trainingExperience,
    required this.muscleGroups,
    required this.selection,
  });

  // Methode zur Anpassung des Volumens pro Tag
  Map<String, Map<String, Map<String, int>>> _adjustVolumePerDay() {
    Map<String, Map<String, Map<String, int>>> adjustedVolume = {};

    distributedVolume.forEach((dayName, muscleVolume) {
      int totalVolumeForDay =
          muscleVolume.values.fold(0, (sum, sets) => sum + sets);
      double deviation =
          (totalVolumeForDay - volumePerDay).abs() / volumePerDay;

      if (deviation > 0.1) {
        double adjustmentFactor;
        if (totalVolumeForDay > volumePerDay) {
          // Nach unten glätten, obere Grenze nutzen (+10%)
          adjustmentFactor = (volumePerDay * 1.1) / totalVolumeForDay;
        } else {
          // Nach oben glätten, untere Grenze nutzen (-10%)
          adjustmentFactor = (volumePerDay * 0.9) / totalVolumeForDay;
        }
        Map<String, int> adjustedMuscleVolume = {};

        muscleVolume.forEach((muscle, sets) {
          adjustedMuscleVolume[muscle] = (sets * adjustmentFactor).round();
        });

        adjustedVolume[dayName] = {
          'old': muscleVolume,
          'adjusted': adjustedMuscleVolume
        };
      } else {
        adjustedVolume[dayName] = {
          'old': muscleVolume,
          'adjusted': muscleVolume
        };
      }
    });

    return adjustedVolume;
  }

  // Methode zur Berechnung der geschätzten Trainingszeit pro Tag
  int _calculateEstimatedTimePerDay(
      String dayName, Map<String, int> dayVolume) {
    int totalSets =
        dayVolume.values.fold(0, (sum, sets) => sum + sets); // Summe der Sätze
    return totalSets * 3; // Multipliziere mit 3 Minuten pro Satz
  }

  // Methode zur Formatierung der Dauer in Stunden und Minuten
  String _formatDuration(double seconds) {
    Duration duration = Duration(seconds: seconds.round());
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    String formatted = '';

    if (hours > 0) {
      formatted += '$hours h ';
    }
    formatted += '$minutes min';
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    final adjustedVolume = _adjustVolumePerDay();

    return Scaffold(
      appBar: AppBar(
        title: Text(split['name']),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: split['days'].length,
        itemBuilder: (context, index) {
          final day = split['days'][index];
          final dayName = day['name'];
          final dayVolume =
              adjustedVolume[dayName] ?? {'old': {}, 'adjusted': {}};
          final oldVolume = dayVolume['old'] ?? {};
          final adjustedDayVolume = dayVolume['adjusted'] ?? {};

          return Card(
            margin: EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  ...adjustedDayVolume.entries.map((entry) {
                    String muscle = entry.key;
                    int adjustedSets = entry.value;
                    int oldSets = oldVolume[muscle] ?? adjustedSets;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            muscle,
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Alt: $oldSets Sätze, Neu: $adjustedSets Sätze',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  SizedBox(height: 10),
                  Text(
                    'Geschätzte Trainingszeit: ${_calculateEstimatedTimePerDay(dayName, adjustedDayVolume)} Minuten',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  Divider(),
                  SizedBox(height: 10),
                  Text(
                    'Trainingsdetails:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text('Volumen Typ: $volumeType'),
                  Text('Trainingsfrequenz: $trainingFrequency Tage/Woche'),
                  Text('Volumen pro Tag: $volumePerDay'),
                  Text(
                      'Ausgewählte Dauer: ${_formatDuration(selectedDuration)}'),
                  Text('Trainingserfahrung: $trainingExperience'),

                  SizedBox(height: 10),
                  // Verwendung von ExpansionTile für die Muskelgruppen-Auswahl
                  ExpansionTile(
                    title: Text(
                      'Muskelgruppen Auswahl',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    children: muscleGroups.map<Widget>((muscleGroup) {
                      String muscleName = muscleGroup['name'];
                      String selectionStatus =
                          selection[muscleName] ?? 'Nicht ausgewählt';
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2.0, horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              muscleName,
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              selectionStatus,
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
