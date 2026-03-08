import '../../scan/models/scan_history_item.dart';
import '../../profile/models/user_profile.dart';

class PatternCoachInsight {
  final String title;
  final String description;
  final String suggestion;
  final List<String> healthierAlternatives;

  PatternCoachInsight({
    required this.title,
    required this.description,
    required this.suggestion,
    this.healthierAlternatives = const [],
  });
}

class PatternCoachService {
  PatternCoachInsight generateInsight(List<ScanHistoryItem> history, UserProfile profile) {
    if (history.isEmpty) {
      return PatternCoachInsight(
        title: "Starting Your Journey",
        description: "Looks like you're just getting started. Keep scanning to see your behavioral patterns!",
        suggestion: "Try scanning your breakfast tomorrow.",
      );
    }

    // 🕵️ Pattern 1: High Sunday Sodium (Innovation Pillar: Festival/Weekend habits)
    final sundays = history.where((s) => s.timestamp.weekday == DateTime.sunday).toList();
    final highSaltSundays = sundays.where((s) => s.verdict.contains("CAUTION") || s.verdict.contains("AVOID")).length;

    if (highSaltSundays >= 2) {
      return PatternCoachInsight(
        title: "Sunday Sodium Spike",
        description: "You tend to scan high-sodium items on Sundays. This often leads to water retention.",
        suggestion: "Try swapping your Sunday chips for some homemade plantain chips with minimal salt.",
        healthierAlternatives: ["Banana Chips (Low Salt)", "Roasted Makhana", "Steam-cooked Kozhukkatta"],
      );
    }

    // 🕵️ Pattern 2: Diabetes Management (Innovation Pillar: Predictive Risk Alerts)
    if (profile.hasDiabetes) {
      final nightScans = history.where((s) => s.timestamp.hour >= 20).toList();
      final highSugarNight = nightScans.where((s) => s.verdict.contains("AVOID")).length;
      
      if (highSugarNight >= 2) {
        return PatternCoachInsight(
          title: "Late Night Sugar Risk",
          description: "Scanned high-sugar items after 8 PM twice this week. This can impact your morning glucose.",
          suggestion: "Try a small handful of almonds or a warm cup of sugar-free herbal tea instead.",
          healthierAlternatives: ["Almonds", "Greek Yogurt", "Sugar-free tea"],
        );
      }
    }

    // Default insight if no strong patterns found
    return PatternCoachInsight(
      title: "Consistent Tracking",
      description: "Great job scanning! You're making data-driven decisions for your ${profile.goal.toLowerCase()} goal.",
      suggestion: "Remember to drink 2 liters of water daily.",
    );
  }
}
