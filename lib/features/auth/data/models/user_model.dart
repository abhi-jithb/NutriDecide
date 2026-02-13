import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      profileImage: json['profile_image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profile_image': profileImage,
    };
  }
}
