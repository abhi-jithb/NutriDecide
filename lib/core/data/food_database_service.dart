import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/scan/models/nutrition_data.dart';

/// Production-ready Hive-based Food Database Service.
/// This replaces the memory-heavy JSON Map with a persistent, low-latency Hive index.
/// 20k foods are stored as indexed binary data, ensuring O(1) barcode lookup without high RAM usage.
class FoodDatabaseService {
  static final FoodDatabaseService _instance = FoodDatabaseService._internal();
  factory FoodDatabaseService() => _instance;
  FoodDatabaseService._internal();

  static const String _foodBoxName = 'food_db_box';
  static const String _metadataBoxName = 'db_metadata_box';
  static const String _dbVersionKey = 'db_v1_imported';

  bool _isInitialized = false;
  late Box _foodBox;
  late Box _metadataBox;

  // Optimized memory cache (LRU-lite)
  final Map<String, NutritionData> _memoryCache = {};
  final List<String> _cacheKeys = [];
  static const int _maxCacheSize = 100;

  bool get isInitialized => _isInitialized;

  /// Initializes Hive and handles the one-time high-speed import of the 20k food dataset.
  Future<void> initializeDatabase() async {
    if (_isInitialized) return;

    try {
      await Hive.initFlutter();
      _foodBox = await Hive.openBox(_foodBoxName);
      _metadataBox = await Hive.openBox(_metadataBoxName);

      final isImported = _metadataBox.get(_dbVersionKey, defaultValue: false);
      if (!isImported || _foodBox.isEmpty) {
        await _performInitialImport();
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('❌ FoodDatabaseService Init Error: $e');
    }
  }

  Future<void> saveFoodData(String barcode, NutritionData data) async {
    if (!_isInitialized) await initializeDatabase();
    
    _addToCache(barcode, data);
    await _foodBox.put(barcode, data.toMap()); // Update disk
  }

  void _addToCache(String key, NutritionData value) {
    if (_memoryCache.length >= _maxCacheSize) {
      final oldestKey = _cacheKeys.removeAt(0);
      _memoryCache.remove(oldestKey);
    }
    _memoryCache[key] = value;
    _cacheKeys.add(key);
  }

  Future<void> _performInitialImport() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/foods_clean.json');
      final List<dynamic> rawData = await compute(_parseJsonIsolate, jsonString);
      
      final Map<String, dynamic> hiveMap = {};
      for (var item in rawData) {
        final code = item['code']?.toString();
        if (code != null && code.isNotEmpty) {
          hiveMap[code] = item;
        }
      }

      await _foodBox.putAll(hiveMap);
      await _metadataBox.put(_dbVersionKey, true);
    } catch (e) {
      debugPrint('❌ FoodDatabaseService Import Error: $e');
    }
  }

  /// Hybrid lookup: Memory -> Hive -> null
  NutritionData? getFoodByBarcode(String barcode) {
    if (_memoryCache.containsKey(barcode)) {
      _cacheKeys.remove(barcode);
      _cacheKeys.add(barcode);
      return _memoryCache[barcode];
    }
    
    if (!_isInitialized || _foodBox.isEmpty) return null;
    
    final rawItem = _foodBox.get(barcode);
    if (rawItem == null) return null;

    final Map<String, dynamic> itemMap = Map<String, dynamic>.from(rawItem);
    final data = NutritionData.fromLocalMap(itemMap);
    
    _addToCache(barcode, data);
    return data;
  }

  /// Keyword search using Hive iteration (limited for performance).
  /// In a full production environment, this would be replaced by an indexed MeiliSearch/Postgres.
  List<NutritionData> searchFoods(String query, {int limit = 10}) {
    if (!_isInitialized || _foodBox.isEmpty) return [];

    final q = query.toLowerCase();
    final List<NutritionData> matches = [];

    // Hive iteration for simple name matching
    for (var value in _foodBox.values) {
      final name = (value['name'] ?? '').toString().toLowerCase();
      if (name.contains(q)) {
        matches.add(_parseLocalItem(Map<String, dynamic>.from(value)));
      }
      if (matches.length >= limit) break;
    }

    return matches;
  }

  List<NutritionData> getAllFoods() {
    return _foodBox.values
        .take(50) // Capped for performance safety
        .map((e) => _parseLocalItem(Map<String, dynamic>.from(e)))
        .toList();
  }

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

/// Isolate-safe JSON parsing for high-volume datasets.
List<dynamic> _parseJsonIsolate(String source) {
  return json.decode(source) as List<dynamic>;
}
