// training_plan_settings_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'split_detail_screen.dart'; // Import der neuen Detailansicht
import 'package:evosync/widgets/training/splits/training_volume_table.dart'; // Import der neuen Tabellen-Komponente

class TrainingPlanSettingsScreen extends StatelessWidget {
  final String volumeType;
  final int trainingFrequency; // Anzahl der Trainingstage pro Woche
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

  // Methode zur Berechnung der relativen Volumenverhältnisse
  Map<String, double> _getRelativeVolumeProportion() {
    Map<String, double> relativeProportions = {};

    for (var muscleGroup in muscleGroups) {
      String muscleName = muscleGroup['name'];
      int minVolume = 0;
      int maxVolume = 0;

      switch (selection[muscleName]) {
        case 'Fokussieren':
          minVolume = muscleGroup['mav']['min'];
          maxVolume = muscleGroup['mav']['max'];
          break;
        case 'Etwas Fokussieren':
          minVolume = muscleGroup['mev']['min'];
          maxVolume = muscleGroup['mev']['max'];
          break;
        case 'Normal':
          minVolume = muscleGroup['mev']['min'];
          maxVolume = muscleGroup['mev']['max'];
          break;
        case 'Vernachlässigen':
          minVolume = muscleGroup['mev']['min'];
          maxVolume = muscleGroup['mev']['max'];
          break;
        case 'Nicht Trainieren':
          minVolume = 0;
          maxVolume = 0;
          break;
        default:
          minVolume = 0;
          maxVolume = 0;
      }

      relativeProportions[muscleName] = (minVolume + maxVolume) / 2.0;
    }

    double totalVolume = relativeProportions.values.fold(0, (a, b) => a + b);
    if (totalVolume == 0) totalVolume = 1; // Vermeidung von Division durch Null

    relativeProportions.updateAll((muscle, volume) {
      return volume / totalVolume;
    });

    return relativeProportions;
  }

  // Methode zur Berechnung des gesamten wöchentlichen Volumens basierend auf relativen Proportionen
  Map<String, int> _calculateTotalVolumeDistribution() {
    Map<String, int> totalVolumeDistribution = {};

    Map<String, double> relativeProportions = _getRelativeVolumeProportion();

    // Gesamte Trainingszeit pro Woche berechnen
    double totalTrainingTimePerWeek = selectedDuration * trainingFrequency;

    for (var muscleGroup in muscleGroups) {
      String muscleName = muscleGroup['name'];
      double proportion = relativeProportions[muscleName]!;
      double allocatedTimeForMuscle = proportion * totalTrainingTimePerWeek;
      int assignedVolume = (allocatedTimeForMuscle / (3 * 60))
          .round(); // Durchschnittliche Satzdauer von 3 Minuten in Sekunden
      totalVolumeDistribution[muscleName] = assignedVolume;
    }

    return totalVolumeDistribution;
  }

  // Methode zur Berechnung der täglichen Volumenverteilung durch Division des wöchentlichen Volumens
  Map<String, int> _calculateDailyVolumeDistribution(
      Map<String, int> totalVolumeDistribution) {
    Map<String, int> dailyVolumeDistribution = {};

    for (var muscle in totalVolumeDistribution.keys) {
      int weeklyVolume = totalVolumeDistribution[muscle]!;
      int dailyVolume = (weeklyVolume / trainingFrequency).round();
      dailyVolumeDistribution[muscle] = dailyVolume;
    }

    return dailyVolumeDistribution;
  }

  // Methode zur Verteilung des Volumens unter Berücksichtigung der neuen JSON-Struktur
  Map<String, Map<String, int>> _distributeVolumeAcrossDays(
      Map<String, int> totalVolumeDistribution,
      List<dynamic> splitDays,
      Map<String, dynamic> dayTypes) {
    Map<String, Map<String, int>> dailyVolume = {};

    // Berechne die Summe der Gewichte für jede Muskelgruppe basierend auf der Anzahl der Gruppen pro Tag
    Map<String, double> muscleWeightsSum = {};
    Map<String, Map<String, double>> muscleWeights = {};

    for (var day in splitDays) {
      String dayName = day['name'];
      String dayType = day['type'];
      List<dynamic> musclesForDay = dayTypes[dayType]['muscle_groups'];

      muscleWeights[dayName] = {};
      for (var muscle in musclesForDay) {
        muscleWeights[dayName]![muscle] = 1 / musclesForDay.length.toDouble();
        muscleWeightsSum[muscle] =
            (muscleWeightsSum[muscle] ?? 0) + muscleWeights[dayName]![muscle]!;
      }
    }

    // Verteile das Volumen auf die Tage abhängig von den Gewichten
    for (var day in splitDays) {
      String dayName = day['name'];
      String dayType = day['type'];
      List<dynamic> musclesForDay = dayTypes[dayType]['muscle_groups'];

      Map<String, int> dayVolume = {};

      for (var muscle in musclesForDay) {
        int totalVolume = totalVolumeDistribution[muscle] ?? 0;
        double normalizedWeight =
            (muscleWeights[dayName]![muscle] ?? 0) / muscleWeightsSum[muscle]!;
        double rawVolume = totalVolume * normalizedWeight;
        int allocatedVolume =
            rawVolume.round(); // Verwende die standardmäßige Rundung
        dayVolume[muscle] = allocatedVolume;
      }

      dailyVolume[dayName] = dayVolume;
    }

    return dailyVolume;
  }

  // Lädt die day_types und split_variants aus der JSON-Datei
  Future<Map<String, dynamic>> _loadSplitData() async {
    try {
      final String response =
          await rootBundle.loadString('assets/database/splits.json');
      final data = await json.decode(response);
      return data;
    } catch (e) {
      print('Fehler beim Laden der Splits: $e');
      return {};
    }
  }

  // Filtert geeignete Splits basierend auf der Trainingsfrequenz
  List<Map<String, dynamic>> _filterSplits(
      List<dynamic> splitVariants, int trainingFrequency) {
    List<Map<String, dynamic>> suitableSplits = [];

    for (var split in splitVariants) {
      int numberOfDays = split['days'].length;

      // Prüft, ob die Anzahl der Tage im Split zur gewünschten Trainingsfrequenz passt
      if (numberOfDays == trainingFrequency) {
        suitableSplits.add(split);
      }
    }

    return suitableSplits;
  }

  @override
  Widget build(BuildContext context) {
    // Berechnung des gesamten wöchentlichen Volumens für jede Muskelgruppe
    Map<String, int> totalVolumeDistribution =
        _calculateTotalVolumeDistribution();

    // Berechnung der relativen Gewichtung
    Map<String, double> relativeProportions = _getRelativeVolumeProportion();

    // Berechnung der Gesamtsummen
    int totalSets = totalVolumeDistribution.values.fold(0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(
        title: Text('Trainingsplan Einstellungen'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadSplitData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Center(child: Text('Fehler beim Laden der Splits'));
          } else {
            final data = snapshot.data!;
            final dayTypes = data['day_types'] as Map<String, dynamic>;
            final splitVariants = data['split_variants'] as List<dynamic>;

            // Filtern der Splits basierend auf der Trainingsfrequenz
            final suitableSplits =
                _filterSplits(splitVariants, trainingFrequency);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Verwendung der ausgelagerten Tabellen-Komponente
                  TrainingVolumeTable(
                    muscleGroups: muscleGroups,
                    totalVolumeDistribution: totalVolumeDistribution,
                    relativeProportions: relativeProportions,
                    totalSets: totalSets,
                    trainingFrequency: trainingFrequency,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Empfohlene Splits:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  // Anzeige der Splitvarianten ohne detaillierte Volumenverteilung
                  ...suitableSplits.map((split) {
                    return ListTile(
                      title: Text(split['name']),
                      onTap: () async {
                        // Berechne die tägliche Volumenverteilung für den ausgewählten Split
                        Map<String, Map<String, int>> distributedVolume =
                            _distributeVolumeAcrossDays(totalVolumeDistribution,
                                split['days'], dayTypes);

                        // Navigiere zur Detailansicht des Splits und übergebe alle Variablen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SplitDetailScreen(
                              split: split,
                              distributedVolume: distributedVolume,
                              volumeType: volumeType,
                              trainingFrequency: trainingFrequency,
                              volumePerDay: volumePerDay,
                              selectedDuration: selectedDuration,
                              trainingExperience: trainingExperience,
                              muscleGroups:
                                  muscleGroups, // Übergabe der Muskelgruppen
                              selection: selection, // Übergabe der Auswahl
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Aktion zum Speichern des Trainingsplans
                        // Implementieren Sie hier Ihre Speicherlogik
                      },
                      icon: Icon(Icons.save, size: 24),
                      label: Text('Plan Speichern'),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                        textStyle: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
