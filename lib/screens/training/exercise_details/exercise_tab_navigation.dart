import 'package:flutter/material.dart';
import 'package:evosync/models/exercise_converter.dart';
import 'package:evosync/screens/training/exercise_details/metrics_muscles_tab.dart';
import 'package:evosync/screens/training/exercise_details/exercise_info_details_tab.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({Key? key, required this.exercise})
      : super(key: key);

  @override
  _ExerciseDetailScreenState createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.title),
        backgroundColor: Colors.blueAccent,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          MetricsMusclesTab(exercise: widget.exercise),
          DetailsTab(exercise: widget.exercise),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Metriken',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'Details',
          ),
        ],
      ),
    );
  }
}
