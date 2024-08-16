import 'package:flutter/material.dart';
import 'package:evosync/models/exercise_converter.dart';
import 'package:evosync/widgets/training_screen_widgets/exercise/metric_bar.dart'; // Korrekte Import-Anweisung

class MetricsMusclesTab extends StatelessWidget {
  final Exercise exercise;

  const MetricsMusclesTab({Key? key, required this.exercise}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetricsCard(context, exercise),
          const SizedBox(height: 16),
          _buildMuscleGroupsCard(context, exercise, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildMetricsCard(BuildContext context, Exercise exercise) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 12,
      shadowColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black38
          : Colors.grey.shade300,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Theme.of(context).brightness == Brightness.dark
                ? [
                    Theme.of(context).cardColor,
                    Theme.of(context).scaffoldBackgroundColor
                  ]
                : [Colors.white, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black45
                  : Colors.grey.shade300,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Metriken',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.headlineSmall?.color,
                  ),
            ),
            const SizedBox(height: 16),
            MetricBar(
              label: 'Range of Motion',
              value: exercise.rangeOfMotion.toDouble(),
            ),
            const SizedBox(height: 16),
            MetricBar(
              label: 'Stabilität',
              value: exercise.stability.toDouble(),
            ),
            const SizedBox(height: 16),
            MetricBar(
              label: 'Schwierigkeit',
              value: exercise.difficultyLevel['scale'].toDouble(),
            ),
            const SizedBox(height: 16),
            MetricBar(
              label: 'Gelenkbelastung',
              value: exercise.jointStress['scale'].toDouble(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuscleGroupsCard(
      BuildContext context, Exercise exercise, bool isDarkMode) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 12,
      shadowColor: isDarkMode ? Colors.black38 : Colors.grey.shade300,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [theme.cardColor, theme.scaffoldBackgroundColor]
                : [Colors.white, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black45 : Colors.grey.shade300,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trainierte Muskelgruppen',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.headlineSmall?.color,
              ),
            ),
            const SizedBox(height: 16),
            _buildMuscleGroup(
              label: 'Primäre Muskeln',
              muscles: exercise.primaryMuscles,
              color: isDarkMode ? Colors.greenAccent : Colors.green,
              icon: Icons.fitness_center,
            ),
            const SizedBox(height: 16),
            _buildMuscleGroup(
              label: 'Sekundäre Muskeln',
              muscles: exercise.secondaryMuscles,
              color: isDarkMode ? Colors.lightBlueAccent : Colors.blueAccent,
              icon: Icons.accessibility_new,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuscleGroup({
    required String label,
    required List<String> muscles,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: muscles.map((muscle) {
            return Chip(
              avatar: Icon(icon, color: Colors.white, size: 20),
              label: Text(
                muscle,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: color.withOpacity(0.8),
            );
          }).toList(),
        ),
      ],
    );
  }
}
