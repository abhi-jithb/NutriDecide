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

  ProductVerdict analyzeProduct(NutritionData product, UserProfile profile) {
    List<String> reasons = [];
    int cautionPoints = 0;
    int avoidPoints = 0;

    // 1. Check Allergies
    for (var allergy in profile.allergies) {
      if (product.ingredients.any((ing) => ing.contains(allergy.toLowerCase()))) {
        reasons.add("Contains your allergen: $allergy");
        avoidPoints += 10;
      }
    }

    // 2. Check Diabetes (High Sugar)
    if (profile.hasDiabetes) {
      final sugar = product.nutrients['sugars_100g'] ?? 0;
      if (sugar > 10) {
        reasons.add("High sugar content ($sugar g/100g) - Risky for diabetes");
        avoidPoints += 5;
      } else if (sugar > 5) {
        reasons.add("Moderate sugar content ($sugar g/100g)");
        cautionPoints += 2;
      }
    }

    // 3. Check Hypertension (High Sodium)
    if (profile.hasHypertension) {
      final sodium = product.nutrients['sodium_100g'] ?? 0;
      if (sodium > 0.6) {
        reasons.add("High sodium ($sodium g/100g) - Risky for hypertension");
        avoidPoints += 5;
      } else if (sodium > 0.3) {
        reasons.add("Moderate sodium ($sodium g/100g)");
        cautionPoints += 2;
      }
    }

    // 4. Check Diet Types (e.g., Vegan)
    if (profile.dietType == "Vegan") {
      final animalProducts = ['milk', 'egg', 'honey', 'meat', 'beef', 'pork', 'gelatin'];
      for (var nonVegan in animalProducts) {
        if (product.ingredients.any((ing) => ing.contains(nonVegan))) {
          reasons.add("Contains animal-derived ingredient: $nonVegan");
          avoidPoints += 10;
        }
      }
    }

    // 5. Ultra-Processed Additives
    final harmfulAdditives = {
      'high fructose corn syrup': 'Highly processed sweetener linked to obesity',
      'palm oil': 'High in saturated fats and environmental impact',
      'artificial color': 'May have behavioral effects in children',
      'monosodium glutamate': 'Additive that may cause sensitivity',
      'aspartame': 'Artificial sweetener linked to gut issues',
    };

    for (var entry in harmfulAdditives.entries) {
      if (product.ingredients.any((ing) => ing.contains(entry.key))) {
        reasons.add("Contains ${entry.key}: ${entry.value}");
        cautionPoints += 1;
      }
    }
    if (avoidPoints > 0) {
      return ProductVerdict(verdict: Verdict.avoid, reasons: reasons);
    } else if (cautionPoints > 0) {
      return ProductVerdict(verdict: Verdict.caution, reasons: reasons);
    } else {
      reasons.add("Matches your health profile perfectly!");
      return ProductVerdict(verdict: Verdict.good, reasons: reasons);
    }
  }
}
