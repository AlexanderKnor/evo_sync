import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:evosync/models/profile.dart';
import 'package:evosync/database_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Profile? userProfile;

  String _svgFrontsideString = '';
  String _svgBacksideString = '';
  bool _isSwapped = false;

  late Map<String, List<String>> _frontsideGroupedIds;
  late Map<String, List<String>> _backsideGroupedIds;

  // Separate Maps für Vorder- und Rückseite
  late Map<String, int> _frontsideSliderValues;
  late Map<String, int> _backsideSliderValues;
  late Map<String, int> _currentSliderValues;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    List<Profile> profiles = await _dbHelper.getProfiles();
    if (profiles.isNotEmpty) {
      setState(() {
        userProfile = profiles.first;
        print('Loaded Profile: $userProfile');
        _initializeSettings();
      });
    }
  }

  void _initializeSettings() async {
    if (userProfile != null) {
      final String gender = userProfile!.gender.toLowerCase();
      if (gender == 'weiblich') {
        _frontsideGroupedIds = {
          "Gruppe 1": ['_x30_5', '_x33_1'],
          "Gruppe 2": ['_x30_7', '_x33_3'],
          "Gruppe 3": ['_x30_6', '_x33_2'],
        };
        _backsideGroupedIds = {
          "Gruppe 1": ['_x31_2', '_x33_5'],
          "Gruppe 2": ['_x34_6', '_x32_3'],
          "Gruppe 3": ['_x34_3', '_x32_0'],
        };
        _svgFrontsideString =
            await rootBundle.loadString('assets/images/female_frontside.svg');
        _svgBacksideString =
            await rootBundle.loadString('assets/images/female_backside.svg');
      } else if (gender == 'männlich') {
        _frontsideGroupedIds = {
          "Gruppe 1": ['_x35_2', '_x32_6'],
          "Gruppe 2": ['_x33_2', '_x30_6'],
          "Gruppe 3": ['_x33_1', '_x30_5'],
        };
        _backsideGroupedIds = {
          "Gruppe 1": ['_x33_6', '_x31_5'],
          "Gruppe 2": ['_x34_1', '_x32_0'],
          "Gruppe 3": ['_x34_2', '_x32_1'],
        };
        _svgFrontsideString =
            await rootBundle.loadString('assets/images/male_frontside.svg');
        _svgBacksideString =
            await rootBundle.loadString('assets/images/male_backside.svg');
      }

      _initializeSliderValues();
      setState(() {});
    }
  }

  void _initializeSliderValues() {
    // Standardwerte für die Slider-Einstellungen der Vorderseite
    _frontsideSliderValues = {
      for (var group in _frontsideGroupedIds.keys) group: 2,
    };
    // Standardwerte für die Slider-Einstellungen der Rückseite
    _backsideSliderValues = {
      for (var group in _backsideGroupedIds.keys) group: 2,
    };
    // Aktuelle Slider-Einstellungen setzen
    _currentSliderValues = _frontsideSliderValues;
  }

  void _swapSvgs() {
    setState(() {
      _isSwapped = !_isSwapped;
      if (_isSwapped) {
        _currentSliderValues = _backsideSliderValues;
      } else {
        _currentSliderValues = _frontsideSliderValues;
      }
    });
  }

  Color _colorFromValue(int value) {
    switch (value) {
      case 0:
        return const Color.fromARGB(255, 128, 128, 128);
      case 1:
        return const Color.fromARGB(255, 189, 189, 189);
      case 2:
        return const Color.fromARGB(255, 255, 255, 255);
      case 3:
        return const Color.fromARGB(255, 222, 253, 255);
      case 4:
        return const Color.fromARGB(255, 190, 251, 255);
      default:
        return Colors.white;
    }
  }

  String _updateSvgColors(String svgString, Map<String, Color> colors,
      Map<String, List<String>> groupedIds) {
    for (var group in groupedIds.values) {
      for (var id in group) {
        final color = colors[id];
        if (color != null) {
          final hexColor = color.value.toRadixString(16).substring(2);

          final regex =
              RegExp(r'(<path[^>]*id="' + id + r'"[^>]*fill=")[^"]+(")');
          svgString = svgString.replaceFirst(
            regex,
            '${regex.firstMatch(svgString)?.group(1)}#$hexColor${regex.firstMatch(svgString)?.group(2)}',
          );
        }
      }
    }
    return svgString;
  }

  String _getLabelText(int value) {
    switch (value) {
      case 0:
        return "Nicht trainieren";
      case 1:
        return "Vernachlässigen";
      case 2:
        return "Normal";
      case 3:
        return "Etwas fokussieren";
      case 4:
        return "Fokussieren";
      default:
        return "Normal";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _svgFrontsideString.isEmpty || _svgBacksideString.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: TweenAnimationBuilder<Color?>(
                        tween: ColorTween(
                          begin: Colors.white,
                          end: Colors.white,
                        ),
                        duration: const Duration(milliseconds: 500),
                        builder: (context, color, child) {
                          Map<String, Color> currentColors = {
                            for (var group in _currentSliderValues.keys)
                              for (var id in (_isSwapped
                                  ? _backsideGroupedIds
                                  : _frontsideGroupedIds)[group]!)
                                id: _colorFromValue(
                                    _currentSliderValues[group]!)
                          };
                          return SvgPicture.string(
                            _isSwapped
                                ? _updateSvgColors(_svgBacksideString,
                                    currentColors, _backsideGroupedIds)
                                : _updateSvgColors(_svgFrontsideString,
                                    currentColors, _frontsideGroupedIds),
                            semanticsLabel: 'Frontside or Backside',
                            height: 560.0,
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: _currentSliderValues.keys.map((group) {
                          return Column(
                            children: [
                              Text(
                                group,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                _getLabelText(_currentSliderValues[group]!),
                                style: const TextStyle(fontSize: 18),
                              ),
                              Slider(
                                value: _currentSliderValues[group]!.toDouble(),
                                min: 0,
                                max: 4,
                                divisions: 4,
                                onChanged: (value) {
                                  setState(() {
                                    _currentSliderValues[group] = value.round();
                                  });
                                },
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 60,
                  right: 20,
                  child: GestureDetector(
                    onTap: _swapSvgs,
                    child: SvgPicture.string(
                      _isSwapped
                          ? _updateSvgColors(
                              _svgFrontsideString,
                              {
                                for (var group in _frontsideSliderValues.keys)
                                  for (var id in _frontsideGroupedIds[group]!)
                                    id: _colorFromValue(
                                        _frontsideSliderValues[group]!)
                              },
                              _frontsideGroupedIds)
                          : _updateSvgColors(
                              _svgBacksideString,
                              {
                                for (var group in _backsideSliderValues.keys)
                                  for (var id in _backsideGroupedIds[group]!)
                                    id: _colorFromValue(
                                        _backsideSliderValues[group]!)
                              },
                              _backsideGroupedIds),
                      semanticsLabel: 'Frontside or Backside',
                      width: 100.0,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SettingsScreen(),
  ));
}
