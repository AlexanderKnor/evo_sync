import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evosync/theme/dark_mode_notifier.dart';
import 'package:evosync/widgets/generic/custom_number_input_screen.dart';
import 'package:evosync/models/sportarten_met_converter.dart';

class KrafttrainingCalculator extends StatefulWidget {
  final double gewicht;
  final Function(double) onKrafttrainingCalculated;

  const KrafttrainingCalculator({
    Key? key,
    required this.gewicht,
    required this.onKrafttrainingCalculated,
  }) : super(key: key);

  @override
  _KrafttrainingCalculatorState createState() =>
      _KrafttrainingCalculatorState();
}

class _KrafttrainingCalculatorState extends State<KrafttrainingCalculator> {
  int _satzeLeicht = 0;
  int _satzeMittel = 0;
  int _satzeSchwer = 0;

  double _kalorienLeicht = 0;
  double _kalorienMittel = 0;
  double _kalorienSchwer = 0;

  final double _metLeicht = 3.0;
  final double _metMittel = 5.0;
  final double _metSchwer = 8.0;

  final double _dauerProSatz = 1.0;

  String _selectedSportart = 'Keine Auswahl';
  double _dauerSportart = 0;
  double _kalorienSportart = 0;

  Map<String, double> _sportartenMet = {'Keine Auswahl': 0.0}; // Standardwert

  @override
  void initState() {
    super.initState();
    _loadSportartenMet();
  }

  Future<void> _loadSportartenMet() async {
    final loadedData = await SportartenMetConverter.loadSportartenMet(
        'assets/database/sportarten_met.json');
    setState(() {
      _sportartenMet.addAll(loadedData);
    });
  }

  @override
  void didUpdateWidget(covariant KrafttrainingCalculator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gewicht != widget.gewicht) {
      _calculateKalorien();
    }
  }

  void _calculateKalorien() {
    double kalorienLeicht = _calculateForIntensity(_satzeLeicht, _metLeicht);
    double kalorienMittel = _calculateForIntensity(_satzeMittel, _metMittel);
    double kalorienSchwer = _calculateForIntensity(_satzeSchwer, _metSchwer);
    double kalorienSportart =
        _calculateForSportart(_dauerSportart, _selectedSportart);

    if (kalorienLeicht != _kalorienLeicht ||
        kalorienMittel != _kalorienMittel ||
        kalorienSchwer != _kalorienSchwer ||
        kalorienSportart != _kalorienSportart) {
      setState(() {
        _kalorienLeicht = kalorienLeicht;
        _kalorienMittel = kalorienMittel;
        _kalorienSchwer = kalorienSchwer;
        _kalorienSportart = kalorienSportart;
      });

      double totalKalorien = _kalorienLeicht +
          _kalorienMittel +
          _kalorienSchwer +
          _kalorienSportart;
      widget.onKrafttrainingCalculated(totalKalorien);
    }
  }

  double _calculateForIntensity(int satze, double met) {
    return satze * _dauerProSatz * met * widget.gewicht * 0.01667;
  }

  double _calculateForSportart(double dauer, String sportart) {
    double met = _sportartenMet[sportart] ?? 1.0;
    return dauer * met * widget.gewicht * 0.01667;
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Information'),
        content: const Text(
          'Hier kannst du den Kalorienverbrauch für dein Krafttraining und andere Aktivitäten berechnen.',
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

  void _handleDauerChanged(String value) {
    final parsedDauer = double.tryParse(value) ?? 0;
    if (parsedDauer != _dauerSportart) {
      setState(() {
        _dauerSportart = parsedDauer;
      });
      _calculateKalorien();
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
                '3. Aktives Training (TEA)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Was und wie lange hast du trainiert?',
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _buildKrafttrainingSlider(
                context,
                'Krafttraining, leicht',
                _satzeLeicht,
                (value) {
                  setState(() {
                    _satzeLeicht = value;
                  });
                  _calculateKalorien();
                },
                _kalorienLeicht,
                isDarkMode,
              ),
              const SizedBox(height: 16),
              _buildKrafttrainingSlider(
                context,
                'Krafttraining, mittel',
                _satzeMittel,
                (value) {
                  setState(() {
                    _satzeMittel = value;
                  });
                  _calculateKalorien();
                },
                _kalorienMittel,
                isDarkMode,
              ),
              const SizedBox(height: 16),
              _buildKrafttrainingSlider(
                context,
                'Krafttraining, schwer',
                _satzeSchwer,
                (value) {
                  setState(() {
                    _satzeSchwer = value;
                  });
                  _calculateKalorien();
                },
                _kalorienSchwer,
                isDarkMode,
              ),
              const SizedBox(height: 32),
              Text(
                'Zusätzliche Sportarten',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              if (_sportartenMet.isNotEmpty) // Nur wenn Daten geladen sind
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: _selectedSportart,
                        items: _sportartenMet.keys
                            .map((String sportart) => DropdownMenuItem<String>(
                                  value: sportart,
                                  child: Text(
                                    sportart,
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedSportart = newValue!;
                            _calculateKalorien();
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Sportart',
                          labelStyle: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor:
                              isDarkMode ? Colors.grey[700] : Colors.grey[300],
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () async {
                          String? result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CustomNumberInputScreen(
                                initialValue: _dauerSportart.toString(),
                                title: 'Dauer',
                                suffix: 'Min',
                                step: 5.0,
                                minValue: 0.0,
                                maxValue: 240.0,
                                onValueChanged: _handleDauerChanged,
                              ),
                            ),
                          );
                          if (result != null) {
                            _handleDauerChanged(result);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: isDarkMode
                                ? Colors.grey[700]
                                : Colors.grey[300],
                            border: Border.all(
                              color:
                                  isDarkMode ? Colors.white54 : Colors.black87,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _dauerSportart == 0
                                    ? 'Dauer'
                                    : _dauerSportart.toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              Text(
                                'Min',
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
              const SizedBox(height: 8),
              if (_kalorienSportart > 0)
                Text(
                  'Verbrauchte Kalorien: ${_kalorienSportart.toStringAsFixed(0)} kcal',
                  style: TextStyle(
                    fontSize: 18,
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

  Widget _buildKrafttrainingSlider(
    BuildContext context,
    String labelText,
    int satze,
    ValueChanged<int> onChanged,
    double kalorien,
    bool isDarkMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: satze.toDouble(),
                min: 0,
                max: 30,
                divisions: 30,
                label: '$satze Sätze',
                onChanged: (double value) {
                  onChanged(value.round());
                },
                activeColor: isDarkMode ? Colors.tealAccent : Colors.blueAccent,
                inactiveColor: isDarkMode ? Colors.grey : Colors.blue.shade100,
              ),
            ),
            Text(
              '$satze Sätze',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
        if (kalorien > 0)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: kalorien / 400,
              minHeight: 25,
              backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[400],
              valueColor: AlwaysStoppedAnimation<Color>(
                isDarkMode ? Colors.tealAccent : Colors.blueAccent,
              ),
            ),
          ),
        if (kalorien > 0) const SizedBox(height: 8),
        if (kalorien > 0)
          Text(
            'Verbrauchte Kalorien: ${kalorien.toStringAsFixed(0)} kcal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
      ],
    );
  }
}
