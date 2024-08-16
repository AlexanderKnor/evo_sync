import 'package:flutter/material.dart';

class CaloriesBreakdownScreen extends StatelessWidget {
  final double rmr;
  final double neat;
  final double krafttraining;
  final double tef;

  const CaloriesBreakdownScreen({
    Key? key,
    required this.rmr,
    required this.neat,
    required this.krafttraining,
    required this.tef,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double totalCalories = rmr + neat + krafttraining + tef;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Hero(
                tag: 'caloriesHero',
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(bottom: 20.0),
                  child: const Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                    size: 100,
                  ),
                ),
              ),
              _buildCaloriesBar(
                context,
                'RMR (Ruheumsatz)',
                rmr,
                Colors.blue,
                totalCalories == 0 ? 0 : rmr / totalCalories,
              ),
              _buildCaloriesBar(
                context,
                'NEAT (Aktivität)',
                neat,
                Colors.orange,
                totalCalories == 0 ? 0 : neat / totalCalories,
              ),
              _buildCaloriesBar(
                context,
                'TEA (Training)',
                krafttraining,
                Colors.red,
                totalCalories == 0 ? 0 : krafttraining / totalCalories,
              ),
              _buildCaloriesBar(
                context,
                'TEF (Thermischer Effekt)',
                tef,
                Colors.green,
                totalCalories == 0 ? 0 : tef / totalCalories,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaloriesBar(BuildContext context, String label, double value,
      Color color, double percentage) {
    double validPercentage = percentage.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${value.toStringAsFixed(0)} kcal',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Stack(
          children: [
            Container(
              height: 30,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            FractionallySizedBox(
              widthFactor: validPercentage,
              child: Container(
                height: 30,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 4,
              bottom: 4,
              child: Text(
                '${(validPercentage * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
