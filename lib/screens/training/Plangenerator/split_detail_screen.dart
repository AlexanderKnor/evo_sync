// split_detail_screen.dart

import 'package:flutter/material.dart';

class SplitDetailScreen extends StatefulWidget {
  final Map<String, dynamic> split;
  final Map<String, Map<String, int>> distributedVolume;
  final Map<String, int> weeklyVolumeDistribution;
  final String volumeType;
  final int trainingFrequency;
  final int volumePerDay;
  final double selectedDuration;
  final String trainingExperience;
  final List<dynamic> muscleGroups;
  final Map<String, String> selection;
  final String trainingWeeks;

  // Neuer Parameter für die Periodisierung
  final bool periodizationEnabled;

  SplitDetailScreen({
    required this.split,
    required this.distributedVolume,
    required this.weeklyVolumeDistribution,
    required this.volumeType,
    required this.trainingFrequency,
    required this.volumePerDay,
    required this.selectedDuration,
    required this.trainingExperience,
    required this.muscleGroups,
    required this.selection,
    required this.trainingWeeks, // Existierender Parameter für die Trainingsdauer in Wochen
    required this.periodizationEnabled, // Neuer Parameter für die Periodisierung
  });

  @override
  _SplitDetailScreenState createState() => _SplitDetailScreenState();
}

class _SplitDetailScreenState extends State<SplitDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;
  Map<String, int> _filteredWeeklyVolume = {};
  Map<String, int> _muscleGroupToTrainingDays = {};
  late Map<String, Map<String, Map<String, int>>> adjustedVolume;

  @override
  void initState() {
    super.initState();
    final List<dynamic> days = widget.split['days'];
    _tabController = TabController(length: days.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    _computeTrainingDays(); // Zuerst Trainingstage berechnen
    adjustedVolume = _adjustVolumePerDay(); // Dann Volumen anpassen
    _updateFilteredWeeklyVolume(); // Und schließlich die Tabelle aktualisieren
  }

  @override
  void didUpdateWidget(covariant SplitDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _computeTrainingDays(); // Trainingstage neu berechnen bei Widget-Update
    adjustedVolume = _adjustVolumePerDay(); // Volumen neu anpassen
    _updateFilteredWeeklyVolume(); // Tabelle aktualisieren
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return; // Vermeidet mehrfaches Aufrufen
    setState(() {
      _currentTabIndex = _tabController.index;
      _updateFilteredWeeklyVolume();
    });
  }

  void _computeTrainingDays() {
    // Berechne, wie viele Tage jede Muskelgruppe trainiert wird
    _muscleGroupToTrainingDays = {};
    for (var muscleGroup in widget.weeklyVolumeDistribution.keys) {
      int count = 0;
      for (var day in widget.split['days']) {
        String dayName = day['name'];
        if (widget.distributedVolume[dayName]?.containsKey(muscleGroup) ??
            false) {
          count++;
        }
      }
      _muscleGroupToTrainingDays[muscleGroup] = count;
    }
  }

  void _updateFilteredWeeklyVolume() {
    final List<dynamic> days = widget.split['days'];
    if (_currentTabIndex >= days.length) return;

    String currentDayName = days[_currentTabIndex]['name'];
    // Typumwandlung hinzufügen, um den Fehler zu beheben
    Map<String, int> currentDayVolume =
        (adjustedVolume[currentDayName]?['adjusted'] as Map<String, int>?) ??
            {};

    Set<String> activeMuscleGroups = currentDayVolume.keys.toSet();

    // Filtere das weeklyVolumeDistribution basierend auf aktiven Muskelgruppen
    _filteredWeeklyVolume = Map.fromEntries(
      widget.weeklyVolumeDistribution.entries.where(
        (entry) => activeMuscleGroups.contains(entry.key),
      ),
    );
  }

  // Methode zur Anpassung des Volumens pro Tag
  Map<String, Map<String, Map<String, int>>> _adjustVolumePerDay() {
    Map<String, Map<String, Map<String, int>>> adjustedVolume = {};

    widget.distributedVolume.forEach((dayName, muscleVolume) {
      int totalVolumeForDay =
          muscleVolume.values.fold(0, (sum, sets) => sum + sets);
      double deviation =
          (totalVolumeForDay - widget.volumePerDay).abs() / widget.volumePerDay;

      double adjustmentFactor = 1.0;
      if (deviation > 0.1) {
        if (totalVolumeForDay > widget.volumePerDay) {
          // Anpassung nach unten, um nicht höher als volumePerDay zu sein
          adjustmentFactor = widget.volumePerDay / totalVolumeForDay;
        } else {
          // Anpassung nach oben, erlauben bis zu +10%
          adjustmentFactor = (widget.volumePerDay * 1.1) / totalVolumeForDay;
        }
      }

      Map<String, int> adjustedMuscleVolume = {};
      muscleVolume.forEach((muscle, sets) {
        int adjustedSets = (sets * adjustmentFactor).round();

        // Sicherstellen, dass die Anzahl der Sätze zwischen 1 und 12 liegt
        adjustedSets = adjustedSets.clamp(1, 12);

        // Berechne maxVolumePerDay für diese Muskelgruppe
        int trainingDays = _muscleGroupToTrainingDays[muscle] ?? 1;
        double maxVolumePerDay = trainingDays > 0
            ? widget.weeklyVolumeDistribution[muscle]! / trainingDays
            : 0.0;

        // Stelle sicher, dass das angepasste Volumen nicht das maximale Volumen pro Tag überschreitet
        double effectiveMaxVolumePerDay = maxVolumePerDay > widget.volumePerDay
            ? widget.volumePerDay.toDouble()
            : maxVolumePerDay;

        if (adjustedSets > effectiveMaxVolumePerDay) {
          adjustedSets = effectiveMaxVolumePerDay.round();
        }

        adjustedMuscleVolume[muscle] = adjustedSets;
      });

      adjustedVolume[dayName] = {
        'old': muscleVolume,
        'adjusted': adjustedMuscleVolume,
      };
    });

    return adjustedVolume;
  }

  // Methode zur Berechnung der geschätzten Trainingszeit pro Tag
  int _calculateEstimatedTimePerDay(
      String dayName, Map<String, int> dayVolume) {
    int totalSets =
        dayVolume.values.fold(0, (sum, sets) => sum + sets); // Summe der Sätze
    int totalSeconds = totalSets * 180; // 3 Minuten pro Satz in Sekunden
    return totalSeconds; // Rückgabe in Sekunden
  }

  // Methode zur Formatierung der Dauer in Stunden und Minuten
  String _formatDuration(int seconds) {
    Duration duration = Duration(seconds: seconds);
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
    final List<dynamic> days = widget.split['days'];
    final int tabCount = days.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.split['name']),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Theme(
            data: Theme.of(context).copyWith(
              tabBarTheme: TabBarTheme(
                labelStyle: TextStyle(fontSize: 12.0),
                unselectedLabelStyle: TextStyle(fontSize: 12.0),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: false, // Tabs werden gleichmäßig verteilt
              tabs: days.map<Widget>((day) {
                return Tab(text: day['name']);
              }).toList(),
            ),
          ),
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ExpansionTile(
                  title: Text(
                    'Wöchentliches Volumen pro Muskelgruppe:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  children: [
                    SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(
                              label: Text('Muskelgruppe',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Wochenvolumen (Sätze)',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Anzahl Trainingstage',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Max Volumen pro Tag (Sätze)',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: _filteredWeeklyVolume.entries.map((entry) {
                          String muscleGroup = entry.key;
                          int weeklyVolume = entry.value;
                          int trainingDays =
                              _muscleGroupToTrainingDays[muscleGroup] ?? 1;
                          double maxVolumePerDay = trainingDays > 0
                              ? widget.weeklyVolumeDistribution[muscleGroup]! /
                                  trainingDays
                              : 0.0;

                          // Stelle sicher, dass maxVolumePerDay nicht höher als volumePerDay ist
                          double effectiveMaxVolumePerDay =
                              maxVolumePerDay > widget.volumePerDay
                                  ? widget.volumePerDay.toDouble()
                                  : maxVolumePerDay;

                          return DataRow(cells: [
                            DataCell(Text(muscleGroup)),
                            DataCell(Text(weeklyVolume.toString())),
                            DataCell(Text(trainingDays.toString())),
                            DataCell(Text(
                                effectiveMaxVolumePerDay.toStringAsFixed(2))),
                          ]);
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: days.map<Widget>((day) {
            final dayName = day['name'];
            // Typumwandlung hinzufügen, um den Fehler zu beheben
            final dayVolumeData =
                adjustedVolume[dayName] as Map<String, dynamic>? ?? {};
            final adjustedDayVolume =
                dayVolumeData['adjusted'] as Map<String, int>? ?? {};
            final oldDayVolume =
                dayVolumeData['old'] as Map<String, int>? ?? {};

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayName,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      ...adjustedDayVolume.entries.map((entry) {
                        String muscle = entry.key;
                        int adjustedSets = entry.value;
                        int oldSets = oldDayVolume[muscle] ?? adjustedSets;
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
                        'Geschätzte Trainingszeit: ${_formatDuration(_calculateEstimatedTimePerDay(dayName, adjustedDayVolume))}',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Divider(),
                      SizedBox(height: 10),
                      Text(
                        'Trainingsdetails:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text('Volumen Typ: ${widget.volumeType}'),
                      Text(
                          'Trainingsfrequenz: ${widget.trainingFrequency} Tage/Woche'),
                      Text('Volumen pro Tag: ${widget.volumePerDay}'),
                      Text(
                          'Ausgewählte Dauer: ${_formatDuration(widget.selectedDuration.toInt())}'),
                      Text('Trainingserfahrung: ${widget.trainingExperience}'),
                      SizedBox(height: 10),
                      // Verwendung von ExpansionTile für die Muskelgruppen-Auswahl
                      ExpansionTile(
                        title: Text(
                          'Muskelgruppen Auswahl',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        children:
                            widget.muscleGroups.map<Widget>((muscleGroup) {
                          String muscleName = muscleGroup['name'];
                          String selectionStatus =
                              widget.selection[muscleName] ??
                                  'Nicht ausgewählt';
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
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
