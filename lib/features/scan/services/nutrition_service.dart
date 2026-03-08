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
      if (sugar > 8) {
        reasons.add("High sugar detected ($sugar g). Stricter limit applied for your Diabetes profile.");
        avoidPoints += 7;
      } else if (sugar > 3) {
        reasons.add("Contains moderate sugar ($sugar g). Monitor your glucose levels.");
        cautionPoints += 3;
      }
    }

    // 3. Check Hypertension (High Sodium)
    if (profile.hasHypertension) {
      final sodium = product.nutrients['sodium_100g'] ?? 0;
      final salt = product.nutrients['salt_100g'] ?? (sodium * 2.5);
      if (salt > 1.2) {
        reasons.add("High salt content (${salt.toStringAsFixed(1)}g). Dangerous for hypertension.");
        avoidPoints += 7;
      } else if (salt > 0.5) {
        reasons.add("Moderate salt detected. Use with caution.");
        cautionPoints += 3;
      }
    }

    // 4. Check PCOS (Glycemic Load & Inflammation)
    if (profile.hasPcos) {
      final sugar = product.nutrients['sugars_100g'] ?? 0;
      final highGiIngredients = ['maida', 'refined flour', 'maltodextrin', 'dextrose', 'corn syrup', 'tapioca starch'];
      final inflammatoryOils = ['palm oil', 'vegetable oil', 'sunflower oil', 'soybean oil'];
      
      bool hasHighGi = product.ingredients.any((ing) => highGiIngredients.any((gi) => ing.toLowerCase().contains(gi)));
      bool hasInflammatoryOil = product.ingredients.any((ing) => inflammatoryOils.any((oil) => ing.toLowerCase().contains(oil)));

      if (sugar > 10 || (hasHighGi && sugar > 5)) {
        reasons.add("High Glycemic Load: High sugar/refined carbs can trigger insulin resistance in PCOS.");
        avoidPoints += 5;
      } else if (hasHighGi || hasInflammatoryOil) {
        reasons.add("Contains refined carbs or inflammatory oils: May aggravate PCOS symptoms.");
        cautionPoints += 4;
      }
    }

    // 5. Check Diet Types (e.g., Vegan)
    if (profile.dietType == "Vegan") {
      final animalProducts = ['milk', 'egg', 'honey', 'meat', 'beef', 'pork', 'gelatin', 'curd', 'ghee', 'fish'];
      for (var nonVegan in animalProducts) {
        if (product.ingredients.any((ing) => ing.contains(nonVegan))) {
          reasons.add("Non-Vegan: Contains $nonVegan");
          avoidPoints += 10;
        }
      }
    }

    // 6. Ultra-Processed Additives & Fillers
    final harmfulAdditives = {
      'high fructose corn syrup': 'Highly processed sweetener',
      'palm oil': 'High in saturated fats',
      'artificial color': 'Synthetic additive',
      'msg': 'Flavor enhancer',
      'aspartame': 'Artificial sweetener',
      'preservative': 'Chemical stabilizer',
    };

    for (var entry in harmfulAdditives.entries) {
      if (product.ingredients.any((ing) => ing.toLowerCase().contains(entry.key))) {
        reasons.add("Refined Additive: ${entry.key}");
        cautionPoints += 2;
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
