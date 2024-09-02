import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'split_detail_screen.dart'; // Import der neuen Detailansicht

class TrainingPlanSettingsScreen extends StatelessWidget {
  final String volumeType;
  final int trainingFrequency; // Anzahl der Trainingseinheiten pro Woche
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
          minVolume = muscleGroup['mav']['max'];
          maxVolume = muscleGroup['mrv']['min'];
          break;
        case 'Etwas Fokussieren':
          minVolume = muscleGroup['mav']['min'];
          maxVolume = muscleGroup['mav']['max'];
          break;
        case 'Normal':
          minVolume = muscleGroup['mev']['min'];
          maxVolume = muscleGroup['mav']['min'];
          break;
        case 'Vernachlässigen':
          minVolume = muscleGroup['mev']['min'];
          maxVolume = muscleGroup['mev']['max'];
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

  // Methode zur Berechnung der täglichen Volumenverteilung
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

  // Methode zur Berechnung der gesamten Volumenverteilung für die Woche
  Map<String, int> _calculateTotalVolumeDistribution(
      Map<String, int> dailyVolumeDistribution) {
    Map<String, int> totalVolumeDistribution = {};

    dailyVolumeDistribution.forEach((muscle, dailyVolume) {
      totalVolumeDistribution[muscle] = dailyVolume * trainingFrequency;
    });

    return totalVolumeDistribution;
  }

  // Benutzerdefinierte Rundungsfunktion nach den spezifizierten Regeln
  int customRound(double value) {
    if (value - value.floor() <= 0.5) {
      return value.floor(); // Bis 0,5 abrunden
    } else {
      return value.ceil(); // Ab 0,6 aufrunden
    }
  }

  // Methode zur gewichteten Verteilung des Volumens auf die Trainingstage basierend auf der Anzahl der Muskelgruppen
  Map<String, Map<String, int>> _distributeVolumeAcrossDays(
      Map<String, int> totalVolumeDistribution, List<dynamic> splitDays) {
    Map<String, Map<String, int>> dailyVolume = {};

    // Berechne die Summe der Gewichte für jede Muskelgruppe basierend auf der Anzahl der Gruppen pro Tag
    Map<String, double> muscleWeightsSum = {};
    Map<String, Map<String, double>> muscleWeights = {};

    for (var day in splitDays) {
      String dayName = day['day'];
      int muscleCount = day['muscle_groups'].length;

      muscleWeights[dayName] = {};
      for (var muscle in day['muscle_groups']) {
        muscleWeights[dayName]![muscle] = 1 / muscleCount.toDouble();
        muscleWeightsSum[muscle] =
            (muscleWeightsSum[muscle] ?? 0) + muscleWeights[dayName]![muscle]!;
      }
    }

    // Verteile das Volumen auf die Tage abhängig von den Gewichten
    for (var day in splitDays) {
      String dayName = day['day'];
      Map<String, int> dayVolume = {};

      for (var muscle in day['muscle_groups']) {
        int totalVolume = totalVolumeDistribution[muscle] ?? 0;
        double normalizedWeight =
            (muscleWeights[dayName]![muscle] ?? 0) / muscleWeightsSum[muscle]!;
        double rawVolume = totalVolume * normalizedWeight;
        int allocatedVolume = customRound(
            rawVolume); // Verwende die benutzerdefinierte Rundungsfunktion
        dayVolume[muscle] = allocatedVolume;
      }

      dailyVolume[dayName] = dayVolume;
    }

    return dailyVolume;
  }

  // Lädt die Split-Varianten aus der JSON-Datei
  Future<List<dynamic>> _loadSplitVariants() async {
    final String response =
        await rootBundle.loadString('assets/database/Splits_Default.json');
    final data = await json.decode(response);
    return data['split_variants'];
  }

  // Filtert geeignete Splits basierend auf der berechneten Volumenverteilung und Trainingsfrequenz
  List<Map<String, dynamic>> _filterSplits(
      List<dynamic> splitVariants, Map<String, int> totalVolumeDistribution) {
    List<Map<String, dynamic>> suitableSplits = [];

    for (var split in splitVariants) {
      int numberOfDays = split['days'].length;

      // Prüft, ob die Anzahl der Tage im Split zur gewünschten Trainingsfrequenz passt
      if (numberOfDays == trainingFrequency) {
        bool isSuitable = true;

        for (var day in split['days']) {
          for (var muscleGroup in day['muscle_groups']) {
            // Überprüft, ob jede Muskelgruppe in den berechneten Volumen enthalten ist
            if (!totalVolumeDistribution.containsKey(muscleGroup)) {
              isSuitable = false;
              break;
            }
          }
          if (!isSuitable) break;
        }

        if (isSuitable) {
          suitableSplits.add(split);
        }
      }
    }

    return suitableSplits;
  }

  @override
  Widget build(BuildContext context) {
    // Berechnung des Volumens für jede Muskelgruppe
    Map<String, int> dailyVolumeDistribution =
        _calculateDailyVolumeDistribution();
    Map<String, int> totalVolumeDistribution =
        _calculateTotalVolumeDistribution(dailyVolumeDistribution);

    return Scaffold(
      appBar: AppBar(
        title: Text('Trainingsplan Einstellungen'),
      ),
      body: FutureBuilder(
        future: _loadSplitVariants(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Fehler beim Laden der Splits'));
          } else {
            final splits = _filterSplits(
                snapshot.data as List<dynamic>, totalVolumeDistribution);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Volumen pro Muskelgruppe:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  // Anzeige des Gesamtvolumens pro Woche
                  ...muscleGroups.map((muscleGroup) {
                    final muscleName = muscleGroup['name'];
                    final totalVolume =
                        totalVolumeDistribution[muscleName] ?? 0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text('$muscleName: $totalVolume Sätze/Woche',
                          style: TextStyle(fontSize: 16)),
                    );
                  }).toList(),
                  SizedBox(height: 20),
                  Text('Empfohlene Splits:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  // Anzeige der Splitvarianten ohne detaillierte Volumenverteilung
                  ...splits.map((split) {
                    return ListTile(
                      title: Text(split['name']),
                      onTap: () {
                        // Navigiere zur Detailansicht des Splits
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SplitDetailScreen(
                              split: split,
                              distributedVolume: _distributeVolumeAcrossDays(
                                  totalVolumeDistribution,
                                  split[
                                      'days']), // Korrekte Verteilung, falls in der Detailansicht benötigt
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
