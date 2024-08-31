import 'package:flutter/material.dart';

class TrainingDurationCard extends StatefulWidget {
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
  _TrainingDurationCardState createState() => _TrainingDurationCardState();
}

class _TrainingDurationCardState extends State<TrainingDurationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Setting up the pulsing animation to scale uniformly
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleCoachButtonPressed() {
    if (widget.selectedDuration == widget.moderateDauer.toDouble()) {
      // Trigger the pulsing animation if the slider is at the ideal position
      _pulseController.forward().then((_) => _pulseController.reverse());
    } else {
      // Otherwise, call the existing onSetToIdealDuration function
      widget.onSetToIdealDuration();
    }
  }

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
              'Passe den Trainingsumfang an',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Trainingsdauer: ${widget.formatDauer(widget.selectedDuration.toInt())}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
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
                        (widget.minimaleDauer - widget.minSliderValue) /
                            (widget.maxSliderValue - widget.minSliderValue),
                        (widget.moderateDauer - widget.minSliderValue) /
                            (widget.maxSliderValue - widget.minSliderValue),
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
                      overlayShape: SliderComponentShape.noOverlay,
                      thumbColor: sliderThumbColor,
                      activeTrackColor: Colors.transparent,
                      inactiveTrackColor: Colors.transparent,
                      trackHeight: 6,
                    ),
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Slider(
                            value: widget.selectedDuration,
                            min: widget.minSliderValue.toDouble(),
                            max: widget.maxSliderValue.toDouble(),
                            divisions:
                                widget.maxSliderValue - widget.minSliderValue,
                            label: null,
                            onChanged: (double value) {
                              widget.onDurationChanged(value);
                            },
                          ),
                        );
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
                      widget.formatDauer(widget.minimaleDauer),
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
                      widget.formatDauer(widget.maximaleDauer),
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
              widget.kontextText,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: _handleCoachButtonPressed,
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
