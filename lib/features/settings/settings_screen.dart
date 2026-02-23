import 'package:flutter/material.dart';
import '../../../app.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          _sectionTitle("Account"),
          _settingsTile(
            icon: Icons.lock_outline,
            title: "Change Password",
            onTap: () {},
          ),
          _settingsTile(
            icon: Icons.logout,
            title: "Logout",
            onTap: () {},
          ),
          _settingsTile(
            icon: Icons.delete_outline,
            title: "Delete Account",
            isDestructive: true,
            onTap: () {
              _showDeleteDialog(context);
            },
          ),

          const SizedBox(height: 20),

          _sectionTitle("Data & Privacy"),
          _settingsTile(
            icon: Icons.download,
            title: "Export My Data",
            subtitle: "Download profile and logs",
            onTap: () {},
          ),
          _settingsTile(
            icon: Icons.delete_sweep,
            title: "Delete All Logs",
            onTap: () {},
          ),
          _settingsTile(
            icon: Icons.privacy_tip_outlined,
            title: "Privacy Policy",
            onTap: () {},
          ),
          _settingsTile(
            icon: Icons.description_outlined,
            title: "Terms & Conditions",
            onTap: () {},
          ),

          const SizedBox(height: 20),

          _sectionTitle("Permissions"),
          _settingsTile(
            icon: Icons.camera_alt_outlined,
            title: "Camera Permission",
            subtitle: "Required for scanning",
            trailing: const Icon(Icons.check_circle, color: Colors.green),
            onTap: () {},
          ),
          _settingsTile(
            icon: Icons.notifications_outlined,
            title: "Notifications",
            subtitle: "Meal reminders & updates",
            trailing: const Icon(Icons.check_circle, color: Colors.green),
            onTap: () {},
          ),

          const SizedBox(height: 20),

          _sectionTitle("Subscription"),
          _subscriptionCard(context),

          const SizedBox(height: 20),

          _sectionTitle("App Preferences"),
          SwitchListTile(
            value: isDarkMode,
            title: const Text("Dark Mode"),
            onChanged: (value) {
              setState(() {
                isDarkMode = value;
              });
              MyApp.of(context)?.toggleTheme(value);
            },
          ),
          SwitchListTile(
            value: true,
            onChanged: (val) {},
            title: const Text("Enable Notifications"),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : Colors.green),
        title: Text(
          title,
          style: TextStyle(color: isDestructive ? Colors.red : Colors.black),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _subscriptionCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Free Plan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("Upgrade to Premium for advanced analysis."),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Upgrade"),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("This action cannot be undone. Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {},
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}