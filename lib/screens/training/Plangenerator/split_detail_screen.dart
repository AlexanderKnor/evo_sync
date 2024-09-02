import 'package:flutter/material.dart';

class SplitDetailScreen extends StatelessWidget {
  final Map<String, dynamic> split;
  final Map<String, Map<String, int>> distributedVolume;

  SplitDetailScreen({
    required this.split,
    required this.distributedVolume,
  });

  // Methode zur Berechnung der geschätzten Trainingszeit pro Tag
  int _calculateEstimatedTimePerDay(String dayName) {
    // Summiere die Sätze aller Muskelgruppen an diesem Tag
    final dayVolume = distributedVolume[dayName] ?? {};
    int totalSets =
        dayVolume.values.fold(0, (sum, sets) => sum + sets); // Summe der Sätze
    return totalSets * 3; // Multipliziere mit 3 Minuten pro Satz
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(split['name']),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: split['days'].length,
        itemBuilder: (context, index) {
          final day = split['days'][index];
          final dayName = day['day'];
          final muscleGroups = List<String>.from(
              day['muscle_groups']); // Konvertiere zu List<String>
          final dayVolume = distributedVolume[dayName] ?? {};

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
                  ...muscleGroups.map((muscle) {
                    final sets = dayVolume[muscle] ?? 0;
                    return Text(
                      '$muscle: $sets Sätze',
                      style: TextStyle(fontSize: 16),
                    );
                  }).toList(),
                  SizedBox(height: 10),
                  Text(
                    'Geschätzte Trainingszeit: ${_calculateEstimatedTimePerDay(dayName)} Minuten',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
