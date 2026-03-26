import '../models/nutrition_data.dart';
import '../../profile/models/user_profile.dart';
import 'ingredient_analyzer.dart';

class ScoringEngine {
  /// Calculates a risk score (0-100) based on nutritional content and user profile.
  static double calculateRiskScore({
    required NutritionData product,
    required UserProfile profile,
    required IngredientAnalysisResult ingredientAnalysis,
  }) {
    final nutrients = product.nutrients;
    final sugar = _asDouble(nutrients['sugars_100g']) ?? 0.0;
    final sodium = _asDouble(nutrients['sodium_100g']) ?? 0.0; // in grams
    final satFat = _asDouble(nutrients['saturated-fat_100g'] ?? nutrients['saturated_fat_100g']) ?? 0.0;
    final kcal = _asDouble(nutrients['energy-kcal_100g'] ?? nutrients['energy_kcal_100g']) ?? 0.0;
    final fiber = _asDouble(nutrients['fiber_100g']) ?? 0.0;
    final protein = _asDouble(nutrients['protein_100g']) ?? 0.0;

    // Multipliers based on medical conditions
    double sugarMultiplier = 1.0;
    double sodiumMultiplier = 1.0;
    double satFatMultiplier = 1.0;

    if (profile.hasDiabetes) {
      sugarMultiplier = 2.5; // High sensitivity to sugar
    }
    if (profile.hasHypertension) {
      sodiumMultiplier = 3.5; // Extreme sensitivity to sodium (Salt)
    }
    if (profile.hasPcos) {
      satFatMultiplier = 2.0;
      sugarMultiplier = 1.5;
    }

    // Weighted Risk Calculation
    // Base Risk (0-100)
    double calculatedRisk = 0;

    // 1. Sugar Risk
    // Assuming 'sugar' is in grams per 100g
    if (sugar > 15) {
      calculatedRisk += (sugar - 15) * 1.5 * sugarMultiplier;
    } else if (sugar > 5 && profile.hasDiabetes) {
      calculatedRisk += 20 * sugarMultiplier;
    }
    
    // 2. Sodium Risk (THE SALT FIX)
    // Sodium is in grams per 100g, convert to mg for easier comparison
    final sodiumMg = sodium * 1000;
    // Salt is roughly 40% Sodium. A product with >400mg sodium per 100g is HIGH.
    if (sodiumMg > 400) {
      calculatedRisk += (sodiumMg / 100) * 2.5 * sodiumMultiplier;
    } else if (sodiumMg > 150 && profile.hasHypertension) {
      // For hypertensive users, even moderate sodium is risky
      calculatedRisk += 40 * sodiumMultiplier;
    }

    // 3. Saturated Fat Risk
    // Assuming 'satFat' is in grams per 100g
    if (satFat > 5) calculatedRisk += (satFat - 5) * 2.5 * satFatMultiplier;

    // 4. Calorie Density & Goals
    if (kcal > 500) {
      calculatedRisk += (profile.goal == 'Weight Loss') ? 30 : 15;
    } else if (kcal > 300) {
      calculatedRisk += (profile.goal == 'Weight Loss') ? 15 : 5;
    }
    
    // Weight Gain Bonus: High calorie is NOT necessarily bad if no other red flags
    if (profile.goal == 'Weight Gain' && kcal > 400 && sugar < 10) {
      calculatedRisk -= 10;
    }

    // 5. Ingredient Additives & Processing
    if (ingredientAnalysis.hasHarmfulAdditives) calculatedRisk += 20;
    if (ingredientAnalysis.hasRefinedSugars) calculatedRisk += 15;
    if (ingredientAnalysis.hasArtificialSweeteners) {
      // Stricter for fitness mode
      calculatedRisk += (profile.dietType == 'Fitness / Gym') ? 25 : 10;
    }

    // 6. Fitness / Gym Mode Optimizations
    if (profile.dietType == 'Fitness / Gym') {
      // Penalize low protein/high calorie density
      if (protein < 5 && kcal > 350) {
        calculatedRisk += 20;
      }
      // Stricter sugar limit for athletes
      if (sugar > 8) calculatedRisk += 15;
    }

    // 7. Bonuses (Deductions)
    if (fiber > 2) {
      calculatedRisk -= (fiber / 5.0) * 15.0; // Max 15 point bonus
    }
    if (protein > 10 && profile.dietType == 'Fitness / Gym') {
      calculatedRisk -= (protein / 10.0) * 15.0; // Protein bonus for gym mode
    }

    // 8. Ingredient-based Red Flags (Processed Additives) - Direct string checks
    final ingredientsLower = product.ingredients.join(' ').toLowerCase();
    if (ingredientsLower.contains("high fructose corn syrup")) calculatedRisk += 25;
    if (ingredientsLower.contains("msg") || ingredientsLower.contains("monosodium glutamate")) calculatedRisk += 20;
    if (ingredientsLower.contains("palm oil")) calculatedRisk += 15;
    if (ingredientsLower.contains("sodium nitrate")) calculatedRisk += 20;

    // 9. Final Fail-Safe: Allergies
    for (String allergy in profile.allergies) {
      final allergyLower = allergy.toLowerCase().trim();
      if (allergyLower.isEmpty) continue;

      // Smart matching: e.g. "Peanut" matches "Peanuts", "Peanut oil", etc.
      if (ingredientsLower.contains(allergyLower)) {
        return 100.0; // Immediate Maximum Risk
      }
    }

    // 10. Vegan/Vegetarian Check
    if (profile.dietType == 'Vegan') {
      final animalProducts = ['milk', 'egg', 'honey', 'meat', 'beef', 'pork', 'gelatin', 'curd', 'ghee', 'fish', 'whey'];
      if (product.ingredients.any((ing) => animalProducts.any((ap) => ing.toLowerCase().contains(ap)))) {
        return 100.0;
      }
    }

    return calculatedRisk.clamp(0.0, 100.0);
  }

  static List<String> generateReasons({
    required NutritionData product,
    required UserProfile profile,
    required IngredientAnalysisResult ingredientAnalysis,
    required double riskScore,
  }) {
    final List<String> reasons = [];
    final nutrients = product.nutrients;
    
    final sugar = _asDouble(nutrients['sugars_100g']);
    final sodium = _asDouble(nutrients['sodium_100g']);
    final kcal = _asDouble(nutrients['energy-kcal_100g'] ?? nutrients['energy_kcal_100g']);
    final protein = _asDouble(nutrients['protein_100g']);

    if (sugar != null && sugar > 15) reasons.add('High sugar content (${sugar.toStringAsFixed(1)}g/100g).');
    if (sodium != null && sodium > 0.6) reasons.add('High sodium levels detected.');
    if (kcal != null && kcal > 400) reasons.add('High calorie density.');
    
    if (profile.hasDiabetes && (ingredientAnalysis.hasRefinedSugars || (sugar ?? 0) > 10)) {
      reasons.add('Contains ingredients that impact insulin sensitivity.');
    }
    if (profile.hasHypertension && (sodium ?? 0) > 0.4) {
      reasons.add('Sodium levels exceed safe threshold for hypertension.');
    }
    if (profile.dietType == 'Fitness / Gym') {
      if ((protein ?? 0) < 5) reasons.add('Low protein-to-calorie ratio.');
      if (ingredientAnalysis.hasArtificialSweeteners) reasons.add('Artificial sweeteners may impact gut microbiome/cravings.');
    }

    reasons.addAll(ingredientAnalysis.warnings.take(3));

    if (reasons.isEmpty) reasons.add('Balanced nutritional profile.');
    reasons.add('Guidance only. Not medical advice.');

    return reasons.toSet().toList();
  }

  static double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
