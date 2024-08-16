import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:evosync/models/exercise_converter.dart';
import 'package:evosync/screens/training/exercise_details/exercise_tab_navigation.dart';
import 'package:evosync/widgets/generic/custom_slide_transition.dart';
import 'package:evosync/widgets/generic/icon_circle.dart';

class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({Key? key}) : super(key: key);

  @override
  _ExerciseListScreenState createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  late Future<List<Exercise>> exercises;

  @override
  void initState() {
    super.initState();
    exercises = _loadExercises();
  }

  Future<List<Exercise>> _loadExercises() async {
    final String indexResponse =
        await rootBundle.loadString('assets/database/Index_exercises.json');
    final Map<String, dynamic> indexData = json.decode(indexResponse);
    final List<String> exerciseFiles = List<String>.from(indexData['files']);

    List<Exercise> exercises = [];
    for (String file in exerciseFiles) {
      final String jsonString =
          await rootBundle.loadString('assets/database/exercises/$file');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      exercises.add(Exercise.fromJson(jsonMap));
    }

    return exercises;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Übungen'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Exercise>>(
        future: exercises,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Keine Übungen verfügbar.'));
          } else {
            final exercises = snapshot.data!;
            return ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 12,
                  shadowColor: Colors.black38,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  ExerciseDetailScreen(exercise: exercise),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return CustomSlideTransition(
                              animation: animation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
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
                            color: isDarkMode
                                ? Colors.black45
                                : Colors.grey.shade300,
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const IconCircle(
                            icon: Icons.fitness_center,
                            iconColor: Colors.blueAccent,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exercise.title,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Zielmuskel: ${exercise.primaryMuscles.join(', ')}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
