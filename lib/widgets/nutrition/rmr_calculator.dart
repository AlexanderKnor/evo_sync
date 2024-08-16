import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evosync/theme/dark_mode_notifier.dart';
import 'package:evosync/widgets/generic/custom_number_input_screen.dart';

class RmrCalculator extends StatefulWidget {
  final Function(double) onWeightChanged;
  final Function(double) onRmrCalculated;

  const RmrCalculator({
    super.key,
    required this.onWeightChanged,
    required this.onRmrCalculated,
  });

  @override
  // ignore: library_private_types_in_public_api
  _RmrCalculatorState createState() => _RmrCalculatorState();
}

class _RmrCalculatorState extends State<RmrCalculator> {
  double? _gewicht;
  int? _alter;
  int? _groesse;
  double? _koerperfettanteil;
  double _rmr = 0;
  int _selectedGenderIndex = 0; // 0 = Mann, 1 = Frau
  bool _useKatchMcArdle = false;

  late TextEditingController _gewichtController;
  late TextEditingController _alterController;
  late TextEditingController _groesseController;
  late TextEditingController _kfaController;

  @override
  void initState() {
    super.initState();
    _gewichtController = TextEditingController();
    _alterController = TextEditingController();
    _groesseController = TextEditingController();
    _kfaController = TextEditingController();
  }

  @override
  void dispose() {
    _gewichtController.dispose();
    _alterController.dispose();
    _groesseController.dispose();
    _kfaController.dispose();
    super.dispose();
  }

  void _calculateRMR() {
    double calculatedRMR = 0;

    if (_useKatchMcArdle) {
      if (_gewicht != null && _koerperfettanteil != null) {
        final lbm = _gewicht! * (1 - _koerperfettanteil! / 100);
        calculatedRMR = 370 + (21.6 * lbm);
      }
    } else {
      if (_gewicht != null && _alter != null && _groesse != null) {
        if (_selectedGenderIndex == 0) {
          calculatedRMR = 10 * _gewicht! + 6.25 * _groesse! - 5 * _alter! + 5;
        } else {
          calculatedRMR = 10 * _gewicht! + 6.25 * _groesse! - 5 * _alter! - 161;
        }
      }
    }

    if (calculatedRMR != _rmr) {
      setState(() {
        _rmr = calculatedRMR;
      });
      widget.onRmrCalculated(_rmr);
    }
  }

  void _handleWeightChange(String value) {
    final parsedWeight = double.tryParse(value);
    if (parsedWeight != null && parsedWeight != _gewicht) {
      setState(() {
        _gewicht = parsedWeight;
      });
      widget.onWeightChanged(parsedWeight);
      _calculateRMR();
    }
  }

  void _handleGenderSwitch(int index) {
    if (_selectedGenderIndex != index) {
      setState(() {
        _selectedGenderIndex = index;
      });
      _calculateRMR();
    }
  }

  void _handleFormulaSwitch(int index) {
    if (_useKatchMcArdle != (index == 1)) {
      setState(() {
        _useKatchMcArdle = index == 1;
      });
      _calculateRMR();
    }
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Information'),
        content: const Text(
          'Der Grundumsatz (RMR) ist die Menge an Energie, die dein Körper benötigt, um grundlegende Funktionen wie Atmung, Blutzirkulation und Zellproduktion aufrechtzuerhalten. '
          'Du kannst den RMR basierend auf Gewicht, Alter und Größe oder mithilfe des Körperfettanteils (KFA) berechnen. '
          'Die Mifflin-St Jeor-Formel wird für die Berechnung mit Gewicht, Alter und Größe verwendet, während die Katch-McArdle-Formel den KFA berücksichtigt.',
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
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  children: const [TextSpan(text: '1. Grundumsatz (RMR)')],
                ),
              ),
              const SizedBox(height: 8),
              ToggleButtons(
                borderRadius: BorderRadius.circular(10),
                selectedBorderColor: Colors.blue,
                selectedColor: Colors.white,
                fillColor: Colors.blue,
                color: isDarkMode ? Colors.white70 : Colors.black87,
                borderColor: Colors.blue,
                isSelected: [
                  _selectedGenderIndex == 0,
                  _selectedGenderIndex == 1
                ],
                onPressed: (index) {
                  _handleGenderSwitch(index);
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(Icons.male, size: 24),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(Icons.female, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ToggleButtons(
                borderRadius: BorderRadius.circular(10),
                selectedBorderColor: Colors.blue,
                selectedColor: Colors.white,
                fillColor: Colors.blue,
                color: isDarkMode ? Colors.white70 : Colors.black87,
                borderColor: Colors.blue,
                isSelected: [
                  _useKatchMcArdle == false,
                  _useKatchMcArdle == true
                ],
                onPressed: (index) {
                  _handleFormulaSwitch(index);
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('Gewicht, Alter, Größe'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('Gewicht und KFA'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInputField(
                context,
                'Gewicht',
                'kg',
                _gewichtController,
                _handleWeightChange,
                step: 0.1, // Schrittweite für Gewicht
                minValue: 20.0, // Mindestgewicht in kg
                maxValue: 200.0, // Maximalgewicht in kg
              ),
              const SizedBox(height: 16),
              if (_useKatchMcArdle)
                _buildInputField(
                  context,
                  'Körperfettanteil (KFA)',
                  '%',
                  _kfaController,
                  (value) {
                    final parsedValue = double.tryParse(value);
                    if (parsedValue != null &&
                        parsedValue != _koerperfettanteil) {
                      setState(() {
                        _koerperfettanteil = parsedValue;
                      });
                      _calculateRMR();
                    }
                  },
                  step: 0.1, // Schrittweite für KFA
                  minValue: 5.0, // Mindest-KFA in %
                  maxValue: 50.0, // Maximal-KFA in %
                )
              else ...[
                _buildInputField(
                  context,
                  'Alter',
                  'Jahre',
                  _alterController,
                  (value) {
                    final parsedValue = int.tryParse(value);
                    if (parsedValue != null && parsedValue != _alter) {
                      setState(() {
                        _alter = parsedValue;
                      });
                      _calculateRMR();
                    }
                  },
                  step: 1, // Schrittweite für Alter
                  minValue: 10, // Mindestalter in Jahren
                  maxValue: 100, // Maximalalter in Jahren
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  context,
                  'Größe',
                  'cm',
                  _groesseController,
                  (value) {
                    final parsedValue = int.tryParse(value);
                    if (parsedValue != null && parsedValue != _groesse) {
                      setState(() {
                        _groesse = parsedValue;
                      });
                      _calculateRMR();
                    }
                  },
                  step: 1, // Schrittweite für Größe
                  minValue: 100, // Mindestgröße in cm
                  maxValue: 250, // Maximalgröße in cm
                ),
              ],
              const SizedBox(height: 30),
              if (_rmr > 0)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _rmr / 3000,
                    minHeight: 25,
                    backgroundColor:
                        isDarkMode ? Colors.grey[700] : Colors.grey[400],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDarkMode ? Colors.tealAccent : Colors.blueAccent,
                    ),
                  ),
                ),
              if (_rmr > 0) const SizedBox(height: 8),
              if (_rmr > 0)
                Text(
                  'Grundumsatz: ${_rmr.toStringAsFixed(0)} kcal',
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

  Widget _buildInputField(
    BuildContext context,
    String labelText,
    String suffixText,
    TextEditingController controller,
    Function(String) onChanged, {
    required double step, // Neue step Eigenschaft
    required double minValue, // Mindestwert
    required double maxValue, // Maximalwert
  }) {
    final isDarkMode =
        Provider.of<DarkModeNotifier>(context).themeMode == ThemeMode.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            String? result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomNumberInputScreen(
                  initialValue: controller.text,
                  title: labelText,
                  suffix: suffixText,
                  onValueChanged: (value) {
                    controller.text = value;
                    onChanged(value);
                  },
                  step: step, // Schrittwert wird hier übergeben
                  minValue: minValue, // Mindestwert wird hier übergeben
                  maxValue: maxValue, // Maximalwert wird hier übergeben
                ),
              ),
            );
            if (result != null) {
              onChanged(result);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
              border: Border.all(
                color: isDarkMode ? Colors.white54 : Colors.black87,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.text.isEmpty ? labelText : controller.text,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  suffixText,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
