import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'split_detail_screen.dart';
import 'auto_split_selector.dart'; // Import hinzufügen
import 'package:evosync/widgets/training/splits/training_volume_table.dart';

class TrainingPlanSettingsScreen extends StatefulWidget {
  final String volumeType;
  final int trainingFrequency;
  final int volumePerDay;
  final double selectedDuration;
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

  @override
  _TrainingPlanSettingsScreenState createState() =>
      _TrainingPlanSettingsScreenState();
}

class _TrainingPlanSettingsScreenState
    extends State<TrainingPlanSettingsScreen> {
  String? selectedSplit = 'Automatisch'; // Initial auf "Automatisch" gesetzt
  String selectedWeeks = 'Unbegrenzt';
  bool isPeriodizationEnabled = false;
  List<Map<String, dynamic>> suitableSplits = [];
  Map<String, dynamic> splitData = {};

  final List<String> periodizationWeekOptions = [
    '4 Wochen',
    '5 Wochen',
    '6 Wochen',
    '7 Wochen',
  ];

  @override
  void initState() {
    super.initState();

    // Toggle-Button initial aktivieren und Trainingsdauer einstellen bei bestimmten Trainingserfahrungen
    if (widget.trainingExperience == 'Intermediate' ||
        widget.trainingExperience == 'Advanced' ||
        widget.trainingExperience == 'Very Advanced') {
      isPeriodizationEnabled = true;
      selectedWeeks = _getWeeksForExperience(widget.trainingExperience);
    }

    _loadSplitData().then((data) {
      final splitVariants = data['split_variants'] as List<dynamic>;
      setState(() {
        suitableSplits = _filterSplits(splitVariants, widget.trainingFrequency);
        splitData = data;
      });
    });
  }

  String _getWeeksForExperience(String experience) {
    switch (experience) {
      case 'Intermediate':
        return '5 Wochen';
      case 'Advanced':
        return '6 Wochen';
      case 'Very Advanced':
        return '7 Wochen';
      default:
        return '4 Wochen';
    }
  }

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

  List<Map<String, dynamic>> _filterSplits(
      List<dynamic> splitVariants, int trainingFrequency) {
    return splitVariants
        .where((split) => split['days'].length == trainingFrequency)
        .map((split) => split as Map<String, dynamic>)
        .toList();
  }

  Map<String, double> _getRelativeVolumeProportion() {
    Map<String, double> relativeProportions = {};

    for (var muscleGroup in widget.muscleGroups) {
      String muscleName = muscleGroup['name'];
      int minVolume = 0;
      int maxVolume = 0;

      switch (widget.selection[muscleName]) {
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
    if (totalVolume == 0) totalVolume = 1;

    relativeProportions.updateAll((muscle, volume) {
      return volume / totalVolume;
    });

    return relativeProportions;
  }

  Map<String, int> _calculateTotalVolumeDistribution() {
    Map<String, int> totalVolumeDistribution = {};
    Map<String, double> relativeProportions = _getRelativeVolumeProportion();

    double totalTrainingTimePerWeek =
        widget.selectedDuration * widget.trainingFrequency;

    for (var muscleGroup in widget.muscleGroups) {
      String muscleName = muscleGroup['name'];
      double proportion = relativeProportions[muscleName]!;
      double allocatedTimeForMuscle = proportion * totalTrainingTimePerWeek;
      int assignedVolume = (allocatedTimeForMuscle / (3 * 60)).round();
      totalVolumeDistribution[muscleName] = assignedVolume;
    }

    return totalVolumeDistribution;
  }

  Map<String, Map<String, int>> _distributeVolumeAcrossDays(
      Map<String, int> totalVolumeDistribution,
      List<dynamic> splitDays,
      Map<String, dynamic> dayTypes) {
    Map<String, Map<String, int>> dailyVolume = {};
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
        int allocatedVolume = rawVolume.round();
        dayVolume[muscle] = allocatedVolume;
      }

      dailyVolume[dayName] = dayVolume;
    }

    return dailyVolume;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trainingsplan Einstellungen'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TrainingVolumeTable(
              muscleGroups: widget.muscleGroups,
              totalVolumeDistribution: _calculateTotalVolumeDistribution(),
              relativeProportions: _getRelativeVolumeProportion(),
              totalSets: _calculateTotalVolumeDistribution()
                  .values
                  .fold(0, (a, b) => a + b),
              trainingFrequency: widget.trainingFrequency,
            ),
            SizedBox(height: 20),
            Text(
              'Empfohlene Splits:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Split auswählen:'),
                      DropdownButton<String>(
                        value: selectedSplit,
                        items: [
                          DropdownMenuItem<String>(
                            value: 'Automatisch',
                            child: Text('Automatisch'),
                          ),
                          ...suitableSplits.map((split) {
                            return DropdownMenuItem<String>(
                              value: split['name'],
                              child: Text(split['name']),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedSplit = value;
                          });
                        },
                        hint: Text('Wähle einen Split'),
                      ),
                      SizedBox(height: 20),
                      Text('Trainingsdauer in Wochen:'),
                      DropdownButton<String>(
                        value: selectedWeeks,
                        items: (isPeriodizationEnabled
                                ? periodizationWeekOptions
                                : ['Unbegrenzt'])
                            .map((week) {
                          return DropdownMenuItem<String>(
                            value: week,
                            child: Text(week),
                          );
                        }).toList(),
                        onChanged: isPeriodizationEnabled
                            ? (value) {
                                setState(() {
                                  selectedWeeks = value!;
                                });
                              }
                            : null,
                        hint: Text('Wähle die Anzahl der Wochen'),
                        isExpanded: true,
                        disabledHint: Text('Unbegrenzt'),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Periodisierung',
                            style: TextStyle(fontSize: 16),
                          ),
                          Switch(
                            value: isPeriodizationEnabled,
                            onChanged: (value) {
                              setState(() {
                                isPeriodizationEnabled = value;
                                if (isPeriodizationEnabled) {
                                  selectedWeeks = _getWeeksForExperience(
                                      widget.trainingExperience);
                                } else {
                                  selectedWeeks = 'Unbegrenzt';
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: selectedSplit != null
                    ? () {
                        if (selectedSplit == 'Automatisch') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AutoSplitSelector(
                                  volumeType: widget.volumeType,
                                  trainingFrequency: widget.trainingFrequency,
                                  volumePerDay: widget.volumePerDay,
                                  selectedDuration: widget.selectedDuration,
                                  trainingExperience: widget.trainingExperience,
                                  muscleGroups: widget.muscleGroups,
                                  selection: widget.selection),
                            ),
                          );
                        } else {
                          final selectedSplitData = suitableSplits.firstWhere(
                              (split) => split['name'] == selectedSplit);

                          final dayTypes =
                              splitData['day_types'] as Map<String, dynamic>;
                          final distributedVolume = _distributeVolumeAcrossDays(
                              _calculateTotalVolumeDistribution(),
                              selectedSplitData['days'],
                              dayTypes);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SplitDetailScreen(
                                split: selectedSplitData,
                                distributedVolume: distributedVolume,
                                weeklyVolumeDistribution:
                                    _calculateTotalVolumeDistribution(),
                                volumeType: widget.volumeType,
                                trainingFrequency: widget.trainingFrequency,
                                volumePerDay: widget.volumePerDay,
                                selectedDuration: widget.selectedDuration,
                                trainingExperience: widget.trainingExperience,
                                muscleGroups: widget.muscleGroups,
                                selection: widget.selection,
                                trainingWeeks: selectedWeeks,
                                periodizationEnabled: isPeriodizationEnabled,
                              ),
                            ),
                          );
                        }
                      }
                    : null,
                child: Text('Weiter'),
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
