import 'package:flutter/material.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/navigation/presentation/bottom_nav_screen.dart';

class AppRouter {
  AppRouter._();

  static const String initial = login;
  
  // Auth routes
  static const String login = '/login';
  static const String register = '/register';
  
  // Main routes
  static const String bottomNav = '/bottom-nav';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case bottomNav:
        return MaterialPageRoute(builder: (_) => const BottomNavScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case AppRouter.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
