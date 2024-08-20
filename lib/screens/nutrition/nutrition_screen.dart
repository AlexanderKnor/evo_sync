import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evosync/theme/dark_mode_notifier.dart';
import 'package:evosync/widgets/nutrition/rmr_calculator.dart';
import 'package:evosync/widgets/generic/theme_toggle_button.dart';
import 'package:evosync/widgets/nutrition/neat_calculator.dart';
import 'package:evosync/widgets/nutrition/krafttraining_calculator.dart';
import 'package:evosync/widgets/nutrition/tef_widget.dart';
import 'package:evosync/widgets/nutrition/total_calories_widget.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  _NutritionScreenState createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  double _weight = 0.0;
  double _rmr = 0.0;
  double _neat = 0.0;
  double _krafttraining = 0.0;

  void _updateRmr(double rmr) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _rmr = rmr;
        });
      }
    });
  }

  void _updateNeat(double neat) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _neat = neat;
        });
      }
    });
  }

  void _updateKrafttraining(double krafttraining) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _krafttraining = krafttraining;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<DarkModeNotifier>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: ThemeToggleButton(),
                ),
              ),
              RmrCalculator(
                onWeightChanged: (weight) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _weight = weight;
                      });
                    }
                  });
                },
                onRmrCalculated: _updateRmr,
              ),
              const SizedBox(height: 20),
              NeatCalculator(
                gewicht: _weight,
                onNeatCalculated: _updateNeat,
              ),
              const SizedBox(height: 20),
              KrafttrainingCalculator(
                gewicht: _weight,
                onKrafttrainingCalculated: _updateKrafttraining,
              ),
              const SizedBox(height: 20),
              TefWidget(
                rmr: _rmr,
                neat: _neat,
                krafttraining: _krafttraining,
              ),
              const SizedBox(height: 20),
              TotalCaloriesWidget(
                rmr: _rmr,
                neat: _neat,
                krafttraining: _krafttraining,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
