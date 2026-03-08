import 'dart:convert';

class UserProfile {
  final double height;
  final double weight;
  final String gender;
  final String goal;
  final double targetWeight;
  final String activityLevel;
  final String dietType;
  final bool hasDiabetes;
  final bool hasHypertension;
  final bool hasPcos;
  final List<String> allergies;

  UserProfile({
    required this.height,
    required this.weight,
    required this.gender,
    required this.goal,
    required this.targetWeight,
    required this.activityLevel,
    required this.dietType,
    required this.hasDiabetes,
    required this.hasHypertension,
    required this.hasPcos,
    this.allergies = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'height': height,
      'weight': weight,
      'gender': gender,
      'goal': goal,
      'targetWeight': targetWeight,
      'activityLevel': activityLevel,
      'dietType': dietType,
      'hasDiabetes': hasDiabetes,
      'hasHypertension': hasHypertension,
      'hasPcos': hasPcos,
      'allergies': allergies,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      height: (map['height'] ?? 0).toDouble(),
      weight: (map['weight'] ?? 0).toDouble(),
      gender: map['gender'] ?? '',
      goal: map['goal'] ?? '',
      targetWeight: (map['targetWeight'] ?? 0).toDouble(),
      activityLevel: map['activityLevel'] ?? '',
      dietType: map['dietType'] ?? '',
      hasDiabetes: map['hasDiabetes'] ?? false,
      hasHypertension: map['hasHypertension'] ?? false,
      hasPcos: map['hasPcos'] ?? false,
      allergies: List<String>.from(map['allergies'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(json.decode(source));
}
