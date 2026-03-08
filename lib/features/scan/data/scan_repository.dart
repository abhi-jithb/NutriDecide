import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_history_item.dart';

class ScanRepository {
  static const String _historyKey = 'scan_history';

  Future<void> saveScan(ScanHistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    
    // Add to the beginning and keep only last 20
    history.insert(0, item);
    if (history.length > 20) {
      history.removeRange(20, history.length);
    }

    final jsonList = history.map((e) => e.toJson()).toList();
    await prefs.setStringList(_historyKey, jsonList);
  }

  Future<List<ScanHistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_historyKey);
    if (jsonList == null) return [];

    try {
      return jsonList.map((e) => ScanHistoryItem.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
