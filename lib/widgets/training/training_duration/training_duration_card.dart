import 'package:flutter/material.dart';

class TrainingDurationCard extends StatelessWidget {
  final double selectedDuration;
  final int minSliderValue;
  final int maxSliderValue;
  final int minimaleDauer;
  final int moderateDauer;
  final int maximaleDauer;
  final Function(double) onDurationChanged;
  final VoidCallback onSetToIdealDuration;
  final String Function(int) formatDauer;
  final String kontextText;

  const TrainingDurationCard({
    Key? key,
    required this.selectedDuration,
    required this.minSliderValue,
    required this.maxSliderValue,
    required this.minimaleDauer,
    required this.moderateDauer,
    required this.maximaleDauer,
    required this.onDurationChanged,
    required this.onSetToIdealDuration,
    required this.formatDauer,
    required this.kontextText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final sliderThumbColor = isDarkMode ? Colors.amber[300] : Colors.amber;

    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Passe den Trainingsumfang an:',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Trainingsdauer: ${formatDauer(selectedDuration.toInt())}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      colors: [
                        Colors.greenAccent,
                        Colors.orangeAccent,
                        Colors.redAccent,
                      ],
                      stops: [
                        (minimaleDauer - minSliderValue) /
                            (maxSliderValue - minSliderValue),
                        (moderateDauer - minSliderValue) /
                            (maxSliderValue - minSliderValue),
                        1.0,
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
                      overlayShape:
                          SliderComponentShape.noOverlay, // Kein Overlay
                      thumbColor: sliderThumbColor,
                      activeTrackColor: Colors.transparent,
                      inactiveTrackColor: Colors.transparent,
                      trackHeight: 6,
                    ),
                    child: Slider(
                      value: selectedDuration,
                      min: minSliderValue.toDouble(),
                      max: maxSliderValue.toDouble(),
                      divisions: maxSliderValue - minSliderValue,
                      label: null,
                      onChanged: (double value) {
                        onDurationChanged(value);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Icon(Icons.access_time, color: Colors.greenAccent),
                    Text(
                      formatDauer(minimaleDauer),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.whatshot, color: Colors.redAccent),
                    Text(
                      formatDauer(maximaleDauer),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              kontextText,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: onSetToIdealDuration,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  backgroundColor: Colors.deepPurpleAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 12,
                  shadowColor: Colors.deepPurpleAccent.withOpacity(0.5),
                ),
                icon: const Icon(Icons.auto_fix_high, color: Colors.white),
                label: const Text(
                  'Coach wählen lassen',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
