import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

/// Production-ready User Profile Repository using Cloud Firestore.
/// Manages user health DNA profile synchronization across devices.
class ProfileRepository {
  static final ProfileRepository _instance = ProfileRepository._internal();
  factory ProfileRepository() => _instance;
  ProfileRepository._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUid => _auth.currentUser?.uid;

  CollectionReference get _profiles => _firestore.collection('users');

  /// Fetches the user profile from Cloud Firestore for the currently logged-in user.
  /// If it doesn't exist, returns null.
  Future<UserProfile?> getProfile() async {
    final uid = currentUid;
    if (uid == null) return null;

    try {
      final doc = await _profiles.doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('❌ ProfileRepository fetch Error: $e');
    }
    return null;
  }

  /// Saves or updates the user health DNA profile to Cloud Firestore.
  Future<void> saveProfile(UserProfile profile) async {
    final uid = currentUid;
    if (uid == null) throw Exception('No user logged in to save profile');

    try {
      await _profiles.doc(uid).set(profile.toMap(), SetOptions(merge: true));
      debugPrint('✅ Profile synchronized for user: $uid');
    } catch (e) {
      debugPrint('❌ ProfileRepository save Error: $e');
      rethrow;
    }
  }

  /// Subscribes to profile changes for real-time suitability updates.
  Stream<UserProfile?> profileStream() {
    final uid = currentUid;
    if (uid == null) return Stream.value(null);

    return _profiles.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserProfile.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }
}
