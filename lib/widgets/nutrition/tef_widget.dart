import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evosync/theme/dark_mode_notifier.dart';

class TefWidget extends StatelessWidget {
  final double rmr;
  final double neat;
  final double krafttraining;

  const TefWidget({
    Key? key,
    required this.rmr,
    required this.neat,
    required this.krafttraining,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Berechne den kumulierten Kalorienbedarf (ohne TEF)
    double cumulativeCalories = rmr + neat + krafttraining;

    // Gesamtenergieaufnahme berechnen, um den TEF zu berücksichtigen
    // Da der TEF 10% der Gesamtenergieaufnahme ausmacht, teilen wir durch 0.90,
    // um den Gesamtenergiebedarf (inkl. TEF) zu ermitteln.
    double totalCalories = cumulativeCalories / 0.90;

    // TEF berechnen als Differenz zwischen Gesamtenergieaufnahme und kumulierten Kalorien
    double tef = totalCalories - cumulativeCalories;

    final isDarkMode =
        Provider.of<DarkModeNotifier>(context).themeMode == ThemeMode.dark;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.6)
                    : Colors.grey.withOpacity(0.4),
                spreadRadius: 5,
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  'Thermic Effect of Food',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8.0),
              if (tef > 0) // Nur anzeigen, wenn der TEF-Wert über 0 ist
                Text(
                  '${tef.toStringAsFixed(0)} kcal',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.tealAccent : Colors.blueAccent,
                  ),
                ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: Icon(Icons.help_outline,
                color: isDarkMode ? Colors.white : Colors.black87),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Information'),
                  content: const SingleChildScrollView(
                    child: Text(
                      'Der Thermic Effect of Food (TEF) ist die Energie, '
                      'die Ihr Körper benötigt, um die aufgenommene Nahrung '
                      'zu verdauen, aufzunehmen und zu speichern. '
                      'Er macht etwa 10% des gesamten Kalorienverbrauchs aus.',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Verstanden'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
