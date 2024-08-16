class Exercise {
  final String title;
  final int rangeOfMotion;
  final int stability;
  final String equipment;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final String type;
  final Map<String, dynamic> difficultyLevel;
  final Map<String, dynamic> jointStress;
  final String machineSpecificTips;
  final String safetyTips;
  final List<String> modifications;

  Exercise({
    required this.title,
    required this.rangeOfMotion,
    required this.stability,
    required this.equipment,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.type,
    required this.difficultyLevel,
    required this.jointStress,
    required this.machineSpecificTips,
    required this.safetyTips,
    required this.modifications,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      title: json['machine_name'] ?? 'Unbekannte Übung',
      rangeOfMotion: json['range_of_motion']?['scale'] ?? 0,
      stability: json['stability']?['scale'] ?? 0,
      equipment: json['equipment'] ?? 'Unbekanntes Gerät',
      primaryMuscles:
          List<String>.from(json['muscle_groups']?['primary'] ?? []),
      secondaryMuscles:
          List<String>.from(json['muscle_groups']?['secondary'] ?? []),
      type: json['resistance_type'] ?? 'Unbekannter Typ',
      difficultyLevel: json['difficulty_level'] ??
          {'scale': 0, 'description': 'Keine Beschreibung'},
      jointStress: json['joint_stress'] ??
          {
            'scale': 0,
            'description': 'Keine Beschreibung',
            'affected_joints': []
          },
      machineSpecificTips:
          json['machine_specific_tips'] ?? 'Keine Tipps verfügbar',
      safetyTips: json['safety_tips'] ?? 'Keine Sicherheitshinweise verfügbar',
      modifications: List<String>.from(json['modifications'] ?? []),
    );
  }
}
