import 'package:flutter/material.dart';

class MetricBar extends StatelessWidget {
  final String label;
  final double value; // Erwartet wird ein Wert zwischen 0 und 5
  final String? tooltip;

  const MetricBar({
    Key? key,
    required this.label,
    required this.value,
    this.tooltip,
  }) : super(key: key);

  // Methode zur dynamischen Berechnung der Farbe basierend auf dem Wert
  Color _getColorForValue(double value) {
    if (value <= 2.0) {
      // Interpolation zwischen Rot und Gelb
      return Color.lerp(Colors.red, Colors.yellow, value / 2.0) ?? Colors.red;
    } else {
      // Interpolation zwischen Gelb und Grün
      return Color.lerp(Colors.yellow, Colors.green, (value - 2.0) / 3.0) ??
          Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color metricColor = _getColorForValue(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: metricColor,
              ),
            ),
            if (tooltip != null)
              Tooltip(
                message: tooltip!,
                child: Icon(
                  Icons.info_outline,
                  color: metricColor,
                  size: 16,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value / 5, // Skalierung des Wertes von 0-5 auf 0-1
          backgroundColor: theme.brightness == Brightness.dark
              ? Colors.grey[700]
              : Colors.grey[300],
          color: metricColor,
          minHeight: 8, // Höhere Leiste für bessere Sichtbarkeit
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(1)} / 5', // Zeigt den genauen Wert an
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
