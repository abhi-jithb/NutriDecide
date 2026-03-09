import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nutrition_data.dart';
import '../../profile/models/user_profile.dart';

class NutritionService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2/product';

  Future<NutritionData?> fetchProductData(String barcode) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$barcode.json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1) {
          return NutritionData.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching product: $e');
      return null;
    }
  }

  Future<List<NutritionData>> fetchAlternatives(NutritionData product) async {
    if (product.categories.isEmpty) return [];
    
    // Use the most specific category (usually the last one in tags)
    final category = product.categories.last;
    final url = 'https://world.openfoodfacts.org/cgi/search.pl?'
        'action=process&'
        'tagtype_0=categories&'
        'tag_contains_0=contains&'
        'tag_0=$category&'
        'nutrition_grades=a,b&'
        'sort_by=unique_scans_n&'
        'page_size=5&'
        'json=true';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List products = data['products'] ?? [];
        return products.map((p) => NutritionData.fromJson({'product': p})).toList();
      }
    } catch (e) {
      print('Error fetching alternatives: $e');
    }
    return [];
  }

  ProductVerdict analyzeProduct(NutritionData product, UserProfile profile) {
    List<String> reasons = [];
    double riskScore = 0;

    double sugar100 = (product.nutrients['sugars_100g'] ?? 0).toDouble();
    double sodiumMg = 0.0;
    if (product.nutrients['sodium_100g'] != null) {
      sodiumMg = (product.nutrients['sodium_100g'] as num).toDouble() * 1000.0;
    } else if (product.nutrients['salt_100g'] != null) {
      sodiumMg = (product.nutrients['salt_100g'] as num).toDouble() / 2.5 * 1000.0;
    }
    double satFat100 = (product.nutrients['saturated-fat_100g'] ?? product.nutrients['saturated_fat_100g'] ?? 0).toDouble();
    double energyKcal100 = (product.nutrients['energy-kcal_100g'] ?? product.nutrients['energy_kcal_100g'] ?? 0).toDouble();
    double fiber100 = (product.nutrients['fiber_100g'] ?? 0).toDouble();

    // 1. Allergies
    bool hasAllergy = false;
    for (var allergy in profile.allergies) {
      if (product.ingredients.any((ing) => ing.toLowerCase().contains(allergy.toLowerCase()))) {
        reasons.add("Contains allergen: $allergy.");
        hasAllergy = true;
      }
    }

    // Base risks
    double sugarRisk = 0;
    if (sugar100 > 20) sugarRisk = 40;
    else if (sugar100 > 10) sugarRisk = 25;
    else if (sugar100 > 5) sugarRisk = 10;

    double sodiumRisk = 0;
    if (sodiumMg > 800) sodiumRisk = 40;
    else if (sodiumMg > 400) sodiumRisk = 25;
    else if (sodiumMg > 120) sodiumRisk = 10;

    double fatRisk = 0;
    if (satFat100 > 10) fatRisk = 20;
    else if (satFat100 > 5) fatRisk = 10;

    double calorieRisk = 0;
    if (energyKcal100 > 500) calorieRisk = 30; // High calorie density
    else if (energyKcal100 > 300) calorieRisk = 15;

    double additiveRisk = 0;
    final refinedSugars = ['high fructose corn syrup', 'glucose syrup', 'corn syrup solids', 'maltose', 'added sugar'];
    bool hasRefinedSugar = product.ingredients.any((ing) => refinedSugars.any((rs) => ing.toLowerCase().contains(rs)));
    if (hasRefinedSugar) additiveRisk += 15;

    final harmfulAdditives = ['artificial color', 'msg', 'aspartame', 'preservative', 'palm oil'];
    int additiveCount = product.ingredients.where((ing) => harmfulAdditives.any((ha) => ing.toLowerCase().contains(ha))).length;
    additiveRisk += additiveCount * 5.0;

    double fiberBonus = 0;
    if (fiber100 > 5) fiberBonus = 15;
    else if (fiber100 > 3) fiberBonus = 5;

    // Apply specific condition multipliers and reasons
    if (profile.hasDiabetes) {
      sugarRisk *= 1.5;
      if (hasRefinedSugar) {
        additiveRisk += 10;
        reasons.add("Contains refined sugars, increasing blood glucose spike risk.");
      }
      if (sugar100 > 10 || hasRefinedSugar) {
         reasons.add("High sugar content may not align with diabetes management.");
      }
    } else if (sugar100 > 20) {
      reasons.add("Very high sugar content (${sugar100.toStringAsFixed(1)}g/100g).");
    }

    if (profile.hasHypertension) {
      sodiumRisk *= 1.5;
      if (sodiumMg > 400) {
         reasons.add("High sodium levels may increase blood pressure risk.");
      }
      if (sodiumMg > 800 && (fatRisk > 0 || additiveRisk > 0)) {
         sodiumRisk += 15; // move toward AVOID when combined with fat/processed
      }
    } else if (sodiumMg > 800) {
      reasons.add("Very high sodium content (${sodiumMg.toStringAsFixed(0)}mg/100g).");
    }

    if (profile.hasPcos) {
      calorieRisk *= 1.5;
      sugarRisk = profile.hasDiabetes ? sugarRisk : (sugarRisk * 1.3); // moderately penalize if not already penalized by diabetes
      additiveRisk *= 1.5;
      if (energyKcal100 > 500 || sugar100 > 10 || hasRefinedSugar) {
         reasons.add("High calorie density and refined carbohydrates may worsen PCOS-related insulin resistance.");
      }
    } else if (energyKcal100 > 500) {
      reasons.add("High calorie density (${energyKcal100.toStringAsFixed(0)} kcal/100g).");
    }

    if (fiber100 > 3) {
      reasons.add("Fiber content (${fiber100.toStringAsFixed(1)}g) slows glucose absorption and improves digestion.");
    }

    // Diet types logic (e.g., Vegan)
    if (profile.dietType == "Vegan") {
      final animalProducts = ['milk', 'egg', 'honey', 'meat', 'beef', 'pork', 'gelatin', 'curd', 'ghee', 'fish'];
      for (var nonVegan in animalProducts) {
        if (product.ingredients.any((ing) => ing.contains(nonVegan))) {
          reasons.add("Non-Vegan: Contains $nonVegan.");
          hasAllergy = true; // Act as complete blocker
        }
      }
    }

    // Cumulative Risk Score
    riskScore = sugarRisk + sodiumRisk + fatRisk + calorieRisk + additiveRisk - fiberBonus;
    if (hasAllergy) riskScore += 100; // Immediate avoid

    riskScore = riskScore.clamp(0.0, 100.0);

    // Final Verdict matching exact boundaries
    Verdict finalVerdict;
    if (riskScore <= 25) {
      finalVerdict = Verdict.good;
      if (reasons.isEmpty || reasons.length == 1 && reasons.first.contains("Fiber")) {
        reasons.add("Generally suitable for your profile.");
      }
    } else if (riskScore <= 60) {
      finalVerdict = Verdict.caution;
    } else {
      finalVerdict = Verdict.avoid;
    }

    // Required disclaimer
    reasons.add("Guidance only. Not medical advice.");

    return ProductVerdict(verdict: finalVerdict, reasons: reasons.toSet().toList());
  }
}
