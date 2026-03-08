import 'package:flutter/material.dart';
import '../profile/models/user_profile.dart';
import '../profile/data/profile_repository.dart';
import '../scan/scan_screen.dart';
import '../scan/models/scan_history_item.dart';
import '../scan/data/scan_repository.dart';
import 'services/meal_suggestion_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    final profile = await ProfileRepository().getProfile();
    final history = await ScanRepository().getHistory();
    
    List<MealSuggestion> suggestions = [];
    if (profile != null) {
      suggestions = MealSuggestionService().getSuggestions(profile, history);
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
    final today = DateTime.now();
    final riskyToday = _history.where((s) => 
      s.timestamp.year == today.year && 
      s.timestamp.month == today.month && 
      s.timestamp.day == today.day &&
      (s.verdict.contains("AVOID") || s.verdict.contains("CAUTION"))
    ).length;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  _profile != null ? "Hello, ${_profile?.gender == 'Male' ? 'Sir' : '👋'}" : "Welcome",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
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
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (riskyToday >= 2) _buildSmartAlert(riskyToday),
                    _buildScanCentral(),
                    const SizedBox(height: 32),
                    const Text(
                      "Daily Guidance",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildSuggestionsList(),
                    const SizedBox(height: 32),
                    _buildRecentSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
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
              TextButton(onPressed: () {}, child: const Text("View All")),
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
