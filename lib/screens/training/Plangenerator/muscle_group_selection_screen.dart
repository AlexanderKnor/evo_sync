import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xml/xml.dart' as xml;
import 'package:evosync/screens/training/Plangenerator/training_settings_screen.dart';

class MuscleGroupSelectionScreen extends StatefulWidget {
  final String trainingExperience;
  final List<dynamic> muscleGroups;
  final int trainingFrequency;
  final double selectedDuration;
  final String gender;

  const MuscleGroupSelectionScreen({
    required this.trainingExperience,
    required this.muscleGroups,
    required this.trainingFrequency,
    required this.selectedDuration,
    required this.gender,
    Key? key,
  }) : super(key: key);

  @override
  _MuscleGroupSelectionScreenState createState() =>
      _MuscleGroupSelectionScreenState();
}

class _MuscleGroupSelectionScreenState
    extends State<MuscleGroupSelectionScreen> {
  Map<String, List<String>>? frontsideGroupedIds;
  Map<String, List<String>>? backsideGroupedIds;
  Map<String, int> musclePriorities = {};
  String _svgFrontsideString = '';
  String _svgBacksideString = '';
  bool _isSwapped = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroupedIds();
    for (var muscleGroup in widget.muscleGroups) {
      musclePriorities[muscleGroup['name']] = 2;
    }
  }

  Future<void> _loadGroupedIds() async {
    try {
      final groupedIds = json.decode(
          await rootBundle.loadString('assets/database/body_svg_ids.json'));
      final gender =
          widget.gender.toLowerCase() == 'weiblich' ? 'female' : 'male';
      frontsideGroupedIds =
          _convertToMapOfStringLists(groupedIds[gender]['frontside']);
      backsideGroupedIds =
          _convertToMapOfStringLists(groupedIds[gender]['backside']);
      await _initializeSettings();
    } catch (e) {
      print('Fehler beim Laden der Daten: $e');
    }
  }

  Map<String, List<String>> _convertToMapOfStringLists(
      Map<String, dynamic> map) {
    return map
        .map((key, value) => MapEntry(key, List<String>.from(value as List)));
  }

  Future<void> _initializeSettings() async {
    if (frontsideGroupedIds == null || backsideGroupedIds == null) return;

    final gender =
        widget.gender.toLowerCase() == 'weiblich' ? 'female' : 'male';
    try {
      final svgResults = await Future.wait([
        rootBundle.loadString('assets/images/${gender}_frontside.svg'),
        rootBundle.loadString('assets/images/${gender}_backside.svg'),
      ]);
      _svgFrontsideString = svgResults[0];
      _svgBacksideString = svgResults[1];
    } catch (e) {
      print('Fehler beim Laden der SVGs: $e');
    }
    setState(() => _isLoading = false);
  }

  String _updateSvgColorsEfficiently(
      String svgString, Map<String, List<String>> groupedIds) {
    final document = xml.XmlDocument.parse(svgString);

    groupedIds.forEach((muscleGroup, ids) {
      int priorityValue = musclePriorities[muscleGroup] ?? 2;
      final color = _colorFromValue(priorityValue);
      final hexColor = color.value.toRadixString(16).substring(2);

      ids.forEach((id) {
        final elements = document
            .findAllElements('path')
            .where((element) => element.getAttribute('id') == id);

        for (var element in elements) {
          element.setAttribute('fill', '#$hexColor');
        }
      });
    });

    return document.toXmlString();
  }

  Color _colorFromValue(int value) {
    switch (value) {
      case 4:
        return const Color.fromARGB(255, 170, 255, 252); // Fokussieren
      case 3:
        return const Color.fromARGB(255, 216, 255, 254); // Etwas fokussieren
      case 2:
        return Colors.white; // Normal
      case 1:
        return const Color.fromARGB(255, 175, 175, 175); // Vernachlässigen
      case 0:
      default:
        return const Color.fromARGB(255, 125, 125, 125); // Nicht trainieren
    }
  }

  void _navigateToTrainingPlanSettings() {
    Map<String, String> selection = {};
    widget.muscleGroups.forEach((muscleGroup) {
      String muscleName = muscleGroup['name'];
      int priorityValue = musclePriorities[muscleName] ?? 2;

      switch (priorityValue) {
        case 4:
          selection[muscleName] = 'Fokussieren';
          break;
        case 3:
          selection[muscleName] = 'Etwas fokussieren';
          break;
        case 2:
          selection[muscleName] = 'Normal';
          break;
        case 1:
          selection[muscleName] = 'Vernachlässigen';
          break;
        case 0:
          selection[muscleName] = 'Nicht trainieren';
          break;
      }
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingPlanSettingsScreen(
          volumeType: 'Benutzerdefiniert',
          volumePerDay: (widget.selectedDuration / 180).ceil(),
          trainingFrequency: widget.trainingFrequency,
          selectedDuration: widget.selectedDuration,
          trainingExperience: widget.trainingExperience,
          muscleGroups: widget.muscleGroups,
          selection: selection,
        ),
      ),
    );
  }

  void _swapSvgs() {
    setState(() {
      _isSwapped = !_isSwapped;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Muskelgruppen Priorisieren'),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 20,
            right: 20,
            child: GestureDetector(
              onTap: _swapSvgs,
              child: SvgPicture.string(
                _updateSvgColorsEfficiently(
                  _isSwapped ? _svgFrontsideString : _svgBacksideString,
                  _isSwapped ? frontsideGroupedIds! : backsideGroupedIds!,
                ),
                semanticsLabel: 'Wechsel SVG',
                width: 100.0,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _swapSvgs,
                child: Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: SvgPicture.string(
                    _updateSvgColorsEfficiently(
                      _isSwapped ? _svgBacksideString : _svgFrontsideString,
                      _isSwapped ? backsideGroupedIds! : frontsideGroupedIds!,
                    ),
                    semanticsLabel: 'Aktuelle SVG Ansicht',
                    height: 520.0,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: musclePriorities.keys.map((muscleName) {
                    final priorityValue = musclePriorities[muscleName] ?? 2;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            muscleName,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 0.0),
                          Text(
                            _getLabelText(priorityValue),
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5.0),
                          ToggleButtons(
                            borderRadius: BorderRadius.circular(10.0),
                            constraints: const BoxConstraints(
                              minWidth: 55.0,
                              minHeight: 35.0,
                            ),
                            isSelected: List.generate(
                              5,
                              (index) => index == priorityValue,
                            ),
                            onPressed: (int index) {
                              setState(() {
                                musclePriorities[muscleName] = index;
                                if (_isSwapped) {
                                  _svgBacksideString =
                                      _updateSvgColorsEfficiently(
                                          _svgBacksideString,
                                          backsideGroupedIds!);
                                } else {
                                  _svgFrontsideString =
                                      _updateSvgColorsEfficiently(
                                          _svgFrontsideString,
                                          frontsideGroupedIds!);
                                }
                              });
                            },
                            children: const [
                              Text("0", style: TextStyle(fontSize: 16)),
                              Text("1", style: TextStyle(fontSize: 16)),
                              Text("2", style: TextStyle(fontSize: 16)),
                              Text("3", style: TextStyle(fontSize: 16)),
                              Text("4", style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _navigateToTrainingPlanSettings,
          child: const Text('Weiter'),
        ),
      ),
    );
  }

  String _getLabelText(int value) {
    const labels = [
      "Nicht trainieren",
      "Vernachlässigen",
      "Normal",
      "Etwas fokussieren",
      "Fokussieren"
    ];
    return labels[value];
  }
}
