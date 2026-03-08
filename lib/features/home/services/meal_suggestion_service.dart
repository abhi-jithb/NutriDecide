import '../../profile/models/user_profile.dart';
import '../../scan/models/scan_history_item.dart';

class MealSuggestion {
  final String title;
  final String description;
  final String icon; // Icon name or category

  MealSuggestion({required this.title, required this.description, required this.icon});
}

class MealSuggestionService {
  List<MealSuggestion> getSuggestions(UserProfile profile, List<ScanHistoryItem> todayScans) {
    List<MealSuggestion> suggestions = [];

    // Analyze today's scans for specific trends
    int highSugarCount = 0;
    int highSodiumCount = 0;
    int avoidCount = 0;

    final today = DateTime.now();
    final todayScansList = todayScans.where((s) => 
      s.timestamp.year == today.year && 
      s.timestamp.month == today.month && 
      s.timestamp.day == today.day
    ).toList();

    for (var scan in todayScansList) {
      if (scan.verdict == 'AVOID') avoidCount++;
      // Since we don't store detailed nutrients in history yet, we rely on the verdict or common patterns
    }

    // 1. General Health Alerts
    if (avoidCount > 0) {
      suggestions.add(MealSuggestion(
        title: "Cleanse Suggestion",
        description: "You've had some processed items today. Try a fresh green salad for your next meal to balance it out.",
        icon: "eco",
      ));
    }

    // 2. Profile-based suggestions
    if (profile.hasDiabetes) {
      suggestions.add(MealSuggestion(
        title: "Low Glycemic Pick",
        description: "Focus on fiber-rich oats or lentils for your next snack to keep insulin levels stable.",
        icon: "bloodtype",
      ));
    }

    if (profile.hasHypertension) {
      suggestions.add(MealSuggestion(
        title: "Potassium Boost",
        description: "Bananas or spinach can help balance out your sodium intake today.",
        icon: "heart_broken",
      ));
    }

    if (profile.dietType == "Vegan") {
      suggestions.add(MealSuggestion(
        title: "Protein Power",
        description: "Ensure you're getting enough B12 today. Consider a fortified nutritional yeast sprinkle.",
        icon: "restaurant",
      ));
    }

    if (profile.goal == "Weight Loss") {
      suggestions.add(MealSuggestion(
        title: "Hydration Check",
        description: "Sometimes thirst is mistaken for hunger. Drink a glass of lemon water before your next snack.",
        icon: "water_drop",
      ));
    }

    // Default suggestion if list is empty
    if (suggestions.isEmpty) {
      suggestions.add(MealSuggestion(
        title: "Daily Balanced Meal",
        description: "A combination of lean protein, healthy fats, and complex carbs is ideal for you right now.",
        icon: "restaurant",
      ));
    }

    return suggestions;
  }
}
