import 'package:flutter/material.dart';
import '../../../app.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Preferences & Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _buildSubscriptionBanner(theme),
          const SizedBox(height: 24),

          _sectionHeader("App Customization"),
          _settingsSwitch(
            title: "Dark Mode",
            subtitle: "Switch between light and dark themes",
            icon: Icons.dark_mode_outlined,
            value: theme.brightness == Brightness.dark,
            onChanged: (val) => MyApp.of(context)?.toggleTheme(val),
          ),
          _settingsSwitch(
            title: "Health Alerts",
            subtitle: "Real-time warnings on risky scans",
            icon: Icons.notifications_active_outlined,
            value: true,
            onChanged: (val) {},
          ),
          
          const SizedBox(height: 24),
          _sectionHeader("Account & Security"),
          _settingsActionTile(
            title: "Manage Health Profile",
            subtitle: "Update allergies, conditions & metrics",
            icon: Icons.health_and_safety_outlined,
            onTap: () {},
          ),
          _settingsActionTile(
            title: "Security Settings",
            subtitle: "Change password & biometrics",
            icon: Icons.lock_person_outlined,
            onTap: () {},
          ),
          _settingsActionTile(
            title: "Sign Out",
            icon: Icons.logout_rounded,
            isDestructive: true,
            onTap: () {},
          ),

          const SizedBox(height: 24),
          _sectionHeader("Data Transparency"),
          _settingsActionTile(
            title: "Privacy Center",
            subtitle: "Control how your health data is used",
            icon: Icons.privacy_tip_outlined,
            onTap: () {},
          ),
          _settingsActionTile(
            title: "Export Health Data",
            subtitle: "Download your scan history PDF",
            icon: Icons.file_download_outlined,
            onTap: () {},
          ),
          
          const SizedBox(height: 32),
          const Center(
            child: Text(
              "NutriDecide v1.2.0 • Build 246",
              style: TextStyle(color: Colors.grey, fontSize: 12),
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
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.withOpacity(0.8),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSubscriptionBanner(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "GO PREMIUM",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Icon(Icons.star_rounded, color: Colors.amber, size: 32),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Unlock detailed additive analysis and personalized meal planners.",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: theme.colorScheme.primary,
              minimumSize: const Size(120, 45),
            ),
            child: const Text("UPGRADE NOW"),
          ),
        ],
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
    final color = isDestructive ? Colors.red : Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: onTap,
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
            color: isDestructive ? Colors.red : null,
          ),
        ),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        activeColor: color,
      ),
    );
  }
}