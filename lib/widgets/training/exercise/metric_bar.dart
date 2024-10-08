import 'package:flutter/material.dart';

class MetricBar extends StatelessWidget {
  final String label;
  final double value; // Erwartet wird ein Wert zwischen 0 und 5
  final String? tooltip;
  final bool reverseScale; // Parameter zur Umkehrung der Farbskala

  const MetricBar({
    Key? key,
    required this.label,
    required this.value,
    this.tooltip,
    this.reverseScale = false, // Standardmäßig ist die Skala nicht umgekehrt
  }) : super(key: key);

  // Methode zur dynamischen Berechnung der Farbe basierend auf dem Wert
  Color _getColorForValue(double value) {
    if (reverseScale) {
      // Umgekehrte Farbskala
      if (value <= 2.0) {
        return Color.lerp(Colors.green, Colors.yellow, value / 2.0) ??
            Colors.green;
      } else {
        return Color.lerp(Colors.yellow, Colors.red, (value - 2.0) / 3.0) ??
            Colors.red;
      }
    } else {
      // Normale Farbskala
      if (value <= 2.0) {
        return Color.lerp(Colors.red, Colors.yellow, value / 2.0) ?? Colors.red;
      } else {
        return Color.lerp(Colors.yellow, Colors.green, (value - 2.0) / 3.0) ??
            Colors.green;
      }
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
          '${value.toInt()} / 5', // Zeigt den genauen Wert als ganze Zahl an
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
