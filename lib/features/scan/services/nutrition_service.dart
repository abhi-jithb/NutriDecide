import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/nutrition_data.dart';
import '../../profile/models/user_profile.dart';
import '../../../core/data/food_database_service.dart';
import 'ingredient_analyzer.dart';
import 'scoring_engine.dart';

class NutritionService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2/product';
  final FoodDatabaseService _dbService = FoodDatabaseService();

  /// Hybrid data acquisition flow: 
  /// 1. Local Hive Database (Offline first, 20k foods)
  /// 2. Remote Open Food Facts API (Live fallback)
  /// 3. Persistence (Cache API results back to Hive for subsequent offline use)
  Future<NutritionData?> fetchProductData(String barcode) async {
    // Phase 1: Local Optimized Lookup (O(1))
    // This now checks both Memory and Hive Persistent store
    final localData = _dbService.getFoodByBarcode(barcode);
    if (localData != null) return localData;

    // Phase 2: Async Fallback to Cloud (Open Food Facts)
    // We only reach this if the barcode isn't in our curated 20k dataset
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$barcode.json'))
          .timeout(const Duration(seconds: 4)); // Strict timeout for UX

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1) {
          final remoteData = NutritionData.fromJson(data);
          
          // Phase 3: Validation & Caching
          // Only cache and return if the product has sufficient data for analysis
          if (remoteData.isComplete) {
            await _dbService.saveFoodData(barcode, remoteData);
            return remoteData;
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ NutritionService: API fallback failed for $barcode: $e');
      // Graceful failure - returns null which triggers "No data available" UI
    }

    return null;
  }

  /// Finds healthier alternatives for Indian products based on CATEGORY mapping.
  Future<List<NutritionData>> fetchAlternatives(NutritionData product, UserProfile profile) async {
    if (product.productName.isEmpty) return [];

    // 1. Identify category-based candidates
    // We prioritize local dataset foods in the same category tags
    // 1. Identify category-based candidates
    // We prioritize local dataset foods in the same category tags
    final candidates = <NutritionData>[];
    
    // First try: Category-based search (most accurate)
    if (product.categories.isNotEmpty) {
      final category = product.categories.first;
      candidates.addAll(_dbService.searchFoods(category, limit: 15));
    }

    // Second try: Keyword fallback if category search yielded few results
    if (candidates.length < 5) {
      final keyword = product.productName.split(' ').first;
      final keywordResults = _dbService.searchFoods(keyword, limit: 15);
      
      // Merge unique results
      for (var res in keywordResults) {
        if (!candidates.any((c) => c.productName == res.productName)) {
          candidates.add(res);
        }
      }
    }
    
    // 2. Filter and Rank by personalized risk score
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

    // Sort: Lowest risk (best) first
    scoredCandidates.sort((a, b) => a.value.compareTo(b.value));

    return scoredCandidates
        .map((e) => e.key)
        .take(3)
        .toList();
  }

  /// Core logic to map complex food data to a simple, actionable verdict.
  ProductVerdict analyzeProduct(NutritionData product, UserProfile profile) {
    _logScan(product);

    // ⛔ Phase 1: Fail-Safe Guard (Task 1 & 2: NONE)
    if (product.confidence == ConfidenceLevel.none || !product.isComplete) {
      return ProductVerdict(
        verdict: Verdict.avoid, 
        confidence: ConfidenceLevel.none,
        reasons: ["No reliable data found for this product.", "Safety cannot be verified."],
      );
    }

    // 🛡️ Phase 2: Extreme Caution (Task 1 & 2: LOW)
    if (product.confidence == ConfidenceLevel.low) {
      return ProductVerdict(
        verdict: Verdict.avoid, 
        confidence: ConfidenceLevel.low,
        reasons: [
          "Very limited data detected.",
          "Health analysis is restricted for this product.",
          "Review the label for allergens and sugar."
        ],
      );
    }

    final ingredientAnalysis = IngredientAnalyzer.analyze(product.ingredients);
    final double riskScore = ScoringEngine.calculateRiskScore(
      product: product, 
      profile: profile, 
      ingredientAnalysis: ingredientAnalysis,
    );

    final explanations = ScoringEngine.generateReasons(
      product: product, 
      profile: profile, 
      ingredientAnalysis: ingredientAnalysis, 
      riskScore: riskScore,
    );

    Verdict finalVerdict;
    if (riskScore <= 25) {
      finalVerdict = Verdict.good;
    } else if (riskScore <= 60) {
      finalVerdict = Verdict.caution;
    } else {
      finalVerdict = Verdict.avoid;
    }

    // ⚖️ Phase 3: Weighting Correction (Task 2: MEDIUM)
    // If data is suspect but partial, we NEVER give a "GOOD" verdict
    if (product.confidence == ConfidenceLevel.medium && finalVerdict == Verdict.good) {
      finalVerdict = Verdict.caution;
      if (!explanations.any((e) => e.contains("Some data is missing"))) {
        explanations.insert(0, "Some data is missing. Verdict is conservative.");
      }
    }

    return ProductVerdict(
      verdict: finalVerdict, 
      reasons: explanations,
      confidence: product.confidence,
    );
  }

  void _logScan(NutritionData product) {
    debugPrint('🔎 SCAN_LOG: [${product.productName}] [${product.confidence.name.toUpperCase()}]');
  }
}
