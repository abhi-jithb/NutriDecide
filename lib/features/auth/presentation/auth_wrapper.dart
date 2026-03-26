import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutri_decide/features/auth/services/auth_service.dart';
import 'package:nutri_decide/features/profile/data/profile_repository.dart';
import 'package:nutri_decide/features/profile/models/user_profile.dart';
import 'package:nutri_decide/features/auth/presentation/login_screen.dart';
import 'package:nutri_decide/features/auth/presentation/profile_setup_screen.dart';
import 'package:nutri_decide/features/navigation/bottom_nav_screen.dart';
import 'package:nutri_decide/features/legal/presentation/medical_disclaimer_screen.dart';
import 'package:nutri_decide/core/services/app_initializer.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _disclaimerAccepted = false;
  bool _loadingDisclaimer = true;
  late Stream<User?> _authStream;

  @override
  void initState() {
    super.initState();
    _authStream = AuthService().authStateChanges;
    _checkDisclaimer();
  }

  Future<void> _checkDisclaimer() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _disclaimerAccepted = prefs.getBool('disclaimer_accepted') ?? false;
        _loadingDisclaimer = false;
      });
    }
  }

  Future<void> _acceptDisclaimer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('disclaimer_accepted', true);
    if (mounted) setState(() => _disclaimerAccepted = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!AppInitializer().isFirebaseReady) {
      return _buildFirebaseError(context);
    }

    if (_loadingDisclaimer) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return StreamBuilder<User?>(
      stream: _authStream,
      builder: (context, snapshot) {
        // High-level Auth Guard
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        // Logic split: Once user is authenticated, we MUST have a profile to proceed
        return StreamBuilder<UserProfile?>(
          stream: ProfileRepository().profileStream(user.uid),
          builder: (context, profileSnapshot) {
            // Wait for profile data ONLY if it's the first time we're loading for this user
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final profile = profileSnapshot.data;
            if (profile == null) {
              // Redirect to onboarding if profile is missing
              return ProfileSetupScreen(uid: user.uid);
            }

            // Legal Guard: Ensure medical disclaimer is accepted once per installation
            if (!_disclaimerAccepted) {
              return MedicalDisclaimerScreen(onAccept: _acceptDisclaimer);
            }

            // All guards passed: Enter main App
            return const BottomNavScreen();
          },
        );
      },
    );
  }

  Widget _buildFirebaseError(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 80, color: Colors.orange),
              const SizedBox(height: 24),
              const Text(
                "Service Unavailable",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                "The app could not connect to our biological data services. This is usually due to a missing configuration file (google-services.json).",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => AppInitializer().initialize(),
                child: const Text("RETRY CONNECTION"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
