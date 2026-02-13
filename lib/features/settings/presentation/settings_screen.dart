import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Preferences'),
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Enable push notifications'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark theme'),
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() => _darkModeEnabled = value);
            },
          ),
          const Divider(),
          const _SectionHeader(title: 'About'),
          ListTile(
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
