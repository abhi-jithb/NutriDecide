import 'package:flutter/material.dart';
import '../data/scan_repository.dart';
import '../models/scan_history_item.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  final ScanRepository _scanRepo = ScanRepository();
  List<ScanHistoryItem> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _scanRepo.getHistory();
    setState(() {
      _history = history.reversed.toList(); // Newest first
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan History"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? const Center(
                  child: Text(
                    "No scans found.\nStart scanning to build your history!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    final color = _getStatusColor(item.verdict);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(Icons.fastfood_outlined, color: color),
                        ),
                        title: Text(
                          item.productName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "${item.timestamp.day}/${item.timestamp.month}/${item.timestamp.year} • ${item.barcode}",
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            item.verdict,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
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
