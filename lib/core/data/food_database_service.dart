import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../features/scan/models/nutrition_data.dart';

/// A production-ready service for managing the offline food database.
/// Provides O(1) barcode lookup and keyword-indexed name searching.
class FoodDatabaseService {
  static final FoodDatabaseService _instance = FoodDatabaseService._internal();
  factory FoodDatabaseService() => _instance;
  FoodDatabaseService._internal();

  final Map<String, NutritionData> _barcodeIndex = {};
  final Map<String, List<String>> _keywordIndex = {}; // Maps keyword -> list of barcodes
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Initializes the database by loading and indexing the offline JSON dataset.
  /// Uses [compute] to offload parsing to a background isolate for performance.
  Future<void> initializeDatabase() async {
    if (_isInitialized) return;

    try {
      final String jsonString = await rootBundle.loadString('assets/data/foods_clean.json');
      
      // Use a custom wrapper for compute
      final List<dynamic> data = await compute(_parseJson, jsonString);
      
      for (var item in data) {
        final code = item['code']?.toString();
        if (code == null || code.isEmpty) continue;

        final nutritionData = _parseLocalItem(item);
        _barcodeIndex[code] = nutritionData;

        // Index keywords for faster search
        final name = nutritionData.productName.toLowerCase();
        final words = name.split(RegExp(r'\s+')).where((w) => w.length > 2);
        for (var word in words) {
          _keywordIndex.putIfAbsent(word, () => []).add(code);
        }
      }

      _isInitialized = true;
      debugPrint('🚀 FoodDatabaseService: Indexed ${_barcodeIndex.length} items.');
    } catch (e) {
      debugPrint('❌ FoodDatabaseService Error: $e');
    }
  }

  /// O(1) lookup for a food item by its barcode.
  NutritionData? getFoodByBarcode(String barcode) {
    if (!_isInitialized) {
      debugPrint('⚠️ FoodDatabaseService not initialized. Call initializeDatabase() first.');
      return null;
    }
    return _barcodeIndex[barcode];
  }

  /// Searches for foods matching the query using the keyword index.
  List<NutritionData> searchFoods(String query, {int limit = 10}) {
    if (!_isInitialized) return [];

    final searchWords = query.toLowerCase().split(RegExp(r'\s+')).where((w) => w.length > 1);
    if (searchWords.isEmpty) return [];

    final Set<String> resultBarcodes = {};
    
    // Simple intersection/union strategy
    for (var word in searchWords) {
      // Direct keyword match
      if (_keywordIndex.containsKey(word)) {
        resultBarcodes.addAll(_keywordIndex[word]!);
      } else {
        // Fallback to partial match in keys if no direct match (slightly slower but still restricted)
        final partialMatches = _keywordIndex.keys.where((k) => k.contains(word));
        for (var match in partialMatches) {
          resultBarcodes.addAll(_keywordIndex[match]!);
        }
      }
      if (resultBarcodes.length >= limit * 2) break;
    }

    return resultBarcodes
        .map((code) => _barcodeIndex[code]!)
        .take(limit)
        .toList();
  }

  /// Provides all foods in the database (use with care for large datasets).
  List<NutritionData> getAllFoods() => _barcodeIndex.values.toList();

  NutritionData _parseLocalItem(Map<String, dynamic> item) {
    List<String> ingredientsList = [];
    if (item['ingredients'] != null && item['ingredients'].toString().isNotEmpty) {
      ingredientsList = item['ingredients']
          .toString()
          .split(',')
          .map((e) => e.trim().toLowerCase())
          .toList();
    }

    Map<String, dynamic> nutrients = {};
    if (item['sugar'] != null) nutrients['sugars_100g'] = _toDouble(item['sugar']);
    if (item['sodium'] != null) {
      double? sodiumMg = _toDouble(item['sodium']);
      if (sodiumMg != null) nutrients['sodium_100g'] = sodiumMg / 1000.0;
    }
    if (item['saturatedFat'] != null) nutrients['saturated-fat_100g'] = _toDouble(item['saturatedFat']);
    if (item['calories'] != null) nutrients['energy-kcal_100g'] = _toDouble(item['calories']);
    if (item['fiber'] != null) nutrients['fiber_100g'] = _toDouble(item['fiber']);
    if (item['protein'] != null) nutrients['protein_100g'] = _toDouble(item['protein']);

    return NutritionData(
      productName: item['name']?.toString() ?? 'Unknown Product',
      ingredients: ingredientsList,
      nutrients: nutrients,
      categories: item['categories'] is List 
          ? List<String>.from(item['categories']) 
          : (item['category'] != null ? [item['category'].toString()] : []),
    );
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

// Top-level function for compute
List<dynamic> _parseJson(String text) {
  return jsonDecode(text) as List<dynamic>;
}
