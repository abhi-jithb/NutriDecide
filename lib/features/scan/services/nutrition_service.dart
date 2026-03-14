import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nutrition_data.dart';
import '../../profile/models/user_profile.dart';
import '../../../core/data/food_database_service.dart';
import 'ingredient_analyzer.dart';
import 'scoring_engine.dart';

class NutritionService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2/product';
  final FoodDatabaseService _dbService = FoodDatabaseService();

  Future<NutritionData?> fetchProductData(String barcode) async {
    // 1. Optimized local lookup (O(1))
    final localData = _dbService.getFoodByBarcode(barcode);
    if (localData != null) return localData;

    // 2. Async Fallback to API
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$barcode.json'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1) {
          return NutritionData.fromJson(data);
        }
      }
    } catch (e) {
      print('NutritionService: API fetch failed: $e');
    }
    return null;
  }

  Future<List<NutritionData>> fetchAlternatives(NutritionData product, UserProfile profile) async {
    if (product.productName.isEmpty) return [];

    // 1. Identify keywords for category/similarity
    final keywords = product.productName.split(' ')
        .where((word) => word.length > 3)
        .toList();

    List<NutritionData> candidates = [];
    if (keywords.isNotEmpty) {
      // Search local database for similar items
      candidates = _dbService.searchFoods(keywords.first, limit: 30);
    } else {
      candidates = _dbService.getAllFoods();
    }
    
    // 2. Filter and Rank by "Healthier" score for THIS user
    final List<MapEntry<NutritionData, double>> scoredCandidates = [];

    for (var candidate in candidates) {
      if (candidate.productName == product.productName) continue;

      final analysis = IngredientAnalyzer.analyze(candidate.ingredients);
      final score = ScoringEngine.calculateRiskScore(
        product: candidate, 
        profile: profile, 
        ingredientAnalysis: analysis,
      );
      scoredCandidates.add(MapEntry(candidate, score));
    }

    // Sort by risk score (lowest first)
    scoredCandidates.sort((a, b) => a.value.compareTo(b.value));

    return scoredCandidates
        .map((e) => e.key)
        .take(3)
        .toList();
  }

  ProductVerdict analyzeProduct(NutritionData product, UserProfile profile) {
    // 1. Run Ingredient Analysis
    final ingredientAnalysis = IngredientAnalyzer.analyze(product.ingredients);

    // 2. Calculate Risk Score via Scoring Engine
    final double riskScore = ScoringEngine.calculateRiskScore(
      product: product, 
      profile: profile, 
      ingredientAnalysis: ingredientAnalysis,
    );

    // 3. Generate Human-Readable Reasons
    final explanations = ScoringEngine.generateReasons(
      product: product, 
      profile: profile, 
      ingredientAnalysis: ingredientAnalysis, 
      riskScore: riskScore,
    );

    // 4. Map Score to Verdict
    Verdict finalVerdict;
    if (riskScore <= 25) {
      finalVerdict = Verdict.good;
    } else if (riskScore <= 60) {
      finalVerdict = Verdict.caution;
    } else {
      finalVerdict = Verdict.avoid;
    }

    return ProductVerdict(
      verdict: finalVerdict, 
      reasons: explanations,
    );
  }
}
