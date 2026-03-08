import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class ProfileRepository {
  static const String _profileKey = 'user_profile';

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, profile.toJson());
  }

  Future<UserProfile?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_profileKey);
    if (profileJson == null) return null;
    try {
      return UserProfile.fromJson(profileJson);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
  }
}
