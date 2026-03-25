import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutri_decide/app.dart';
import 'package:nutri_decide/features/auth/services/auth_service.dart';
import 'package:nutri_decide/features/auth/presentation/login_screen.dart';
import 'package:nutri_decide/features/auth/presentation/profile_setup_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _healthAlerts = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _healthAlerts = prefs.getBool('health_alerts') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _toggleHealthAlerts(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('health_alerts', value);
    setState(() => _healthAlerts = value);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Preferences"),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          _sectionHeader("App Customization"),
          _settingsSwitch(
            title: "Dark Mode",
            subtitle: "Switch between light and dark themes",
            icon: Icons.dark_mode_outlined,
            value: isDark,
            onChanged: (val) => MyApp.of(context)?.toggleTheme(val),
          ),
          _settingsSwitch(
            title: "Health Alerts",
            subtitle: "Warning notifications on risky food scans",
            icon: Icons.notifications_active_outlined,
            value: _healthAlerts,
            onChanged: _toggleHealthAlerts,
          ),
          
          const SizedBox(height: 32),
          _sectionHeader("Account"),
          _settingsActionTile(
            title: "Manage Health Profile",
            subtitle: "Update allergies, conditions & metrics",
            icon: Icons.health_and_safety_outlined,
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => ProfileSetupScreen(uid: AuthService().currentUser!.uid))
              );
            },
          ),
          _settingsActionTile(
            title: "Sign Out",
            icon: Icons.logout_rounded,
            isDestructive: true,
            onTap: () async {
              await AuthService().logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false
                );
              }
            },
          ),

          const SizedBox(height: 32),
          _sectionHeader("Data Transparency"),
          _settingsActionTile(
            title: "Privacy Center",
            subtitle: "Control how your health data is used",
            icon: Icons.privacy_tip_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyCenterScreen())
              );
            },
          ),
          
          const SizedBox(height: 48),
          Center(
            child: Text(
              "NutriDecide v1.5.0 • Production Ready",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.4), 
                fontSize: 12,
                fontWeight: FontWeight.w500
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _settingsActionTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red.shade400 : Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: isDestructive ? Colors.red.shade400 : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: subtitle != null ? Text(
          subtitle, 
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
          )
        ) : null,
        trailing: Icon(
          Icons.arrow_forward_ios_rounded, 
          size: 14, 
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)
        ),
      ),
    );
  }

  Widget _settingsSwitch({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final color = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
      ),
      child: SwitchListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        value: value,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title, 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 15,
            color: Theme.of(context).colorScheme.onSurface,
          )
        ),
        subtitle: Text(
          subtitle, 
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
          )
        ),
        activeColor: color,
      ),
    );
  }
}

class PrivacyCenterScreen extends StatelessWidget {
  const PrivacyCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Center")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Health Data, Your Control",
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "NutriDecide is built with a 'Privacy First' philosophy. Here is how we handle your biometrics and scan history:",
              style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6), height: 1.5),
            ),
            const SizedBox(height: 40),
            _privacyItem(
              context,
              Icons.storage_rounded,
              "Local Persistence",
              "Most scan data is stored locally on your device to ensure maximum speed and offline access.",
            ),
            _privacyItem(
              context,
              Icons.cloud_done_rounded,
              "Cloud Sync",
              "Your core health profile is synced to Firebase Firestore so you can access it across devices securely.",
            ),
            _privacyItem(
              context,
              Icons.security_rounded,
              "Encryption",
              "All communication between the app and servers is encrypted via SSL.",
            ),
            _privacyItem(
              context,
              Icons.analytics_outlined,
              "No 3rd Party Selling",
              "We never share or sell your individual health metrics or food preferences with advertisers.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _privacyItem(BuildContext context, IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.green.shade600, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: TextStyle(
                    fontWeight: FontWeight.w800, 
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onBackground,
                  )
                ),
                const SizedBox(height: 6),
                Text(
                  description, 
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5), 
                    fontSize: 14,
                    height: 1.4
                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}