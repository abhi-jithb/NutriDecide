import 'package:flutter/material.dart';
import 'models/user_profile.dart';
import 'data/profile_repository.dart';
import '../auth/presentation/profile_setup_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final profile = await ProfileRepository().getProfile();
    setState(() {
      _profile = profile;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("My Health Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildProfileCard(),
            const SizedBox(height: 32),
            _buildSectionHeader("Biometrics"),
            const SizedBox(height: 16),
            _buildBiometricGrid(),
            const SizedBox(height: 32),
            _buildSectionHeader("Conditions & Allergies"),
            const SizedBox(height: 16),
            _buildMedicalCard(),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileSetupScreen(
                      uid: ProfileRepository().currentUid!,
                      existingProfile: _profile,
                    ),
                  ),
                );
                if (result == true) _loadAllData();
              },
              child: const Text("UPDATE HEALTH PROFILE"),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.person, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            _profile?.gender ?? "User Profile",
            style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          Text(
            "${_profile?.age ?? 25} Years Old",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6), 
              fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title, 
          style: TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.w900, 
            letterSpacing: -0.5,
            color: Theme.of(context).colorScheme.onBackground,
          )
        ),
      ],
    );
  }

  Widget _buildBiometricGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildGridStat("Height", "${_profile?.height} cm", Icons.height, Colors.blue),
        _buildGridStat("Weight", "${_profile?.weight} kg", Icons.monitor_weight_outlined, Colors.orange),
        _buildGridStat("Goal", _profile?.goal ?? "Maintain", Icons.track_changes, Colors.purple),
        _buildGridStat("Diet", _profile?.dietType ?? "No Restriction", Icons.restaurant, Colors.green),
      ],
    );
  }

  Widget _buildGridStat(String title, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value, 
            style: TextStyle(
              fontWeight: FontWeight.w900, 
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface,
            )
          ),
          Text(
            title, 
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), 
              fontSize: 11
            )
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalCard() {
    final conditions = _profile?.conditions ?? [];
    final allergies = _profile?.allergies ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Known Conditions", 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            )
          ),
          const SizedBox(height: 8),
          if (conditions.isEmpty)
            Text(
              "None reported", 
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4))
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: conditions.map((c) => _buildChip(c, Colors.red.shade400)).toList(),
            ),
          const SizedBox(height: 24),
          Text(
            "Active Allergies", 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            )
          ),
          const SizedBox(height: 8),
          if (allergies.isEmpty)
            Text(
              "None reported", 
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4))
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allergies.map((a) => _buildChip(a, Colors.orange.shade400)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );
  }
}