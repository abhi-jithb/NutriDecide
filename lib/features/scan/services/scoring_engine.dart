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
    double riskScore = 0;

    final nutrients = product.nutrients;
    final sugar100g = _asDouble(nutrients['sugars_100g']);
    final sodium100g = _asDouble(nutrients['sodium_100g']);
    final satFat100g = _asDouble(nutrients['saturated-fat_100g'] ?? nutrients['saturated_fat_100g']);
    final kcal100g = _asDouble(nutrients['energy-kcal_100g'] ?? nutrients['energy_kcal_100g']);
    final fiber100g = _asDouble(nutrients['fiber_100g']);
    final protein100g = _asDouble(nutrients['protein_100g']);

    // 1. Base Sugar Risk (High cap at 40 points)
    if (sugar100g != null) {
      double sugarBase = (sugar100g / 25.0) * 20.0; // 25g/100g is a lot
      if (profile.hasDiabetes) sugarBase *= 2.0;
      if (profile.hasPcos) sugarBase *= 1.5;
      riskScore += sugarBase.clamp(0, 50);
    }

    // 2. Base Sodium Risk (High cap at 40 points)
    if (sodium100g != null) {
      double sodiumMg = sodium100g * 1000;
      double sodiumBase = (sodiumMg / 800.0) * 20.0; // 800mg/100g is very high
      if (profile.hasHypertension) sodiumBase *= 2.0;
      riskScore += sodiumBase.clamp(0, 40);
    }

    // 3. Saturated Fat Risk
    if (satFat100g != null) {
      double fatBase = (satFat100g / 10.0) * 15.0; // 10g/100g is high
      riskScore += fatBase.clamp(0, 30);
    }

    // 4. Calorie Density
    if (kcal100g != null) {
      if (kcal100g > 500) riskScore += 20;
      else if (kcal100g > 300) riskScore += 10;
    }

    // 5. Ingredient Additives & Processing
    if (ingredientAnalysis.hasHarmfulAdditives) riskScore += 15;
    if (ingredientAnalysis.hasRefinedSugars) riskScore += 10;
    if (ingredientAnalysis.hasArtificialSweeteners) {
      // Stricter for fitness mode
      riskScore += (profile.dietType == 'Fitness / Gym') ? 20 : 10;
    }

    // 6. Fitness / Gym Mode Optimizations
    if (profile.dietType == 'Fitness / Gym') {
      // Penalize low protein/high calorie density
      if (protein100g != null && protein100g < 5 && kcal100g != null && kcal100g > 400) {
        riskScore += 15;
      }
      // Stricter salt/sugar for athletes
      if ((sugar100g ?? 0) > 10) riskScore += 10;
    }

    // 7. Bonuses (Deductions)
    if (fiber100g != null) {
      riskScore -= (fiber100g / 5.0) * 10.0; // Max 10 point bonus
    }
    if (protein100g != null && profile.dietType == 'Fitness / Gym') {
      riskScore -= (protein100g / 10.0) * 10.0; // Protein bonus for gym mode
    }

    // 8. Absolute Blockers (Allergies/Dietary Mismatch)
    for (var allergy in profile.allergies) {
      if (product.ingredients.any((ing) => ing.toLowerCase().contains(allergy.toLowerCase()))) {
        return 100.0; // Immediate Avoid
      }
    }

    // Vegan/Vegetarian Check
    if (profile.dietType == 'Vegan') {
      final animalProducts = ['milk', 'egg', 'honey', 'meat', 'beef', 'pork', 'gelatin', 'curd', 'ghee', 'fish', 'whey'];
      if (product.ingredients.any((ing) => animalProducts.any((ap) => ing.toLowerCase().contains(ap)))) {
        return 100.0;
      }
    }

    return riskScore.clamp(0.0, 100.0);
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
