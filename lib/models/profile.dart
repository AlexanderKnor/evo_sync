class Profile {
  int? id;
  String gender;
  String trainingExperience;
  double weight;

  Profile({
    this.id,
    required this.gender,
    required this.trainingExperience,
    required this.weight,
  });

  // Implementierung der copyWith-Methode
  Profile copyWith({
    int? id,
    String? gender,
    String? trainingExperience,
    double? weight,
  }) {
    return Profile(
      id: id ?? this.id,
      gender: gender ?? this.gender,
      trainingExperience: trainingExperience ?? this.trainingExperience,
      weight: weight ?? this.weight,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gender': gender,
      'training_experience': trainingExperience,
      'weight': weight,
    };
  }

  static Profile fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'],
      gender: map['gender'],
      trainingExperience: map['training_experience'],
      weight: map['weight'],
    );
  }

  @override
  String toString() {
    return 'Profile{id: $id, gender: $gender, trainingExperience: $trainingExperience, weight: $weight}';
  }
}
