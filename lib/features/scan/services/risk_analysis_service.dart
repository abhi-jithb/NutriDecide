import '../models/scan_history_item.dart';

class HealthTrendData {
  final DateTime date;
  final double score;

  HealthTrendData(this.date, this.score);
}

class RiskAnalysisService {
  List<HealthTrendData> calculateWeeklyTrends(List<ScanHistoryItem> history) {
    Map<DateTime, List<double>> dailyScores = {};

    // Group scores by day
    for (var item in history) {
      final date = DateTime(item.timestamp.year, item.timestamp.month, item.timestamp.day);
      double score = 100.0;
      if (item.verdict.contains("CAUTION")) score = 50.0;
      if (item.verdict.contains("AVOID")) score = 0.0;

      dailyScores.putIfAbsent(date, () => []).add(score);
    }

    // Calculate averages for the last 7 days
    List<HealthTrendData> trends = [];
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final dayScores = dailyScores[day];
      
      double average = 100.0; // Assume perfect if no scans (or maybe 0?)
      if (dayScores != null && dayScores.isNotEmpty) {
        average = dayScores.reduce((a, b) => a + b) / dayScores.length;
      } else {
        // If no scans, we might want to represent it as "no data" or use the last known score.
        // For visual clarity, let's use 100 if no bad scans happened.
      }
      
      trends.add(HealthTrendData(day, average));
    }

    return trends;
  }
}
