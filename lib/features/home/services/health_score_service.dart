import '../../scan/models/scan_history_item.dart';
import '../../profile/models/user_profile.dart';

class HealthScoreService {
  /// Calculates a Daily Health Score (DHS) from 0 to 100.
  /// 
  /// Logic:
  /// - Base: 100
  /// - Each 'AVOID' scan: -15 to -25 points (depending on profile)
  /// - Each 'CAUTION' scan: -5 to -10 points
  /// - Each 'GOOD' scan: +5 points (recovery)
  /// - Minimum logs for a 'valid' day: 3
  static double calculateDailyScore(List<ScanHistoryItem> history, UserProfile profile) {
    if (history.isEmpty) return 100.0;

    final today = DateTime.now();
    final todayScans = history.where((s) {
      return s.timestamp.year == today.year &&
             s.timestamp.month == today.month &&
             s.timestamp.day == today.day;
    }).toList();

    if (todayScans.isEmpty) return 100.0;

    double score = 100.0;
    
    for (var scan in todayScans) {
      final verdict = scan.verdict.toUpperCase();
      
      if (verdict.contains('AVOID')) {
        double penalty = 20.0;
        // Stricter penalties for medical conditions
        if (profile.hasDiabetes || profile.hasHypertension || profile.hasPcos) {
          penalty = 30.0;
        }
        score -= penalty;
      } else if (verdict.contains('CAUTION')) {
        score -= 8.0;
      } else if (verdict.contains('GOOD')) {
        score += 5.0;
      }
    }

    return score.clamp(0.0, 100.0);
  }

  /// Calculates the current daily streak of logs.
  static int getStreak(List<ScanHistoryItem> history) {
    if (history.isEmpty) return 0;

    // Sort history by date descending
    final sorted = List<ScanHistoryItem>.from(history)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    int streak = 0;
    DateTime checkDate = DateTime.now();
    
    // Normalize to date only
    DateTime normalize(DateTime d) => DateTime(d.year, d.month, d.day);
    
    DateTime lastDate = normalize(checkDate);
    
    // Check if logged today or yesterday
    bool hasToday = sorted.any((s) => normalize(s.timestamp) == lastDate);
    if (!hasToday) {
      lastDate = lastDate.subtract(const Duration(days: 1));
      bool hasYesterday = sorted.any((s) => normalize(s.timestamp) == lastDate);
      if (!hasYesterday) return 0;
    }

    // Go backwards and count days
    while (true) {
      if (sorted.any((s) => normalize(s.timestamp) == lastDate)) {
        streak++;
        lastDate = lastDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  static String getDailyGoal(List<ScanHistoryItem> history) {
    final today = DateTime.now();
    final todayCount = history.where((s) => 
      s.timestamp.year == today.year && 
      s.timestamp.month == today.month && 
      s.timestamp.day == today.day
    ).length;

    if (todayCount == 0) return "Scan your breakfast to start your day!";
    if (todayCount == 1) return "Log 2 more items to unlock today's score.";
    if (todayCount < 3) return "Almost there! One more log for a full report.";
    return "Daily goal reached! Keep making healthy choices.";
  }
}
