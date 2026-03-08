import 'package:flutter/material.dart';
import '../profile/models/user_profile.dart';
import '../profile/data/profile_repository.dart';
import '../scan/scan_screen.dart';
import '../scan/models/scan_history_item.dart';
import '../scan/data/scan_repository.dart';
import 'services/meal_suggestion_service.dart';
import 'services/pattern_coach_service.dart';
import '../scan/services/risk_analysis_service.dart';
import '../../core/theme/app_theme.dart';
import 'voice_log_screen.dart';
import '../scan/presentation/history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScanRepository _scanRepo = ScanRepository();
  final ProfileRepository _profileRepo = ProfileRepository();
  final MealSuggestionService _mealService = MealSuggestionService();
  final PatternCoachService _coachService = PatternCoachService();

  UserProfile? _profile;
  List<ScanHistoryItem> _history = [];
  List<MealSuggestion> _suggestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final profile = await _profileRepo.getProfile();
    final history = await _scanRepo.getHistory();
    
    List<MealSuggestion> suggestions = [];
    if (profile != null) {
      suggestions = _mealService.getSuggestions(profile, history);
    }
    
    setState(() {
      _profile = profile;
      _history = history;
      _suggestions = suggestions;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final today = DateTime.now();
    final riskyToday = _history.where((s) => 
      s.timestamp.year == today.year && 
      s.timestamp.month == today.month && 
      s.timestamp.day == today.day &&
      (s.verdict.contains("AVOID") || s.verdict.contains("CAUTION"))
    ).length;

    final coachInsight = _coachService.generateInsight(_history, _profile!);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 80,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  "NutriDecide Intelligence",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Daily Guidance - Compact
                    const Text(
                      "Daily Guidance",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    _buildProminentGuidance(),
                    
                    const SizedBox(height: 24),

                    // Scan Your Food - Important
                    if (riskyToday >= 2) _buildSmartAlert(riskyToday),
                    _buildScanCentral(),

                    const SizedBox(height: 32),

                    // Health Ecosystem
                    const Text(
                      "Health Ecosystem",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    _buildInnovationActions(context),
                    const SizedBox(height: 32),

                    // AI Pattern Coach Section (Phase 5)
                    _buildPatternCoachSection(coachInsight),
                    const SizedBox(height: 24),
                    
                    _buildRecentSection(),
                    const SizedBox(height: 100), // Extra space for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInnovationActions(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ActionChip(
            avatar: const Icon(Icons.mic_none, size: 18, color: Colors.blue),
            label: const Text("Voice Regional AI"),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VoiceLogScreen()),
            ),
            backgroundColor: Colors.blue.withOpacity(0.05),
          ),
          const SizedBox(width: 12),
          ActionChip(
            avatar: const Icon(Icons.family_restroom_rounded, size: 18, color: Colors.orange),
            label: const Text("Family Mode"),
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Family Mode: Linking profiles for Kerala homes soon!")),
              );
            },
            backgroundColor: Colors.orange.withOpacity(0.05),
          ),
          const SizedBox(width: 12),
          ActionChip(
            avatar: const Icon(Icons.health_and_safety_rounded, size: 18, color: Colors.green),
            label: const Text("Festival Mode"),
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Festival Mode: Adjusting for Onam feast logic!")),
              );
            },
            backgroundColor: Colors.green.withOpacity(0.05),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternCoachSection(PatternCoachInsight insight) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade900, Colors.indigo.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Icon(Icons.psychology, size: 80, color: Colors.white.withOpacity(0.05)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bolt, color: Colors.amber, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      "COACH INSIGHT",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  insight.title,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.suggestion,
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProminentGuidance() {
    if (_suggestions.isEmpty) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getIconData(_suggestions.first.icon), size: 14, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _suggestions.first.title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _suggestions.first.description,
            style: const TextStyle(fontSize: 11, color: Colors.black87, height: 1.2),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSmartAlert(int count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("High Risk Alert", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                Text(
                  "You've scanned $count risky items today. Limit processed intake.",
                  style: TextStyle(color: Colors.red.withOpacity(0.8), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanCentral() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.qr_code_scanner_rounded, 
              size: 80, 
              color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 24),
          const Text(
            "Scan Your Food",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            "Instant health analysis for any product",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScanScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 60),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt_outlined),
                SizedBox(width: 12),
                Text("OPEN SCANNER", style: TextStyle(letterSpacing: 1.1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          final s = _suggestions[index];
          return Container(
            width: 240,
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.4),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_getIconData(s.icon), size: 20, color: Theme.of(context).colorScheme.secondary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(s.title, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(s.description, 
                  style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
                  maxLines: 3, overflow: TextOverflow.ellipsis),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'eco': return Icons.eco_outlined;
      case 'bloodtype': return Icons.bloodtype_outlined;
      case 'heart_broken': return Icons.heart_broken_outlined;
      case 'restaurant': return Icons.restaurant_outlined;
      case 'water_drop': return Icons.water_drop_outlined;
      default: return Icons.tips_and_updates_outlined;
    }
  }

  Widget _buildRecentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Recent Scans",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (_history.isNotEmpty)
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ScanHistoryScreen()),
                ).then((_) => _loadData()), // Reload if history was cleared or updated
                child: const Text("View All"),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_history.isEmpty)
          const Center(child: Text("No scans today", style: TextStyle(color: Colors.grey)))
        else
          ..._history.take(3).map((item) => _buildRecentItem(item)),
      ],
    );
  }

  Widget _buildRecentItem(ScanHistoryItem item) {
    final color = _getStatusColor(item.verdict);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(Icons.fastfood_outlined, color: color),
        ),
        title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(item.barcode, style: const TextStyle(fontSize: 11)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(item.verdict, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Color _getStatusColor(String verdict) {
    if (verdict.contains("GOOD")) return Colors.green;
    if (verdict.contains("CAUTION")) return Colors.orange;
    if (verdict.contains("AVOID")) return Colors.red;
    return Colors.grey;
  }
}
