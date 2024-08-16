import 'package:flutter/material.dart';
import 'package:evosync/models/exercise_converter.dart';
import 'package:evosync/widgets/generic/icon_circle.dart';

class DetailsTab extends StatelessWidget {
  final Exercise exercise;

  const DetailsTab({Key? key, required this.exercise}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCard(
            context: context,
            icon: Icons.fitness_center,
            iconColor: Colors.orange,
            title: 'Equipment',
            content: Text(
              exercise.equipment,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.textTheme.bodyLarge?.color),
            ),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 16),
          _buildCard(
            context: context,
            icon: Icons.info_outline,
            iconColor: Colors.blueAccent,
            title: 'Gerätespezifische Tipps',
            content: Text(
              exercise.machineSpecificTips,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 16),
          _buildCard(
            context: context,
            icon: Icons.health_and_safety,
            iconColor: Colors.red,
            title: 'Sicherheitstipps',
            content: Text(
              exercise.safetyTips,
              style:
                  theme.textTheme.bodyLarge?.copyWith(color: Colors.redAccent),
            ),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 16),
          _buildCard(
            context: context,
            icon: Icons.edit,
            iconColor: Colors.purple,
            title: 'Modifikationen',
            content: Text(
              exercise.modifications.join(', '),
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.textTheme.bodyLarge?.color),
            ),
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget content,
    required bool isDarkMode,
  }) {
    final ThemeData theme = Theme.of(context);

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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconCircle(
              icon: icon,
              iconColor: iconColor,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  content,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
