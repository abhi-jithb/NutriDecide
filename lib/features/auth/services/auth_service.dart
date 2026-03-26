import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/app_initializer.dart';

/// A production-ready authentication service for NutriDecide.
/// Handles login, logout, and auth state management.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;


  Future<UserCredential?> loginWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      debugPrint('❌ AuthService Login Error: $e');
      rethrow;
    }
  }

  Future<UserCredential?> registerWithEmail(String email, String password, String name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await credential.user?.updateDisplayName(name);
      return credential;
    } catch (e) {
      debugPrint('❌ AuthService Signup Error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      // 1. Clear session state first
      AppInitializer().clearUserData();
      
      // 2. Sign out from Firebase
      await _auth.signOut();
      debugPrint('🚪 User logged out successfully. State reset.');
    } catch (e) {
      debugPrint('❌ AuthService Logout Error: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('❌ AuthService Reset Error: $e');
      rethrow;
    }
  }
}
