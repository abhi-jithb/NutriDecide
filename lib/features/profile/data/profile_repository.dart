import '../domain/entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile();
  Future<ProfileEntity> updateProfile(ProfileEntity profile);
}
