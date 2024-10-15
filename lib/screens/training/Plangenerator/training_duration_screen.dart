import 'package:flutter/material.dart';
import 'package:evosync/screens/training/Plangenerator/muscle_group_selection_screen.dart';
import 'package:evosync/widgets/training/training_duration/training_duration_card.dart';

class TrainingDurationScreen extends StatefulWidget {
  final String trainingExperience;
  final List<dynamic> muscleGroups;
  final int trainingFrequency;
  final String gender;

  TrainingDurationScreen({
    required this.trainingExperience,
    required this.muscleGroups,
    required this.trainingFrequency,
    required this.gender,
  });

  @override
  _TrainingDurationScreenState createState() => _TrainingDurationScreenState();
}

class _TrainingDurationScreenState extends State<TrainingDurationScreen>
    with SingleTickerProviderStateMixin {
  late double _selectedDuration;
  late int minVolumeProTag;
  late int moderateVolumeProTag;
  late int maxVolumeProTag;
  late int minimaleDauer;
  late int moderateDauer;
  late int maximaleDauer;

  late int _minSliderValue;
  late int _maxSliderValue;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _minSliderValue = 30 * 60; // 30 Minuten in Sekunden
    _maxSliderValue =
        150 * 60; // 150 Minuten (2 Stunden 30 Minuten) in Sekunden
    _berechneVolumes();
    _selectedDuration = moderateDauer
        .toDouble()
        .clamp(_minSliderValue.toDouble(), _maxSliderValue.toDouble());

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: _selectedDuration,
      end: _selectedDuration,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _animation.addListener(() {
      setState(() {
        _selectedDuration = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _berechneVolumes() {
    int totalVolumeMin = _berechneGesamtvolumen(istMin: true);
    int totalVolumeMax = _berechneGesamtvolumen(istMin: false);

    minVolumeProTag = (totalVolumeMin / widget.trainingFrequency).ceil();
    maxVolumeProTag = (totalVolumeMax / widget.trainingFrequency).ceil();
    moderateVolumeProTag = ((minVolumeProTag + maxVolumeProTag) / 2).ceil();

    int dauerProSatz =
        3 * 60; // Durchschnittliche Dauer 3 Min pro Satz in Sekunden
    minimaleDauer = (minVolumeProTag * dauerProSatz)
        .clamp(_minSliderValue, _maxSliderValue);
    moderateDauer = (moderateVolumeProTag * dauerProSatz)
        .clamp(_minSliderValue, _maxSliderValue);
    maximaleDauer = (maxVolumeProTag * dauerProSatz)
        .clamp(_minSliderValue, _maxSliderValue);
  }

  int _berechneGesamtvolumen({required bool istMin}) {
    int gesamtvolumen = 0;

    for (var muskelgruppe in widget.muscleGroups) {
      int? volumen;
      switch (widget.trainingExperience) {
        case 'Novice':
          volumen =
              istMin ? muskelgruppe['mev']['min'] : muskelgruppe['mev']['max'];
          break;
        case 'Beginner':
          volumen =
              istMin ? muskelgruppe['mev']['min'] : muskelgruppe['mav']['min'];
          break;
        case 'Intermediate':
          volumen =
              istMin ? muskelgruppe['mev']['min'] : muskelgruppe['mav']['max'];
          break;
        case 'Advanced':
          volumen =
              istMin ? muskelgruppe['mev']['max'] : muskelgruppe['mav']['max'];
          break;
        case 'Very Advanced':
          volumen =
              istMin ? muskelgruppe['mav']['min'] : muskelgruppe['mav']['max'];
          break;
        default:
          volumen =
              istMin ? muskelgruppe['mav']['min'] : muskelgruppe['mav']['max'];
      }

      if (volumen != null) {
        gesamtvolumen += volumen;
      }
    }

    return gesamtvolumen;
  }

  void _setToIdealDuration() {
    double idealDuration = moderateDauer
        .toDouble()
        .clamp(_minSliderValue.toDouble(), _maxSliderValue.toDouble());

    _animation = Tween<double>(
      begin: _selectedDuration,
      end: idealDuration,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward(from: 0);
  }

  String formatDauer(int totalSeconds) {
    final int stunden = totalSeconds ~/ 3600;
    final int minuten = (totalSeconds % 3600) ~/ 60;
    if (stunden > 0) {
      return '${stunden}h ${minuten}min';
    } else {
      return '${minuten}min';
    }
  }

  String getKontextText() {
    if (_selectedDuration < minimaleDauer) {
      return 'Kürzeres Training mit reduziertem Volumen, ideal für zeiteffizientes Training.';
    } else if (_selectedDuration > maximaleDauer) {
      return 'Intensives Training mit maximalem Volumen, geeignet für Athleten mit genügend Zeit und Erholung.';
    } else {
      return 'Ausgewogenes Training mit moderatem Volumen, ideal für Fortschritte bei einer ausgewogenen Belastung.';
    }
  }

  void _navigateToMuscleGroupSelection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MuscleGroupSelectionScreen(
          trainingExperience: widget.trainingExperience,
          muscleGroups: widget.muscleGroups,
          trainingFrequency: widget.trainingFrequency,
          selectedDuration: _selectedDuration,
          gender: widget.gender, // Übergeben des Geschlechts
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Define the dark purple color for dark mode
    final Color darkModePurple = Colors.deepPurpleAccent.withOpacity(0.5);

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Trainingsumfang wählen'), // Match the exact title style
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 0), // Add space above the card
            TrainingDurationCard(
              selectedDuration: _selectedDuration,
              minSliderValue: _minSliderValue,
              maxSliderValue: _maxSliderValue,
              minimaleDauer: minimaleDauer,
              moderateDauer: moderateDauer,
              maximaleDauer: maximaleDauer,
              onDurationChanged: (value) {
                setState(() {
                  _selectedDuration = value;
                });
              },
              onSetToIdealDuration: _setToIdealDuration,
              formatDauer: formatDauer,
              kontextText: getKontextText(),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      // Floating Action Button with padding and specific dark mode color
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
            bottom: 30.0, right: 16.0), // Padding to match other screens
        child: FloatingActionButton(
          onPressed: () {
            _navigateToMuscleGroupSelection(context);
          },
          backgroundColor: isDarkMode
              ? darkModePurple
              : theme.colorScheme
                  .primary, // Dark purple in dark mode, primary in light mode
          child: const Icon(Icons.check,
              color: Colors.white), // White icon color for visibility
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
