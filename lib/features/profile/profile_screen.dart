import 'package:flutter/material.dart';
import 'models/user_profile.dart';
import 'data/profile_repository.dart';
import '../scan/data/scan_repository.dart';
import '../scan/services/risk_analysis_service.dart';
import '../home/widgets/health_trend_chart.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  List<HealthTrendData> _trends = [];
  bool _isLoading = true;
  double _currScore = 100.0;
  int _todayScans = 0;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final profile = await ProfileRepository().getProfile();
    final history = await ScanRepository().getHistory();
    final trends = RiskAnalysisService().calculateWeeklyTrends(history);
    
    final today = DateTime.now();
    final todayS = history.where((s) => 
      s.timestamp.year == today.year && 
      s.timestamp.month == today.month && 
      s.timestamp.day == today.day
    ).length;

    setState(() {
      _profile = profile;
      _trends = trends;
      if (trends.isNotEmpty) _currScore = trends.last.score;
      _todayScans = todayS;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, size: 45, color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Health DNA",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Stats Row
                  Row(
                    children: [
                      _buildQuickStat("Health Score", _currScore.toInt().toString(), Icons.favorite, Colors.red),
                      const SizedBox(width: 16),
                      _buildQuickStat("Scans Today", _todayScans.toString(), Icons.analytics, Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    "Weekly Suitability Trend",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  HealthTrendChart(trends: _trends),
                  const SizedBox(height: 32),

                  const Text(
                    "Biometrics & Goals",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (_profile == null)
                    const Center(child: Text("Please complete your profile setup."))
                  else ...[
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        _buildGridCard("Height", "${_profile!.height} cm", Icons.straighten, Colors.teal),
                        _buildGridCard("Weight", "${_profile!.weight} kg", Icons.scale, Colors.orange),
                        _buildGridCard("Goal", _profile!.goal, Icons.track_changes, Colors.purple),
                        _buildGridCard("Diet", _profile!.dietType, Icons.restaurant, Colors.amber),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildFullWidthCard("Medical Conditions", _getConditionsString(), Icons.medical_information, Colors.red),
                    _buildFullWidthCard("Allergies", _profile!.allergies.isEmpty ? "None" : _profile!.allergies.join(", "), Icons.warning_amber, Colors.deepOrange),
                  ],
                  const SizedBox(height: 40),
                  
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_note),
                    label: const Text("MODIFY HEALTH PROFILE"),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String title, String val, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildFullWidthCard(String title, String val, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getConditionsString() {
    if (_profile == null) return "None";
    List<String> conditions = [];
    if (_profile!.hasDiabetes) conditions.add("Diabetes");
    if (_profile!.hasHypertension) conditions.add("Hypertension");
    if (_profile!.hasPcos) conditions.add("PCOS");
    return conditions.isEmpty ? "None" : conditions.join(", ");
  }
}