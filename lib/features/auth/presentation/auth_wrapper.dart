import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/models/user_profile.dart';
import 'login_screen.dart';
import 'profile_setup_screen.dart';
import '../../navigation/bottom_nav_screen.dart';
import '../../legal/presentation/medical_disclaimer_screen.dart';
import '../../../core/services/app_initializer.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _disclaimerAccepted = false;
  bool _loadingDisclaimer = true;

  @override
  void initState() {
    super.initState();
    _checkDisclaimer();
  }

  Future<void> _checkDisclaimer() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _disclaimerAccepted = prefs.getBool('disclaimer_accepted') ?? false;
      _loadingDisclaimer = false;
    });
  }

  Future<void> _acceptDisclaimer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('disclaimer_accepted', true);
    setState(() => _disclaimerAccepted = true);
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
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        return FutureBuilder<UserProfile?>(
          future: ProfileRepository().getProfile(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final profile = profileSnapshot.data;
            if (profile == null) {
              return const ProfileSetupScreen();
            }

            // Legal Guard: Ensure medical disclaimer is accepted once per installation
            if (!_disclaimerAccepted) {
              return MedicalDisclaimerScreen(onAccept: _acceptDisclaimer);
            }

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
