class NutritionData {
  final String productName;
  final String? brand;
  final String? imageUrl;
  final List<String> ingredients;
  final Map<String, dynamic> nutrients;
  final String? nutritionGrade;
  final List<String> categories;

  NutritionData({
    required this.productName,
    this.brand,
    this.imageUrl,
    required this.ingredients,
    required this.nutrients,
    this.nutritionGrade,
    this.categories = const [],
  });

  factory NutritionData.fromJson(Map<String, dynamic> json) {
    final product = json['product'] ?? {};
    final nutriments = product['nutriments'] ?? {};
    
    // Extract ingredients as a list of names
    List<String> ingredientsList = [];
    if (product['ingredients'] != null) {
      ingredientsList = (product['ingredients'] as List)
          .map((i) => (i['text'] as String).toLowerCase())
          .toList();
    } else if (product['ingredients_text'] != null) {
       ingredientsList = (product['ingredients_text'] as String)
          .split(',')
          .map((e) => e.trim().toLowerCase())
          .toList();
    }

    // Extract categories
    List<String> categoriesList = [];
    if (product['categories_tags'] != null) {
      categoriesList = (product['categories_tags'] as List).cast<String>();
    }

    return NutritionData(
      productName: product['product_name'] ?? 'Unknown Product',
      brand: product['brands'],
      imageUrl: product['image_url'],
      ingredients: ingredientsList,
      nutrients: nutriments,
      nutritionGrade: product['nutrition_grades'],
      categories: categoriesList,
    );
  }
}

enum Verdict { good, caution, avoid }

class ProductVerdict {
  final Verdict verdict;
  final List<String> reasons;

  ProductVerdict({required this.verdict, required this.reasons});
}
