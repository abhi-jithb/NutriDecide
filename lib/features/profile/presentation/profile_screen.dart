import 'package:flutter/material.dart';
import '../../../routes/app_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.settings);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 16),
            const Text(
              'User Name',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'user@email.com',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            _buildProfileTile(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () {},
            ),
            _buildProfileTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () {},
            ),
            _buildProfileTile(
              icon: Icons.history,
              title: 'History',
              onTap: () {},
            ),
            _buildProfileTile(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {},
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRouter.login);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
