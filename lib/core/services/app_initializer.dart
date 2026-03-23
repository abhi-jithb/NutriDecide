import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/food_database_service.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/profile/models/user_profile.dart';

/// Centralized startup service to ensure parallel initialization of all core systems.
class AppInitializer {
  static final AppInitializer _instance = AppInitializer._internal();
  factory AppInitializer() => _instance;
  AppInitializer._internal();

  UserProfile? _currentUserProfile;
  UserProfile? get currentUserProfile => _currentUserProfile;

  /// Parallel initialization of DotEnv, Firebase, Hive, and User Profiles.
  /// Target performance: < 2 seconds startup time.
  Future<void> initialize() async {
    final startTime = DateTime.now();

    try {
      // Step A: Phase 1 Parallel Boot (Infrastructure)
      await Future.wait([
        dotenv.load(fileName: ".env"),
        Firebase.initializeApp(),
        Hive.initFlutter(),
      ]);

      // Step B: Phase 2 Heavy Assets (Food Database Indexing into Hive)
      await FoodDatabaseService().initializeDatabase();

      // Step C: User Awareness Phase (Profile Loading from Firestore)
      // This is fast and non-blocking if already logged in via Firebase Auth persistence.
      _currentUserProfile = await ProfileRepository().fetchProfile();

      final duration = DateTime.now().difference(startTime).inMilliseconds;
      debugPrint('🚀 AppInitializer: Full system boot completed in ${duration}ms');

    } catch (e) {
      debugPrint('❗ AppInitializer Fatal Error: $e');
    }
  }

  /// Refreshes the cached profile (useful after signup/profile update).
  Future<void> refreshProfile() async {
    _currentUserProfile = await ProfileRepository().fetchProfile();
  }
}
