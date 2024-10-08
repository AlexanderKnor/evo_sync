import 'package:flutter/material.dart';

class TrainingVolumeTable extends StatelessWidget {
  final List<dynamic> muscleGroups;
  final Map<String, int> totalVolumeDistribution;
  final Map<String, double> relativeProportions;
  final int totalSets;
  final int trainingFrequency;

  TrainingVolumeTable({
    required this.muscleGroups,
    required this.totalVolumeDistribution,
    required this.relativeProportions,
    required this.totalSets,
    required this.trainingFrequency,
  });

  @override
  Widget build(BuildContext context) {
    // Berechnung des täglichen Volumens für jede Muskelgruppe
    Map<String, double> dailyVolumeProportions = {};
    muscleGroups.forEach((muscleGroup) {
      String muscleName = muscleGroup['name'];
      int totalVolume = totalVolumeDistribution[muscleName] ?? 0;
      double dailyVolume =
          trainingFrequency > 0 ? totalVolume / trainingFrequency : 0;
      dailyVolumeProportions[muscleName] = dailyVolume;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Volumen pro Muskelgruppe:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            return DataTable(
              columnSpacing: 10,
              headingRowHeight: 30,
              dataRowHeight: 25,
              columns: [
                DataColumn(
                  label: Flexible(
                    child: Text(
                      'Muskelgruppe',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                DataColumn(
                  label: Flexible(
                    child: Text(
                      'Sätze/Woche',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                DataColumn(
                  label: Flexible(
                    child: Text(
                      'Sätze/Tag',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                DataColumn(
                  label: Flexible(
                    child: Text(
                      'Relative Gewichtung',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
              rows: [
                // Zeilen für jede Muskelgruppe
                ...muscleGroups.map((muscleGroup) {
                  final muscleName = muscleGroup['name'];
                  final totalVolume = totalVolumeDistribution[muscleName] ?? 0;
                  final dailyVolume = dailyVolumeProportions[muscleName] ?? 0.0;
                  final relativeWeight =
                      (relativeProportions[muscleName]! * 100)
                          .toStringAsFixed(1); // Prozentuale Darstellung

                  return DataRow(cells: [
                    DataCell(
                      Text(
                        muscleName,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    DataCell(
                      Text(
                        '$totalVolume',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${dailyVolume.toStringAsFixed(1)}',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    DataCell(
                      Text(
                        '$relativeWeight%',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ]);
                }).toList(),
                // Gesamtsumme
                DataRow(
                  cells: [
                    DataCell(
                      Text(
                        'Total',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(
                      Text(
                        '$totalSets',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${(totalSets / trainingFrequency).toStringAsFixed(1)}',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(
                      Text(
                        '100.0%',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
