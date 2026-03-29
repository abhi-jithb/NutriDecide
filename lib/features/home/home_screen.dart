import 'package:flutter/material.dart';
import '../profile/data/profile_repository.dart';
import '../profile/models/user_profile.dart';
import '../scan/scan_screen.dart';
import '../scan/models/scan_history_item.dart';
import '../scan/data/scan_repository.dart';
import 'services/health_score_service.dart';
import '../scan/presentation/history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScanRepository _scanRepo = ScanRepository();
  final ProfileRepository _profileRepo = ProfileRepository();
  UserProfile? _profile;
  List<ScanHistoryItem> _history = [];
  bool _isLoading = true;
  int _streak = 0;
  double _dailyScore = 100.0;
  String _dailyGoal = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final profile = await _profileRepo.getProfile();
    final history = await _scanRepo.getHistory();
    
    if (profile != null) {
      _streak = HealthScoreService.getStreak(history);
      _dailyScore = HealthScoreService.calculateDailyScore(history, profile);
      _dailyGoal = HealthScoreService.getDailyGoal(history);
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              const SizedBox(height: 32),
              _buildHeader(),
              const SizedBox(height: 32),
              _buildScoreCard(),
              const SizedBox(height: 24),
              _buildScanButton(),
              const SizedBox(height: 48),
              if (_history.isNotEmpty) ...[
                Text(
                  "Recent Scans",
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 16),
                ..._history.take(5).map((item) => _buildRecentItem(item)),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ScanHistoryScreen()),
                  ).then((_) => _loadData()),
                  child: Text(
                    "View Full History →",
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ] else 
                _buildEmptyState(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hi ${_profile?.name?.split(' ').first ?? 'there'} 👋",
          style: TextStyle(
            fontSize: 28, 
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        Text(
          "Ready to check your food?",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6), 
            fontSize: 16, 
            fontWeight: FontWeight.w500
          ),
        ),
        const SizedBox(height: 12),
        if (_streak > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bolt_rounded, 
                  color: Theme.of(context).colorScheme.onSecondaryContainer, 
                  size: 16
                ),
                const SizedBox(width: 4),
                Text(
                  "$_streak DAY STREAK",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer, 
                    fontSize: 11, 
                    fontWeight: FontWeight.w900
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildScoreCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color scoreColor = Colors.green.shade600;
    if (_dailyScore < 80) scoreColor = Colors.orange.shade600;
    if (_dailyScore < 50) scoreColor = Colors.red.shade600;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200
        ),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: scoreColor, width: 4),
            ),
            child: Center(
              child: Text(
                _dailyScore.toInt().toString(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: scoreColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Daily Health Score",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _dailyGoal,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton() {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ScanScreen()),
      ).then((_) => _loadData()),
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 64),
            const SizedBox(height: 24),
            const Text(
              "SCAN PRODUCT",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
            const SizedBox(height: 8),
            Text(
              "Instant health verdict for any barcode",
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentItem(ScanHistoryItem item) {
    final color = _getStatusColor(item.verdict);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200
        ),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.restaurant_rounded, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName, 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurface,
                  )
                ),
                Text(
                  item.verdict, 
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right, 
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3), 
            size: 20
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 48),
          Icon(
            Icons.history, 
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.1), 
            size: 48
          ),
          const SizedBox(height: 16),
          Text(
            "No scans yet. Start identifying your food!",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.4), 
              fontSize: 14
            ),
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
