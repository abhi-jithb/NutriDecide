import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/models/user_profile.dart';
import 'login_screen.dart';
import 'profile_setup_screen.dart';
import '../../navigation/bottom_nav_screen.dart';

/// The production navigation guard for NutriDecide.
/// Ensures the user is authenticated and their Health DNA profile is loaded before access.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        // Feature Auth Guard: Check for an existing User Profile in Firestore
        return FutureBuilder<UserProfile?>(
          future: ProfileRepository().fetchProfile(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final profile = profileSnapshot.data;
            if (profile == null) {
              // No health DNA found: Force user to set up profile
              return const ProfileSetupScreen();
            }

            // Everything ready: Grant access to the app dashboard
            return const BottomNavScreen();
          },
        );
      },
    );
  }
}
