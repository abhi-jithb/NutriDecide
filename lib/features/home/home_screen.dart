import 'package:flutter/material.dart';
import '../profile/models/user_profile.dart';
import '../profile/data/profile_repository.dart';
import '../scan/scan_screen.dart';
import '../scan/models/scan_history_item.dart';
import '../scan/data/scan_repository.dart';
import 'services/meal_suggestion_service.dart';
import 'services/pattern_coach_service.dart';
import 'services/health_score_service.dart';
import '../../core/theme/app_theme.dart';
import 'voice_log_screen.dart';
import '../scan/presentation/history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final ScanRepository _scanRepo = ScanRepository();
  final ProfileRepository _profileRepo = ProfileRepository();
  final MealSuggestionService _mealService = MealSuggestionService();
  final PatternCoachService _coachService = PatternCoachService();

  UserProfile? _profile;
  List<ScanHistoryItem> _history = [];
  List<MealSuggestion> _suggestions = [];
  bool _isLoading = true;
  double _healthScore = 100.0;
  int _streak = 0;
  String _dailyGoal = "";

  late AnimationController _scoreController;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _scoreController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scoreAnimation = Tween<double>(begin: 0, end: 100).animate(CurvedAnimation(
      parent: _scoreController,
      curve: Curves.easeOutCubic,
    ));
    _loadData();
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final profile = await _profileRepo.getProfile();
    final history = await _scanRepo.getHistory();
    
    if (profile != null) {
      _healthScore = HealthScoreService.calculateDailyScore(history, profile);
      _streak = HealthScoreService.getStreak(history);
      _dailyGoal = HealthScoreService.getDailyGoal(history);
      _suggestions = _mealService.getSuggestions(profile, history);
      
      _scoreAnimation = Tween<double>(begin: 0, end: _healthScore).animate(CurvedAnimation(
        parent: _scoreController,
        curve: Curves.easeOutCubic,
      ));
      _scoreController.forward(from: 0);
    }
    
    setState(() {
      _profile = profile;
      _history = history;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_profile == null) {
      return const Scaffold(body: Center(child: Text("Profile missing")));
    }

    final coachInsight = _coachService.generateInsight(_history, _profile!);

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildCustomHeader(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildDailyGoalBanner(),
                    const SizedBox(height: 32),
                    _buildLogCoreSection(context),
                    const SizedBox(height: 40),
                    _buildPatternsAndInsights(coachInsight),
                    const SizedBox(height: 32),
                    _buildRecentSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      backgroundColor: Colors.white,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "DAILY HEALTH SCORE",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: _scoreAnimation,
                  builder: (context, child) {
                    return Text(
                      _scoreAnimation.value.toInt().toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 84,
                        fontWeight: FontWeight.w900,
                      ),
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bolt_rounded, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      "$_streak DAY STREAK",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyGoalBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.flag_circle_outlined, color: Theme.of(context).colorScheme.primary, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _dailyGoal,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogCoreSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildLogTile(
            context: context,
            title: "Scan Barcode",
            subtitle: "Instant Analysis",
            icon: Icons.qr_code_scanner_rounded,
            color: Theme.of(context).colorScheme.primary,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScanScreen()),
            ).then((_) => _loadData()),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildLogTile(
            context: context,
            title: "Voice Log",
            subtitle: "Street Foods AI",
            icon: Icons.mic_none_outlined,
            color: Colors.blue.shade700,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VoiceLogScreen()),
            ).then((_) => _loadData()),
          ),
        ),
      ],
    );
  }

  Widget _buildLogTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 180,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternsAndInsights(PatternCoachInsight insight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Personalized Intelligence",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "AI COACH SAYS",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                insight.title,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                insight.suggestion,
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Recent Logs",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (_history.isNotEmpty)
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ScanHistoryScreen()),
                ).then((_) => _loadData()),
                child: const Text("View All"),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_history.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Text("No nutrition logs for today.", style: TextStyle(color: Colors.grey.shade400)),
            ),
          )
        else
          ..._history.take(4).map((item) => _buildRecentItem(item)),
      ],
    );
  }

  Widget _buildRecentItem(ScanHistoryItem item) {
    final color = _getStatusColor(item.verdict);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.restaurant_rounded, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(item.verdict, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Text(
            "${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String verdict) {
    if (verdict.contains("GOOD")) return Colors.green.shade600;
    if (verdict.contains("CAUTION")) return Colors.orange.shade600;
    if (verdict.contains("AVOID")) return Colors.red.shade600;
    return Colors.grey;
  }
}
