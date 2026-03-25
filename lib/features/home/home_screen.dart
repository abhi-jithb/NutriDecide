import 'package:flutter/material.dart';
import '../profile/data/profile_repository.dart';
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
  List<ScanHistoryItem> _history = [];
  bool _isLoading = true;
  int _streak = 0;

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
    }
    
    setState(() {
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
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              const SizedBox(height: 32),
              _buildHeader(),
              const SizedBox(height: 40),
              _buildScanButton(),
              const SizedBox(height: 48),
              if (_history.isNotEmpty) ...[
                const Text(
                  "Recent Scans",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                ..._history.take(5).map((item) => _buildRecentItem(item)),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ScanHistoryScreen()),
                  ).then((_) => _loadData()),
                  child: const Text("View Full History →"),
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
          "Welcome back!",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        const Text(
          "Ready to check your food?",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        if (_streak > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt_rounded, color: Colors.amber.shade900, size: 16),
                const SizedBox(width: 4),
                Text(
                  "$_streak DAY STREAK",
                  style: TextStyle(color: Colors.amber.shade900, fontSize: 11, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
      ],
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
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
                Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(item.verdict, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 48),
          Icon(Icons.history, color: Colors.grey.shade300, size: 48),
          const SizedBox(height: 16),
          Text(
            "No scans yet. Start identifying your food!",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
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
