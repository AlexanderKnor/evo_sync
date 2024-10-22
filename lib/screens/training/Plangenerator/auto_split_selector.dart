import 'dart:convert';
import 'dart:math'; // Für die sqrt-Funktion
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'split_detail_screen.dart'; // Importiere SplitDetailScreen

class AutoSplitSelector extends StatefulWidget {
  final String volumeType;
  final int trainingFrequency;
  final int volumePerDay;
  final double selectedDuration;
  final String trainingExperience;
  final List<dynamic> muscleGroups;
  final Map<String, String> selection;

  AutoSplitSelector({
    required this.volumeType,
    required this.trainingFrequency,
    required this.volumePerDay,
    required this.selectedDuration,
    required this.trainingExperience,
    required this.muscleGroups,
    required this.selection,
  });

  @override
  _AutoSplitSelectorState createState() => _AutoSplitSelectorState();
}

class _AutoSplitSelectorState extends State<AutoSplitSelector> {
  List<dynamic> splitVariants = [];
  List<dynamic> filteredSplits = [];
  Map<String, dynamic> splitData = {};
  Map<String, int> weeklyVolumeDistribution = {};
  Map<String, int> muscleGroupToTrainingDays = {};

  // Variablen zur Speicherung der Abweichungen und des besten Splits
  Map<String, Map<String, dynamic>> splitMetrics = {};
  String bestSplitName = '';

  // Definiere die primären Muskelgruppen und ihre synergistischen Muskelgruppen
  final Map<String, List<String>> synergisticMuscles = {
    'Lats': ['Upper Back', 'Biceps', 'Traps', 'Rear Delts'],
    'Upper Back': ['Lats', 'Biceps', 'Traps', 'Rear Delts'],
    'Biceps': ['Lats', 'Upper Back'],
    'Triceps': ['Chest', 'Front Delts'],
    'Calves': ['Hamstring', 'Quad'],
    'Chest': ['Triceps', 'Front Delts'],
    'Front Delts': ['Chest', 'Triceps'],
    'Glutes': ['Hamstring', 'Quad'],
    'Hamstring': ['Glutes', 'Calves'],
    'Quad': ['Glutes', 'Hamstring'],
    'Rear Delts': ['Upper Back', 'Traps'],
    'Side Delts': ['Rear Delts', 'Traps'],
    'Traps': ['Upper Back', 'Rear Delts', 'Side Delts']
    // Weitere synergistische Muskelgruppen können hier hinzugefügt werden
  };

  final Map<String, List<String>> antagonisticMuscles = {
    'Chest': ['Lats', 'Upper Back'],
    'Lats': ['Chest'],
    'Upper Back': ['Chest'],
    'Biceps': ['Triceps'],
    'Triceps': ['Biceps'],
    'Quad': ['Hamstring'],
    'Hamstring': ['Quad'],
    'Front Delts': ['Rear Delts'],
    'Rear Delts': ['Front Delts'],
    // Weitere antagonistische Paare können hier hinzugefügt werden
  };

  // Definiere Oberkörper- und Unterkörpermuskelgruppen
  final Set<String> upperBodyMuscles = {
    'Chest',
    'Lats',
    'Upper Back',
    'Biceps',
    'Triceps',
    'Front Delts',
    'Rear Delts',
    'Side Delts',
    'Traps',
  };

  final Set<String> lowerBodyMuscles = {
    'Quad',
    'Hamstring',
    'Glutes',
    'Calves',
    'Abs',
  };

  @override
  void initState() {
    super.initState();
    _loadSplitData();
  }

  Future<void> _loadSplitData() async {
    try {
      final String response =
          await rootBundle.loadString('assets/database/splits.json');
      final data = await json.decode(response);
      setState(() {
        splitVariants = data['split_variants'] as List<dynamic>;
        // Filtere die Splits basierend auf der Trainingsfrequenz
        filteredSplits = splitVariants
            .where((split) => split['days'].length == widget.trainingFrequency)
            .toList();
        splitData = data;
        weeklyVolumeDistribution = _calculateTotalVolumeDistribution();
      });
      print(
          'Geladene Splits: ${filteredSplits.map((s) => s['name']).toList()}');
    } catch (e) {
      print('Fehler beim Laden der Splits: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Fehler beim Laden der Splits. Bitte versuche es später erneut.')),
      );
    }

    // Berechne die Bewertungsmetriken für die Standard-Splits
    _calculateAllSplitMetrics();
    _identifyBestSplit();

    // Generiere einen individuellen Split, wenn die Trainingsfrequenz größer als 1 ist
    if (widget.trainingFrequency > 1) {
      await _generateIndividualSplit();
    }
  }

  // Angepasste Funktion zur Sortierung der Muskelgruppen
  List<String> sortMuscleGroupsBySynergy(List<String> muscleGroups) {
    List<String> sorted = [];
    Set<String> visited = Set<String>();

    // Entferne Muskelgruppen, die nicht trainiert werden sollen
    muscleGroups = muscleGroups.where((muscle) {
      return widget.selection[muscle] != 'Nicht Trainieren';
    }).toList();

    // Definiere die Reihenfolge der großen Muskelgruppen
    List<String> largeMuscles = [
      'Chest',
      'Lats',
      'Upper Back',
      'Quad',
      'Hamstring',
      'Glutes'
    ];

    // Aktualisiere die Prioritäten
    Map<String, int> focusPriority = {
      'Fokussieren': 1,
      'Etwas Fokussieren': 2,
      'Normal': 3,
      'Vernachlässigen': 4,
    };

    // Funktion zur Ermittlung der Priorität einer Muskelgruppe
    int getMusclePriority(String muscle) {
      String focus = widget.selection[muscle] ?? 'Normal';
      return focusPriority[focus] ?? 3; // Standardmäßig 'Normal' Priorität
    }

    // Berechne die kombinierte Priorität für Lats und Upper Back
    int latsPriority = getMusclePriority('Lats');
    int upperBackPriority = getMusclePriority('Upper Back');

    int combinedPriority;
    if (latsPriority == 1 || upperBackPriority == 1) {
      combinedPriority = 1;
    } else if (latsPriority == 2 || upperBackPriority == 2) {
      combinedPriority = 2;
    } else {
      combinedPriority = max(latsPriority, upperBackPriority);
    }

    // Sortiere die großen Muskelgruppen
    List<String> largeMusclesOrdered = [];

    largeMuscles.forEach((muscle) {
      if (muscleGroups.contains(muscle)) {
        int priority;
        if (muscle == 'Lats' || muscle == 'Upper Back') {
          priority = combinedPriority;
        } else {
          priority = getMusclePriority(muscle);
        }
        largeMusclesOrdered.add('$priority|$muscle');
      }
    });

    // Sortiere nach Priorität und entferne die Priorität aus dem Namen
    largeMusclesOrdered.sort();
    largeMusclesOrdered =
        largeMusclesOrdered.map((e) => e.split('|')[1]).toList();

    // Füge die sortierten großen Muskelgruppen hinzu
    for (var muscle in largeMusclesOrdered) {
      if (!visited.contains(muscle)) {
        sorted.add(muscle);
        visited.add(muscle);
      }
    }

    // Füge fokussierte Muskelgruppen hinzu, die nicht zu den großen Muskelgruppen gehören
    List<String> focusedMuscles = [];
    widget.selection.forEach((muscle, focus) {
      if ((focus == 'Fokussieren' || focus == 'Etwas Fokussieren') &&
          muscleGroups.contains(muscle) &&
          !largeMuscles.contains(muscle)) {
        int priority = focusPriority[focus] ?? 3;
        focusedMuscles.add('$priority|$muscle');
      }
    });

    // Sortiere die fokussierten Muskelgruppen nach Priorität
    focusedMuscles.sort();
    focusedMuscles = focusedMuscles.map((e) => e.split('|')[1]).toList();

    // Füge die fokussierten Muskelgruppen hinzu
    for (var muscle in focusedMuscles) {
      if (!visited.contains(muscle)) {
        sorted.add(muscle);
        visited.add(muscle);
      }
    }

    // Füge die restlichen Muskelgruppen entsprechend der Fokussierung hinzu
    List<String> remainingMuscles = muscleGroups.where((muscle) {
      return !visited.contains(muscle) && !largeMuscles.contains(muscle);
    }).toList();

    remainingMuscles.sort((a, b) {
      int priorityA = getMusclePriority(a);
      int priorityB = getMusclePriority(b);
      return priorityA.compareTo(priorityB);
    });

    // Füge die restlichen Muskelgruppen hinzu
    for (var muscle in remainingMuscles) {
      if (!visited.contains(muscle)) {
        sorted.add(muscle);
        visited.add(muscle);
      }
    }

    return sorted;
  }

  Future<void> _generateIndividualSplit() async {
    if (widget.trainingFrequency < 2) return;

    // Entferne Muskelgruppen, die nicht trainiert werden sollen
    List<String> muscleGroups = widget.muscleGroups
        .map<String>((mg) => mg['name'] as String)
        .where((muscle) => widget.selection[muscle] != 'Nicht Trainieren')
        .toList();

    // Anpassung: Gruppiere Lats und Upper Back zusammen
    if (muscleGroups.contains('Upper Back')) {
      muscleGroups.remove('Upper Back');
    }

    // Erstelle die Muskelzuweisungen, wobei Lats und Upper Back kombiniert werden
    List<String> muscleAssignments = muscleGroups.expand((muscle) {
      if (muscle == 'Lats') {
        return ['Lats', 'Lats']; // Da Upper Back mit Lats kombiniert wird
      } else {
        return [muscle, muscle];
      }
    }).toList();

    int totalAssignments = muscleAssignments.length;
    int musclesPerDay = (totalAssignments / widget.trainingFrequency).ceil();

    int attempts = 10000;
    Map<String, dynamic>? bestAssignment;
    int bestDeviation = double.maxFinite.toInt();

    for (int i = 0; i < attempts; i++) {
      List<String> shuffled = List.from(muscleAssignments)..shuffle();
      List<List<String>> days =
          List.generate(widget.trainingFrequency, (_) => []);
      List<Set<String>> daysMuscleTypes =
          List.generate(widget.trainingFrequency, (_) => <String>{});

      bool valid = true;
      for (var muscle in shuffled) {
        bool isUpper = upperBodyMuscles.contains(muscle);
        bool isLower = lowerBodyMuscles.contains(muscle);
        List<int> possibleDays = [];

        for (int d = 0; d < widget.trainingFrequency; d++) {
          if (!days[d].contains(muscle) && days[d].length < musclesPerDay) {
            bool hasUpper = daysMuscleTypes[d].contains('upper');
            bool hasLower = daysMuscleTypes[d].contains('lower');

            if ((isUpper && hasLower) || (isLower && hasUpper)) continue;

            // Überprüfe, ob Muskel oder synergistische Muskeln an angrenzenden Tagen trainiert wurden/werden
            bool trainedAdjacentDay = false;
            List<String> synergisticAndMuscle = [muscle];
            if (synergisticMuscles[muscle] != null) {
              synergisticAndMuscle.addAll(synergisticMuscles[muscle]!);
            }

            if (d > 0) {
              if (days[d - 1].any((m) => synergisticAndMuscle.contains(m))) {
                trainedAdjacentDay = true;
              }
            }
            if (d < widget.trainingFrequency - 1) {
              if (days[d + 1].any((m) => synergisticAndMuscle.contains(m))) {
                trainedAdjacentDay = true;
              }
            }
            if (trainedAdjacentDay) continue;

            possibleDays.add(d);
          }
        }

        if (possibleDays.isEmpty) {
          valid = false;
          break;
        }

        int targetDay = possibleDays.reduce((a, b) {
          int synergyA = days[a]
              .where((m) => synergisticMuscles[m]?.contains(muscle) ?? false)
              .length;
          int synergyB = days[b]
              .where((m) => synergisticMuscles[m]?.contains(muscle) ?? false)
              .length;

          if (synergyA != synergyB) return synergyA > synergyB ? a : b;
          return days[a].length <= days[b].length ? a : b;
        });

        // Anpassung: Wenn der Muskel Lats ist, füge auch Upper Back hinzu
        if (muscle == 'Lats' && !days[targetDay].contains('Upper Back')) {
          days[targetDay].add('Upper Back');
        }

        days[targetDay].add(muscle);
        if (isUpper)
          daysMuscleTypes[targetDay].add('upper');
        else if (isLower) daysMuscleTypes[targetDay].add('lower');
      }

      if (!valid) continue;

      for (int d = 0; d < widget.trainingFrequency; d++) {
        days[d] = sortMuscleGroupsBySynergy(days[d]);
      }

      List<dynamic> splitDays = List.generate(
          widget.trainingFrequency,
          (d) => {
                'name': 'Tag ${d + 1}',
                'type': 'custom',
                'muscle_groups': days[d],
              });

      Map<String, dynamic> individualSplit = {
        'name': 'Individuell',
        'days': splitDays
      };
      final deviationResult =
          _calculateDeviationPerSplit(individualSplit['days']);
      final totalDeviation = deviationResult['totalDeviation'] as int;

      if (totalDeviation < bestDeviation) {
        bestDeviation = totalDeviation;
        bestAssignment = individualSplit;
      }
    }

    if (bestAssignment != null) {
      setState(() {
        filteredSplits.add(bestAssignment);
        _calculateAllSplitMetrics();
        _identifyBestSplit();
      });
      print('Individueller Split hinzugefügt: ${bestAssignment['name']}');
    } else {
      print(
          'Keine gültigen individuellen Splits nach $attempts Versuchen gefunden.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Individueller Split konnte nicht erstellt werden. Nur Standard-Splits werden angezeigt.')),
      );
    }
  }

  Map<String, int> _calculateTotalVolumeDistribution() {
    Map<String, int> totalVolumeDistribution = {};
    double totalTrainingTimePerWeek =
        widget.selectedDuration * widget.trainingFrequency;
    Map<String, double> relativeProportions = _getRelativeVolumeProportion();

    for (var muscleGroup in widget.muscleGroups) {
      String muscleName = muscleGroup['name'];

      // Überspringe Muskelgruppen, die nicht trainiert werden sollen
      if (widget.selection[muscleName] == 'Nicht Trainieren') {
        continue;
      }

      double proportion = relativeProportions[muscleName] ?? 0;
      double allocatedTimeForMuscle = proportion * totalTrainingTimePerWeek;
      int assignedVolume = (allocatedTimeForMuscle / (3 * 60)).round();
      totalVolumeDistribution[muscleName] = assignedVolume;
    }
    return totalVolumeDistribution;
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
          minVolume = muscleGroup['mv']['min'];
          maxVolume = muscleGroup['mv']['max'];
          break;
        case 'Nicht Trainieren':
          continue;
        default:
          break;
      }
      relativeProportions[muscleName] = (minVolume + maxVolume) / 2.0;
    }
    double totalVolume = relativeProportions.values.fold(0, (a, b) => a + b);
    totalVolume = totalVolume == 0 ? 1 : totalVolume;
    relativeProportions.updateAll((muscle, volume) => volume / totalVolume);
    return relativeProportions;
  }

  Map<String, Map<String, Map<String, int>>> _adjustVolumePerDay(
      List<dynamic> splitDays) {
    Map<String, Map<String, Map<String, int>>> adjustedVolume = {};
    _computeTrainingDays(splitDays);

    splitDays.forEach((day) {
      String dayName = day['name'];
      List<dynamic> musclesForDay = splitData['day_types'][day['type']] != null
          ? splitData['day_types'][day['type']]['muscle_groups']
          : day['muscle_groups'];
      int totalVolumeForDay = 0;
      musclesForDay.forEach((muscle) {
        totalVolumeForDay += weeklyVolumeDistribution[muscle] ?? 0;
      });
      double adjustmentFactor = totalVolumeForDay > widget.volumePerDay
          ? widget.volumePerDay / totalVolumeForDay
          : (widget.volumePerDay * 1.1) / totalVolumeForDay;
      Map<String, int> adjustedMuscleVolume = {};
      musclesForDay.forEach((muscle) {
        // Überspringe Muskelgruppen, die nicht trainiert werden sollen
        if (widget.selection[muscle] == 'Nicht Trainieren') {
          return;
        }

        int volume = weeklyVolumeDistribution[muscle] ?? 0;
        int adjustedSets = (volume * adjustmentFactor).round().clamp(1, 12);
        double maxVolumePerDay = ((weeklyVolumeDistribution[muscle] ?? 0) /
                (muscleGroupToTrainingDays[muscle] ?? 1))
            .clamp(1, widget.volumePerDay.toDouble());
        if (adjustedSets > maxVolumePerDay) {
          adjustedSets = maxVolumePerDay.round();
        }
        adjustedMuscleVolume[muscle] = adjustedSets;
      });
      adjustedVolume[dayName] = {'adjusted': adjustedMuscleVolume};
    });
    return adjustedVolume;
  }

  void _computeTrainingDays(List<dynamic> splitDays) {
    muscleGroupToTrainingDays = {};
    for (var muscleGroup in weeklyVolumeDistribution.keys) {
      int count = 0;
      for (var day in splitDays) {
        List<dynamic> musclesForDay =
            splitData['day_types'][day['type']] != null
                ? splitData['day_types'][day['type']]['muscle_groups']
                : day['muscle_groups'];

        // Überspringe Muskelgruppen, die nicht trainiert werden sollen
        if (widget.selection[muscleGroup] == 'Nicht Trainieren') {
          continue;
        }

        if (musclesForDay.contains(muscleGroup)) {
          count++;
        }
      }
      muscleGroupToTrainingDays[muscleGroup] = count;
    }
  }

  Map<String, dynamic> _calculateDeviationPerSplit(List<dynamic> splitDays) {
    Map<String, int> cumulativeVolume = {};
    Map<String, int> deviationFromTarget = {};
    int totalDeviation = 0;

    // Initialisiere das kumulierte Volumen für jede Muskelgruppe
    for (var muscle in weeklyVolumeDistribution.keys) {
      cumulativeVolume[muscle] = 0;
    }

    // Summiere das Volumen für jede Muskelgruppe über alle Trainingstage
    splitDays.forEach((day) {
      List<dynamic> musclesForDay = splitData['day_types'][day['type']] != null
          ? splitData['day_types'][day['type']]['muscle_groups']
          : day['muscle_groups'];
      Map<String, int> adjustedVolumeForDay =
          _adjustVolumePerDay(splitDays)[day['name']]?['adjusted'] ?? {};

      musclesForDay.forEach((muscle) {
        // Überspringe Muskelgruppen, die nicht trainiert werden sollen
        if (widget.selection[muscle] == 'Nicht Trainieren') {
          return;
        }

        cumulativeVolume[muscle] = (cumulativeVolume[muscle] ?? 0) +
            (adjustedVolumeForDay[muscle] ?? 0);
      });
    });

    // Berechnung der Abweichung vom angestrebten Volumen
    cumulativeVolume.forEach((muscle, volume) {
      int targetVolume = weeklyVolumeDistribution[muscle] ?? 0;
      int deviation = volume - targetVolume;
      deviationFromTarget[muscle] = deviation;
      totalDeviation += deviation.abs();
    });

    return {
      'deviationMap': deviationFromTarget,
      'totalDeviation': totalDeviation
    };
  }

  // Berechne die Abweichungen und zusätzlichen Kriterien für alle Splits
  void _calculateAllSplitMetrics() {
    splitMetrics.clear();
    for (var split in filteredSplits) {
      final deviationResult = _calculateDeviationPerSplit(split['days']);
      final totalDeviation = deviationResult['totalDeviation'] as int;
      final deviationMap = deviationResult['deviationMap'] as Map<String, int>;

      // Zusätzliche Kriterien
      int numberOfDeviations =
          deviationMap.values.where((dev) => dev != 0).length;

      splitMetrics[split['name']] = {
        'totalDeviation': totalDeviation,
        'numberOfDeviations': numberOfDeviations,
        'deviationMap': deviationMap,
      };
    }
  }

  // Identifiziere den besten Split unter Berücksichtigung zusätzlicher Kriterien
  void _identifyBestSplit() {
    if (splitMetrics.isEmpty) return;

    // Sortiere die Splits basierend auf den Kriterien
    List<MapEntry<String, Map<String, dynamic>>> sortedSplits =
        splitMetrics.entries.toList()
          ..sort((a, b) {
            // Primär nach totalDeviation
            int cmp =
                a.value['totalDeviation'].compareTo(b.value['totalDeviation']);
            if (cmp != 0) return cmp;

            // Sekundär nach numberOfDeviations (weniger ist besser)
            cmp = a.value['numberOfDeviations']
                .compareTo(b.value['numberOfDeviations']);
            if (cmp != 0) return cmp;

            return 0; // Keine weitere Sortierung
          });

    // Der beste Split ist der erste in der sortierten Liste
    bestSplitName = sortedSplits.first.key;
  }

  @override
  Widget build(BuildContext context) {
    // Bestimmen, ob das aktuelle Theme dunkel ist
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Farben anpassen basierend auf dem Theme
    Color recommendedBadgeColor = isDarkMode
        ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
        : Theme.of(context).colorScheme.primary.withOpacity(0.1);
    Color recommendedTextColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Verfügbare Splits')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Anzeige des angepeilten Wochenvolumens
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Angepeiltes Wochenvolumen pro Muskelgruppe:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  DataTable(
                    columns: const [
                      DataColumn(label: Text('Muskelgruppe')),
                      DataColumn(label: Text('Zielvolumen (Sätze)')),
                    ],
                    rows: weeklyVolumeDistribution.entries.map((entry) {
                      return DataRow(
                        cells: [
                          DataCell(Text(entry.key)),
                          DataCell(Text('${entry.value}')),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            // Zeige eine Meldung, wenn keine Splits verfügbar sind
            if (filteredSplits.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Keine verfügbaren Splits für die ausgewählte Trainingsfrequenz.',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              ),
            // Liste der Splits anzeigen, wenn vorhanden
            if (filteredSplits.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredSplits.length,
                itemBuilder: (context, index) {
                  final split = filteredSplits[index];
                  final adjustedVolume = _adjustVolumePerDay(split['days']);
                  final deviationResult =
                      _calculateDeviationPerSplit(split['days']);

                  // Überprüfen, ob dieser Split der beste Split ist
                  bool isBestSplit = split['name'] == bestSplitName;

                  // Holen der Bewertungsmetriken
                  final metrics = splitMetrics[split['name']];
                  if (metrics == null) {
                    return SizedBox.shrink();
                  }

                  return Card(
                    elevation: isBestSplit ? 4 : 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: isBestSplit
                          ? BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2)
                          : BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ExpansionTile(
                      leading: isBestSplit
                          ? Icon(
                              Icons.star,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              split['name'],
                              style: TextStyle(
                                fontWeight: isBestSplit
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (isBestSplit)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: recommendedBadgeColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Empfohlen',
                                style: TextStyle(
                                  color: recommendedTextColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Text(
                        'Trainingstage: ${split['days'].length}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      children: [
                        // Anzeige der Trainingstage und angepassten Volumen
                        ...split['days'].map<Widget>((day) {
                          String dayName = day['name'];
                          Map<String, int> dayVolume =
                              adjustedVolume[dayName]?['adjusted'] ?? {};

                          return ListTile(
                            title: Text(
                              dayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: dayVolume.entries.map<Widget>((entry) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Text(
                                    '${entry.key}: ${entry.value} Sätze',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }).toList(),
                        const Divider(),
                        // Anzeige der Bewertungsmetriken
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Gesamtabweichung
                              _buildMetricRow(
                                context,
                                'Gesamtabweichung',
                                metrics['totalDeviation'].toString(),
                                metrics['totalDeviation'] == 0
                                    ? Colors.green
                                    : Colors.red,
                                tooltip:
                                    'Die Summe der absoluten Abweichungen aller Muskelgruppen.',
                                metric: 'Gesamtabweichung',
                                splitName: split['name'],
                              ),
                              SizedBox(height: 8),
                              // Anzahl der Abweichungen
                              _buildMetricRow(
                                context,
                                'Anzahl der Abweichungen',
                                metrics['numberOfDeviations'].toString(),
                                metrics['numberOfDeviations'] == 0
                                    ? Colors.green
                                    : Colors.orange,
                                tooltip:
                                    'Wie viele Muskelgruppen eine Abweichung vom Zielvolumen haben.',
                                metric: 'Anzahl der Abweichungen',
                                splitName: split['name'],
                              ),
                            ],
                          ),
                        ),
                        // Details-Button hinzufügen
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, right: 16.0, bottom: 16.0),
                          child: ElevatedButton(
                            onPressed: () {
                              final dayTypes = splitData['day_types']
                                  as Map<String, dynamic>;

                              // Berechne das verteilte Volumen für den Split
                              final distributedVolume =
                                  _distributeVolumeAcrossDays(
                                      _calculateTotalVolumeDistribution(),
                                      split['days'],
                                      dayTypes);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SplitDetailScreen(
                                    split: split,
                                    distributedVolume: distributedVolume,
                                    weeklyVolumeDistribution:
                                        _calculateTotalVolumeDistribution(),
                                    volumeType: widget.volumeType,
                                    trainingFrequency: widget.trainingFrequency,
                                    volumePerDay: widget.volumePerDay,
                                    selectedDuration: widget.selectedDuration,
                                    trainingExperience:
                                        widget.trainingExperience,
                                    muscleGroups: widget.muscleGroups,
                                    selection: widget.selection,
                                    trainingWeeks:
                                        'Unbegrenzt', // Anpassen falls benötigt
                                    periodizationEnabled:
                                        false, // Anpassen falls benötigt
                                  ),
                                ),
                              );
                            },
                            child: Text('Details anzeigen'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              textStyle: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Methode zur Verteilung des Volumens über die Tage
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
      List<dynamic> musclesForDay = splitData['day_types'][dayType] != null
          ? splitData['day_types'][dayType]['muscle_groups']
          : day['muscle_groups'];

      muscleWeights[dayName] = {};
      for (var muscle in musclesForDay) {
        // Überspringe Muskelgruppen, die nicht trainiert werden sollen
        if (widget.selection[muscle] == 'Nicht Trainieren') {
          continue;
        }

        muscleWeights[dayName]![muscle] = 1 / musclesForDay.length.toDouble();
        muscleWeightsSum[muscle] =
            (muscleWeightsSum[muscle] ?? 0) + muscleWeights[dayName]![muscle]!;
      }
    }

    for (var day in splitDays) {
      String dayName = day['name'];
      String dayType = day['type'];
      List<dynamic> musclesForDay = splitData['day_types'][dayType] != null
          ? splitData['day_types'][dayType]['muscle_groups']
          : day['muscle_groups'];

      Map<String, int> dayVolume = {};

      for (var muscle in musclesForDay) {
        // Überspringe Muskelgruppen, die nicht trainiert werden sollen
        if (widget.selection[muscle] == 'Nicht Trainieren') {
          continue;
        }

        int totalVolume = totalVolumeDistribution[muscle] ?? 0;
        double normalizedWeight =
            (muscleWeights[dayName]![muscle] ?? 0) / muscleWeightsSum[muscle]!;
        double rawVolume = totalVolume * normalizedWeight;
        int allocatedVolume = rawVolume.round();
        double maxVolumePerDay = ((weeklyVolumeDistribution[muscle] ?? 0) /
                (muscleGroupToTrainingDays[muscle] ?? 1))
            .clamp(1, widget.volumePerDay.toDouble());
        if (allocatedVolume > maxVolumePerDay) {
          allocatedVolume = maxVolumePerDay.round();
        }
        dayVolume[muscle] = allocatedVolume;
      }

      dailyVolume[dayName] = dayVolume;
    }

    return dailyVolume;
  }

  // Hilfsmethode zum Erstellen einer Bewertungsmetrik-Zeile mit klickbarem Info-Icon
  Widget _buildMetricRow(
    BuildContext context,
    String label,
    String value,
    Color color, {
    required String tooltip,
    required String metric,
    required String splitName,
  }) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            _showMetricDetails(context, metric, splitName);
          },
          child: Tooltip(
            message: tooltip,
            child: Icon(
              Icons.info_outline,
              size: 20,
              color: Colors.grey[600],
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 14, color: color),
        ),
      ],
    );
  }

  // Methode zum Anzeigen eines Dialogfensters mit Berechnungsdetails der Metrik
  void _showMetricDetails(
      BuildContext context, String metric, String splitName) {
    String title = '';
    String content = '';

    final metrics = splitMetrics[splitName];
    if (metrics == null) {
      title = 'Information';
      content = 'Keine Details verfügbar.';
    } else {
      final deviationMap = metrics['deviationMap'] as Map<String, int>;
      switch (metric) {
        case 'Gesamtabweichung':
          title = 'Gesamtabweichung Berechnung';
          content =
              'Die Gesamtabweichung ist die Summe der absoluten Abweichungen aller Muskelgruppen.\n\nBerechnung:\n';
          List<String> deviations = deviationMap.entries
              .map((e) => '${e.key}: |${e.value}|')
              .toList();
          content += deviations.join(' + ');
          content += '\n\nGesamtabweichung: ${metrics['totalDeviation']} Sätze';
          break;
        case 'Anzahl der Abweichungen':
          title = 'Anzahl der Abweichungen Berechnung';
          content =
              'Die Anzahl der Abweichungen gibt an, wie viele Muskelgruppen eine Abweichung vom Zielvolumen haben.\n\nBerechnung:\n';
          List<String> deviatedMuscles = deviationMap.entries
              .where((e) => e.value != 0)
              .map((e) => e.key)
              .toList();
          content +=
              'Muskelgruppen mit Abweichung: ${deviatedMuscles.join(', ')}\n\n';
          content +=
              'Anzahl der Abweichungen: ${metrics['numberOfDeviations']}';
          break;
        default:
          title = 'Information';
          content = 'Keine Details verfügbar.';
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(content),
          ),
          actions: [
            TextButton(
              child: Text('Schließen'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
