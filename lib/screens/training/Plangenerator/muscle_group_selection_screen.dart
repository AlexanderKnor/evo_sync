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

class _MuscleGroupSelectionScreenState extends State<MuscleGroupSelectionScreen>
    with TickerProviderStateMixin {
  Map<String, List<String>>? frontsideGroupedIds;
  Map<String, List<String>>? backsideGroupedIds;
  Map<String, int> musclePriorities = {};
  Map<String, AnimationController> _animationControllers = {};
  Map<String, Animation<Color?>> _colorAnimations = {};
  String _svgFrontsideString = '';
  String _svgBacksideString = '';
  bool _isSwapped = false;
  bool _isLoading = true;
  double _svgHeight = 500.0; // Initiale Höhe der SVG
  double _svgOffset = 0.0; // Initiale Verschiebung der SVG
  final DraggableScrollableController _sheetController =
      DraggableScrollableController(); // Controller für das Scroll-Sheet
  List<Map<String, dynamic>> focusPresets = []; // Für geladene Presets

  @override
  void initState() {
    super.initState();
    _loadGroupedIds();
    _loadFocusPresets(); // Lade die Presets beim Start
    for (var muscleGroup in widget.muscleGroups) {
      musclePriorities[muscleGroup['name']] = 2;

      // Initialize AnimationController and Animation for each muscle group
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );
      _animationControllers[muscleGroup['name']] = controller;

      final animation = ColorTween(
        begin: _colorFromValue(2),
        end: _colorFromValue(2),
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ))
        ..addListener(() {
          setState(() {}); // Refresh UI when color changes
        });
      _colorAnimations[muscleGroup['name']] = animation;
    }

    // Set initial offset based on initial progress
    _updateSvgPositionAndSize(initial: true);
    _sheetController.addListener(() => _updateSvgPositionAndSize());
  }

  // Lade die Fokus-Presets aus der JSON-Datei
  Future<void> _loadFocusPresets() async {
    try {
      final String response =
          await rootBundle.loadString('assets/database/focus_presets.json');
      final data = await json.decode(response);
      setState(() {
        focusPresets = List<Map<String, dynamic>>.from(data['presets']);
      });
    } catch (e) {
      print('Fehler beim Laden der Fokus-Presets: $e');
    }
  }

  @override
  void dispose() {
    _sheetController.removeListener(() => _updateSvgPositionAndSize());
    _sheetController.dispose();
    _animationControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void _updateSvgPositionAndSize({bool initial = false}) {
    setState(() {
      // Calculate progress: initial = 0.27 for start value
      double progress = initial
          ? 0.0 // Set progress to 0.0 for initial state
          : (_sheetController.size - 0.27) / (0.6 - 0.27); // Normalize
      _svgHeight = 500.0 - (progress * (500.0 - 260.0)); // Interpolate height
      _svgOffset = (-125 * progress) - 10; // Dynamic upward shift
    });
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
      final color = _colorAnimations[muscleGroup]?.value ??
          _colorFromValue(priorityValue);
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
        return const Color.fromARGB(255, 255, 138, 138); // Fokussieren
      case 3:
        return const Color.fromARGB(255, 255, 193, 193); // Etwas Fokussieren
      case 2:
        return Colors.white; // Normal
      case 1:
        return const Color.fromARGB(255, 176, 176, 176); // Vernachlässigen
      case 0:
      default:
        return const Color.fromARGB(91, 80, 80, 80); // Nicht Trainieren
    }
  }

  void _animateColorChange(String muscleGroup, int priorityValue) {
    final controller = _animationControllers[muscleGroup];
    if (controller != null) {
      // Create a new animation with updated color values
      _colorAnimations[muscleGroup] = ColorTween(
        begin: _colorAnimations[muscleGroup]?.value,
        end: _colorFromValue(priorityValue),
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ))
        ..addListener(() {
          setState(() {}); // Update UI when color changes
        });

      // Start the animation
      controller.forward(from: 0);
    }
  }

  void _applyPreset(Map<String, int> priorities) {
    // Reset all priorities to "Normal" first
    _resetAllPrioritiesToNormal();

    // Apply the selected preset
    _setPriorities(priorities);
  }

  void _resetAllPrioritiesToNormal() {
    setState(() {
      widget.muscleGroups.forEach((muscleGroup) {
        String muscleName = muscleGroup['name'];
        musclePriorities[muscleName] = 2; // Set all to "Normal"
        _animateColorChange(muscleName, 2);
      });
    });
  }

  void _setPriorities(Map<String, int> priorities) {
    setState(() {
      priorities.forEach((muscle, priority) {
        musclePriorities[muscle] = priority;
        _animateColorChange(muscle, priority);
      });
    });
  }

  void _showPresetsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Fokus-Einstellungen'),
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: _showRecommendations, // Funktion für Empfehlungen
              )
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: focusPresets.map((preset) {
              return ListTile(
                title: Text(preset['name']),
                onTap: () {
                  _applyPreset(Map<String, int>.from(preset['priorities']));
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // Zeige Empfehlungen basierend auf der Trainingserfahrung und füge die Erfahrung zur Anzeige hinzu
  void _showRecommendations() {
    String recommendation;
    switch (widget.trainingExperience) {
      case 'Novice':
      case 'Beginner':
        recommendation =
            'Als Anfänger solltest du ein ausgewogenes Training ohne spezielle '
            'Fokussierung oder Vernachlässigung von Muskelgruppen durchführen.';
        break;
      case 'Intermediate':
        recommendation =
            'Als Fortgeschrittener kannst du eine gewünschte Fokussierung wählen, '
            'aber eine individuelle Einstellung ist ebenfalls sinnvoll.';
        break;
      case 'Advanced':
        recommendation =
            'Für Fortgeschrittene wird empfohlen, individuell nachzuarbeiten und '
            'Fokussierungen entsprechend anzupassen.';
        break;
      case 'Very Advanced':
        recommendation =
            'Sehr Fortgeschrittene sollten die Fokussierung vollständig individuell '
            'einstellen, um gezielt nach persönlichen Bedürfnissen zu trainieren.';
        break;
      default:
        recommendation =
            'Wählen Sie eine Fokus-Einstellung basierend auf Ihren Trainingszielen.';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Empfehlungen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Trainingserfahrung: ${widget.trainingExperience}'),
              const SizedBox(height: 10),
              Text(recommendation),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Verstanden'),
            ),
          ],
        );
      },
    );
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
          selection[muscleName] = 'Etwas Fokussieren';
          break;
        case 2:
          selection[muscleName] = 'Normal';
          break;
        case 1:
          selection[muscleName] = 'Vernachlässigen';
          break;
        case 0:
          selection[muscleName] = 'Nicht Trainieren';
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Muskelgruppen Priorisieren'),
      ),
      body: Stack(
        alignment: Alignment.center,
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
          Positioned(
            left: 20,
            top: 20,
            child: IconButton(
              icon: const Icon(Icons.tune),
              onPressed: _showPresetsDialog,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _swapSvgs,
                child: Padding(
                  padding: const EdgeInsets.only(
                      bottom: 140.0), // Konsistentes Padding
                  child: Transform.translate(
                    offset: Offset(0, _svgOffset), // Angepasster Offset
                    child: SvgPicture.string(
                      _updateSvgColorsEfficiently(
                        _isSwapped ? _svgBacksideString : _svgFrontsideString,
                        _isSwapped ? backsideGroupedIds! : frontsideGroupedIds!,
                      ),
                      semanticsLabel: 'Aktuelle SVG Ansicht',
                      height: _svgHeight, // Dynamische SVG-Höhe
                    ),
                  ),
                ),
              ),
            ],
          ),
          DraggableScrollableSheet(
            controller: _sheetController, // Verwendung des Controllers
            initialChildSize: 0.27,
            minChildSize: 0.27,
            maxChildSize: 0.45,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode ? Colors.black54 : Colors.black26,
                      blurRadius: 10.0,
                      spreadRadius: 5.0,
                      offset: const Offset(0.0, 2.0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Topbar hinzufügen
                    Container(
                      width: 40,
                      height: 6,
                      margin: const EdgeInsets.only(top: 8, bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: musclePriorities.keys.map((muscleName) {
                              final priorityValue =
                                  musclePriorities[muscleName] ?? 2;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      muscleName,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: theme
                                            .textTheme.headlineSmall?.color,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      _getLabelText(priorityValue),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: theme.textTheme.bodyLarge?.color,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 5.0),
                                    ToggleButtons(
                                      borderRadius: BorderRadius.circular(10.0),
                                      constraints: const BoxConstraints(
                                        minWidth: 60.0,
                                        minHeight: 35.0,
                                      ),
                                      isSelected: List.generate(
                                        5,
                                        (index) => index == priorityValue,
                                      ),
                                      onPressed: (int index) {
                                        setState(() {
                                          musclePriorities[muscleName] = index;
                                          _animateColorChange(
                                              muscleName, index);
                                        });
                                      },
                                      fillColor: theme.colorScheme.primary
                                          .withOpacity(0.2),
                                      children: const [
                                        Icon(Icons.block,
                                            size: 20), // Nicht Trainieren
                                        Icon(Icons.arrow_downward,
                                            size: 20), // Vernachlässigen
                                        Icon(Icons.horizontal_rule,
                                            size: 15), // Normal
                                        Icon(Icons.arrow_upward,
                                            size: 20), // Etwas Fokussieren
                                        Icon(Icons.star,
                                            size: 20), // Fokussieren
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _navigateToTrainingPlanSettings,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          child: const Text('Weiter'),
        ),
      ),
    );
  }

  String _getLabelText(int value) {
    const labels = [
      "Nicht Trainieren",
      "Vernachlässigen",
      "Normal",
      "Etwas Fokussieren",
      "Fokussieren"
    ];
    return labels[value];
  }
}