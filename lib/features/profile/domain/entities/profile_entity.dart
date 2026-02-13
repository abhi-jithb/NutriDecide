class ProfileEntity {
  final String id;
  final String email;
  final String? name;
  final String? profileImage;
  final int? age;
  final double? weight;
  final double? height;

  const ProfileEntity({
    required this.id,
    required this.email,
    this.name,
    this.profileImage,
    this.age,
    this.weight,
    this.height,
  });

  ProfileEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImage,
    int? age,
    double? weight,
    double? height,
  }) {
    return ProfileEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
    );
  }
}
