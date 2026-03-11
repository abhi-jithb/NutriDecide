import 'dart:convert';
import 'package:flutter/services.dart';
import '../../features/scan/models/nutrition_data.dart';

class FoodDatabase {
  static final FoodDatabase _instance = FoodDatabase._internal();
  factory FoodDatabase() => _instance;
  FoodDatabase._internal();

  Map<String, NutritionData> _foodMap = {};

  Future<void> loadFoods() async {
    try {
      final String response = await rootBundle.loadString('assets/data/foods_clean.json');
      final List<dynamic> data = json.decode(response);
      
      for (var item in data) {
        final code = item['code'] as String?;
        if (code != null) {
          _foodMap[code] = _parseLocalItem(item);
        }
      }
      print('Offline database loaded with ${_foodMap.length} items.');
    } catch (e) {
      print('Error loading offline food database: $e');
    }
  }

  NutritionData? findFoodByBarcode(String barcode) {
    return _foodMap[barcode];
  }

  List<NutritionData> searchByName(String query) {
     final loweredQuery = query.toLowerCase();
     return _foodMap.values.where((food) => food.productName.toLowerCase().contains(loweredQuery)).take(10).toList();
  }

  NutritionData _parseLocalItem(Map<String, dynamic> item) {
    List<String> ingredientsList = [];
    if (item['ingredients'] != null && item['ingredients'].toString().isNotEmpty) {
      ingredientsList = item['ingredients'].toString().split(',').map((e) => e.trim().toLowerCase()).toList();
    }

    Map<String, dynamic> nutrients = {};
    if (item['sugar'] != null && item['sugar'].toString().isNotEmpty) {
      nutrients['sugars_100g'] = double.tryParse(item['sugar'].toString());
    }
    if (item['sodium'] != null && item['sodium'].toString().isNotEmpty) {
      double? sodiumMg = double.tryParse(item['sodium'].toString());
      if (sodiumMg != null) nutrients['sodium_100g'] = sodiumMg / 1000.0;
    }
    if (item['saturatedFat'] != null && item['saturatedFat'].toString().isNotEmpty) {
      nutrients['saturated-fat_100g'] = double.tryParse(item['saturatedFat'].toString());
    }
    if (item['calories'] != null && item['calories'].toString().isNotEmpty) {
      nutrients['energy-kcal_100g'] = double.tryParse(item['calories'].toString());
    }
    if (item['fiber'] != null && item['fiber'].toString().isNotEmpty) {
      nutrients['fiber_100g'] = double.tryParse(item['fiber'].toString());
    }

    return NutritionData(
      productName: item['name']?.toString() ?? 'Unknown Product',
      ingredients: ingredientsList,
      nutrients: nutrients,
      categories: [],
    );
  }
}
