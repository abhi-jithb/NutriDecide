import 'dart:convert';

class UserProfile {
  final String? uid;
  final String? name;
  final int age;
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
  final List<String> conditions;

  UserProfile({
    this.uid,
    this.name,
    required this.age,
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
    this.conditions = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'age': age,
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
      'conditions': conditions,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'],
      name: map['name'],
      age: map['age'] ?? 25,
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
      conditions: List<String>.from(map['conditions'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(json.decode(source));
}
