import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/nutrition_data.dart';
import '../../profile/models/user_profile.dart';
import '../../../core/data/food_database_service.dart';
import 'ingredient_analyzer.dart';
import 'scoring_engine.dart';

class NutritionService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2/product';
  final FoodDatabaseService _dbService = FoodDatabaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Hybrid data acquisition flow following defined architecture:
  /// 1. User-specific Custom Products (Firestore)
  /// 2. Global Products (Admin Approved Firestore)
  /// 3. Local Hive Database (Offline first, 20k foods)
  /// 4. Remote Open Food Facts API (Live fallback)
  Future<NutritionData?> fetchProductData(String barcode) async {
    final uid = _auth.currentUser?.uid;

    // Phase 1: User-specific custom products
    if (uid != null) {
      try {
        final customDoc = await _firestore
            .collection('users')
            .doc(uid)
            .collection('custom_products')
            .doc(barcode)
            .get();
            
        if (customDoc.exists) {
          debugPrint('✅ Found in Custom Products (Firestore)');
          return NutritionData.fromFirestore(customDoc.data()!);
        }
      } catch (e) {
        debugPrint('⚠️ Custom product check failed: $e');
      }
    }

    // Phase 2: Global admin-approved products
    try {
      final globalDoc = await _firestore
          .collection('global_products')
          .doc(barcode)
          .get();
          
      if (globalDoc.exists) {
        debugPrint('🌍 Found in Global Products (Firestore)');
        return NutritionData.fromFirestore(globalDoc.data()!);
      }
    } catch (e) {
      debugPrint('⚠️ Global product check failed: $e');
    }

    // Phase 3: Local Hive Lookup
    final localData = _dbService.getFoodByBarcode(barcode);
    if (localData != null) {
      debugPrint('📦 Found in Local Hive DB');
      return localData;
    }

    // Phase 4: Remote API Fallback
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$barcode.json'),
        headers: {'User-Agent': 'NutriDecide - Android - Version 1.0'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1) {
          final remoteData = NutritionData.fromJson(data);
          if (remoteData.isComplete) {
            await _dbService.saveFoodData(barcode, remoteData);
            return remoteData;
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ NutritionService: API fallback failed for $barcode: $e');
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
