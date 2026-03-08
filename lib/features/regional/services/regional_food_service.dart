import '../../scan/models/nutrition_data.dart';

class RegionalFoodService {
  // Mock database for Kerala/Indian Street Food
  final Map<String, Map<String, dynamic>> _mockDb = {
    'puttu': {
      'name': 'Puttu (Steamed Rice Cake)',
      'nutrients': {'sugars_100g': 0.5, 'sodium_100g': 0.1, 'protein_100g': 8.0, 'carbs_100g': 45.0},
      'ingredients': ['rice flour', 'grated coconut', 'water', 'salt'],
      'categories': ['kerala_breakfast', 'steamed_food'],
      'imageUrl': 'https://images.unsplash.com/photo-1626132647523-66f5bf380027?q=80&w=300&auto=format&fit=crop',
    },
    'appam': {
      'name': 'Appam',
      'nutrients': {'sugars_100g': 1.2, 'sodium_100g': 0.15, 'protein_100g': 4.0, 'carbs_100g': 38.0},
      'ingredients': ['rice', 'coconut milk', 'yeast', 'sugar', 'salt'],
      'categories': ['kerala_breakfast', 'fermented_food'],
      'imageUrl': 'https://images.unsplash.com/photo-1630406144797-021c1801038f?q=80&w=300&auto=format&fit=crop',
    },
    'parotta': {
      'name': 'Malabar Parotta',
      'nutrients': {'sugars_100g': 2.0, 'sodium_100g': 0.8, 'protein_100g': 7.0, 'carbs_100g': 55.0},
      'ingredients': ['maida (refined flour)', 'oil', 'water', 'salt', 'sugar'],
      'categories': ['kerala_bread', 'high_carb'],
      'imageUrl': 'https://images.unsplash.com/photo-1632742051515-585a2665dd35?q=80&w=300&auto=format&fit=crop',
    },
    'fish curry': {
      'name': 'Kerala Fish Curry',
      'nutrients': {'sugars_100g': 1.0, 'sodium_100g': 0.9, 'protein_100g': 18.0, 'carbs_100g': 5.0},
      'ingredients': ['fish', 'coconut oil', 'chili powder', 'turmeric', 'tamarind', 'salt', 'coconut'],
      'categories': ['kerala_curry', 'high_protein'],
      'imageUrl': 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?q=80&w=300&auto=format&fit=crop',
    },
    'sadhya': {
      'name': 'Kerala Sadhya',
      'nutrients': {'sugars_100g': 4.5, 'sodium_100g': 1.2, 'protein_100g': 12.0, 'carbs_100g': 70.0},
      'ingredients': ['rice', 'sambar', 'avial', 'thoran', 'papad', 'payasam', 'banana'],
      'categories': ['kerala_feast', 'festival_food'],
      'imageUrl': 'https://images.unsplash.com/photo-1610192244261-3f33de3f55e4?q=80&w=300&auto=format&fit=crop',
    },
  };

  NutritionData? searchFood(String query) {
    final q = query.toLowerCase();
    
    // Simple substring match
    for (var key in _mockDb.keys) {
      if (q.contains(key)) {
        final data = _mockDb[key]!;
        return NutritionData(
          productName: data['name'],
          ingredients: List<String>.from(data['ingredients']),
          nutrients: data['nutrients'],
          categories: List<String>.from(data['categories']),
          imageUrl: data['imageUrl'],
        );
      }
    }
    return null;
  }

  // Voice estimation logic for portions
  double estimatePortion(String voiceText) {
    if (voiceText.contains('2') || voiceText.contains('two')) return 2.0;
    if (voiceText.contains('3') || voiceText.contains('three')) return 3.0;
    if (voiceText.contains('half') || voiceText.contains('1/2')) return 0.5;
    return 1.0; // Default portion
  }
}
