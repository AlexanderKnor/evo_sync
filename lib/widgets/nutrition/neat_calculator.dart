import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:evosync/theme/dark_mode_notifier.dart';
import 'package:evosync/widgets/generic/custom_number_input_screen.dart';

class NeatCalculator extends StatefulWidget {
  final double gewicht; // Gewicht als Eingabeparameter
  final Function(double) onNeatCalculated; // Callback für NEAT-Wert

  const NeatCalculator({
    super.key,
    required this.gewicht,
    required this.onNeatCalculated,
  });

  @override
  _NeatCalculatorState createState() => _NeatCalculatorState();
}

class _NeatCalculatorState extends State<NeatCalculator> {
  int _steps = 0;
  double _neat = 0;
  late Stream<StepCount> _stepCountStream;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  void _requestPermissions() async {
    // Berechtigung für Schrittzähler anfragen
    var status = await Permission.activityRecognition.status;
    if (status.isDenied) {
      status = await Permission.activityRecognition.request();
    }

    if (status.isGranted) {
      _initPedometer();
    } else {
      print("Berechtigung für Aktivitätserkennung abgelehnt");
    }
  }

  void _initPedometer() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(_onStepCount).onError(_onStepCountError);
  }

  void _onStepCount(StepCount event) {
    setState(() {
      _steps = event.steps;
    });
    _calculateNeat();
  }

  void _onStepCountError(error) {
    print('Pedometer Error: $error');
  }

  void _calculateNeat() {
    double calculatedNeat = 0;

    if (widget.gewicht > 0 && _steps > 0) {
      const double schrittfaktor =
          0.00051; // Faktor: 0.00051 kcal pro Schritt pro kg
      calculatedNeat = _steps * widget.gewicht * schrittfaktor;
    }

    if (calculatedNeat != _neat) {
      setState(() {
        _neat = calculatedNeat;
      });
      widget.onNeatCalculated(_neat);
    }
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Information'),
        content: const Text(
          'Der Non-Exercise Activity Thermogenesis (NEAT) ist die Energie, die du durch alltägliche Aktivitäten verbrauchst, die nicht als gezieltes Training gelten. '
          'Gib die Anzahl der Schritte ein, die du in den letzten 24 Stunden gemacht hast, die nicht durch gezieltes Training zustande kamen. '
          'Falls du keinen Schrittzähler verwendet hast, kannst du dich an Schätzwerten orientieren. Je mehr du dich bewegst, desto höher ist dein NEAT-Wert.',
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
  }

  void _handleStepsChanged(String value) {
    final parsedSteps = int.tryParse(value) ?? 0;
    if (parsedSteps != _steps) {
      setState(() {
        _steps = parsedSteps;
      });
      _calculateNeat();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '2. Alltagsbewegung (NEAT)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                  children: const [
                    TextSpan(text: 'Schätzwerte: '),
                    TextSpan(
                      text: 'Inaktiv',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ': < 2.000. '),
                    TextSpan(
                      text: 'Wenig aktiv',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ': 5.000. '),
                    TextSpan(
                      text: 'Etwas aktiv',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ': 7.500. '),
                    TextSpan(
                      text: 'Aktiv',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ': 10.000. '),
                    TextSpan(
                      text: 'Hochaktiv',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ': > 12.500.'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        String? result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CustomNumberInputScreen(
                              initialValue: _steps.toString(),
                              title: 'Schritte',
                              suffix: 'Schritte',
                              step: 100.0, // Schrittweite für Schritte
                              minValue: 0.0, // Mindestwert für Schritte
                              maxValue: 50000.0, // Maximalwert für Schritte
                              onValueChanged: _handleStepsChanged,
                            ),
                          ),
                        );
                        if (result != null) {
                          _handleStepsChanged(result);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color:
                              isDarkMode ? Colors.grey[700] : Colors.grey[300],
                          border: Border.all(
                            color: isDarkMode ? Colors.white54 : Colors.black87,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _steps == 0 ? 'Schritte' : _steps.toString(),
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              'Schritte',
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_neat > 0)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value:
                        _neat / 1000, // Annahme von 1000 kcal als Maximalwert
                    minHeight: 25,
                    backgroundColor:
                        isDarkMode ? Colors.grey[700] : Colors.grey[400],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDarkMode ? Colors.tealAccent : Colors.blueAccent,
                    ),
                  ),
                ),
              if (_neat > 0) const SizedBox(height: 8),
              if (_neat > 0)
                Text(
                  'Alltagsaktivität (NEAT): ${_neat.toStringAsFixed(0)} kcal',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
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
            onPressed: () => _showInfoDialog(context),
          ),
        ),
      ],
    );
  }
}
