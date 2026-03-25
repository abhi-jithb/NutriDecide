enum ConfidenceLevel { high, medium, low, none }

class NutritionData {
  final String productName;
  final String? brand;
  final String? imageUrl;
  final List<String> ingredients;
  final Map<String, dynamic> nutrients;
  final String? nutritionGrade;
  final List<String> categories;
  final ConfidenceLevel confidence;

  NutritionData({
    required this.productName,
    this.brand,
    this.imageUrl,
    required this.ingredients,
    required this.nutrients,
    this.nutritionGrade,
    this.categories = const [],
    this.confidence = ConfidenceLevel.high,
  });

  /// Standardizes data layout for local Hive persistence.
  Map<String, dynamic> toMap() {
    return {
      'product_name': productName,
      'brands': brand,
      'image_url': imageUrl,
      'ingredients_text': ingredients.join(', '),
      'nutriments': nutrients,
      'nutrition_grades': nutritionGrade,
      'categories_tags': categories,
      'confidence': confidence.name,
    };
  }

  /// Specialized factory for standardized local storage.
  factory NutritionData.fromLocalMap(Map<String, dynamic> map) {
    return NutritionData(
      productName: map['product_name'] ?? 'Unknown',
      brand: map['brands'],
      imageUrl: map['image_url'],
      ingredients: (map['ingredients_text'] ?? '').toString().split(',').map((e) => e.trim()).toList(),
      nutrients: Map<String, dynamic>.from(map['nutriments'] ?? {}),
      nutritionGrade: map['nutrition_grades'],
      categories: List<String>.from(map['categories_tags'] ?? []),
      confidence: _parseConfidence(map['confidence']),
    );
  }

  factory NutritionData.fromJson(Map<String, dynamic> json) {
    final product = json['product'] ?? {};
    final nutriments = product['nutriments'] ?? {};
    
    List<String> ingredientsList = [];
    if (product['ingredients'] != null && product['ingredients'] is List) {
      ingredientsList = (product['ingredients'] as List)
          .map((i) => (i['text']?.toString().toLowerCase() ?? '').replaceAll(RegExp(r'[*_]'), '').trim())
          .where((i) => i.isNotEmpty)
          .toList();
    } else if (product['ingredients_text'] != null) {
       ingredientsList = (product['ingredients_text'] as String)
          .replaceAll(RegExp(r'[*_]'), '')
          .split(',')
          .map((e) => e.trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    List<String> categoriesList = [];
    if (product['categories_tags'] != null) {
      categoriesList = List<String>.from(product['categories_tags'] as List);
    }

    // Phase 1: Data Availability Mapping
    final hasName = product['product_name'] != null && product['product_name'].toString().isNotEmpty;
    final hasIngredients = ingredientsList.isNotEmpty;
    final hasNutrients = nutriments.isNotEmpty && nutriments['energy-kcal_100g'] != null;
    final hasBrand = product['brands'] != null && product['brands'].toString().isNotEmpty;

    // Phase 2: Refined Confidence Calculation
    ConfidenceLevel calculatedConfidence = ConfidenceLevel.none;
    
    if (hasName && hasIngredients && hasNutrients && hasBrand) {
      calculatedConfidence = ConfidenceLevel.high;
    } else if (hasName && hasIngredients && hasNutrients) {
      calculatedConfidence = ConfidenceLevel.medium; // Missing Brand but has facts
    } else if (hasName && (hasIngredients || hasNutrients)) {
      calculatedConfidence = ConfidenceLevel.low; // Only one major data field
    } else {
      calculatedConfidence = ConfidenceLevel.none; // Insufficient for safe health verdict
    }

    return NutritionData(
      productName: product['product_name'] ?? 'Unknown Product',
      brand: product['brands'],
      imageUrl: product['image_url'],
      ingredients: ingredientsList,
      nutrients: nutriments,
      nutritionGrade: product['nutrition_grades'],
      categories: categoriesList,
      confidence: calculatedConfidence,
    );
  }

  static ConfidenceLevel _parseConfidence(String? value) {
    if (value == null) return ConfidenceLevel.high; // Default for local curated DB
    return ConfidenceLevel.values.firstWhere(
      (e) => e.name == value, 
      orElse: () => ConfidenceLevel.high
    );
  }

  /// Ensures we have enough data to generate a reliable health verdict.
  bool get isComplete => confidence != ConfidenceLevel.none && productName != 'Unknown Product';
}

enum Verdict { good, caution, avoid }

class ProductVerdict {
  final Verdict verdict;
  final List<String> reasons;
  final ConfidenceLevel confidence;

  ProductVerdict({
    required this.verdict, 
    required this.reasons, 
    this.confidence = ConfidenceLevel.high
  });
}
