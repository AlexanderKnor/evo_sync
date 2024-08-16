import 'dart:convert';
import 'package:flutter/services.dart';

class Exercise {
  final String title;
  final String equipment;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final Map<String, dynamic> rangeOfMotion;
  final Map<String, dynamic> stability;
  final Map<String, dynamic> difficultyLevel;
  final Map<String, dynamic> jointStress;
  final Map<String, dynamic> systemicStress;
  final String machineSpecificTips;
  final String safetyTips;
  final List<String> modifications;

  Exercise({
    required this.title,
    required this.equipment,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.rangeOfMotion,
    required this.stability,
    required this.difficultyLevel,
    required this.jointStress,
    required this.systemicStress,
    required this.machineSpecificTips,
    required this.safetyTips,
    required this.modifications,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      title: json['machine_name'] ?? 'Unbekannte Übung',
      equipment: json['equipment'] ?? 'Unbekanntes Gerät',
      primaryMuscles:
          List<String>.from(json['muscle_groups']?['primary'] ?? []),
      secondaryMuscles:
          List<String>.from(json['muscle_groups']?['secondary'] ?? []),
      rangeOfMotion: json['range_of_motion'] ?? {},
      stability: json['stability'] ?? {},
      difficultyLevel: json['difficulty_level'] ?? {},
      jointStress: json['joint_stress'] ?? {},
      systemicStress: json['systemic_stress'] ?? {},
      machineSpecificTips:
          json['machine_specific_tips'] ?? 'Keine Tipps verfügbar',
      safetyTips: json['safety_tips'] ?? 'Keine Sicherheitshinweise verfügbar',
      modifications: List<String>.from(json['modifications'] ?? []),
    );
  }

  static Future<Exercise> loadFromAsset(String path) async {
    final jsonString = await rootBundle.loadString(path);
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    return Exercise.fromJson(jsonMap);
  }
}
