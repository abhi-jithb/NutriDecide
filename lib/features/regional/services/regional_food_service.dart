import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../scan/models/nutrition_data.dart';

class RegionalFoodService {
  // Using local IP to allow physical mobile devices to connect
  static const String _baseUrl = 'http://192.168.29.159:5000/api';

  Future<NutritionData?> searchFood(String query) async {
    print('Searching regional food for voice query: "$query"');
    
    // Common Kerala food spelling variants and phonetic mappings
    final Map<String, String> synonyms = {
      'idly': 'idli',
      'idlies': 'idli',
      'idles': 'idli',
      'idlee': 'idli',
      'porotta': 'parotta',
      'poratta': 'parotta',
      'porottta': 'parotta',
      'protta': 'parotta',
      'barotta': 'parotta',
      'paratha': 'parotta',
      'paroda': 'parotta',
      'appom': 'appam',
      'appa': 'appam',
      'appaas': 'appam',
      'wada': 'vada',
      'vada': 'vada',
      'upm': 'upma',
      'uma': 'upma',
      'uppum': 'upma',
      'poyotta': 'parotta',
      'fibreta': 'parotta',
      'porottta': 'parotta',
      'putu': 'puttu',
      'sombar': 'sambar',
      'curry': 'curry',
      'chicken curry': 'chicken curry',
      'fish curry': 'fish curry',
      'beef curry': 'beef fry',
      'beef fry': 'beef fry',
      'delhi': 'idli',
      'ideli': 'idli',
    };

    // Clean query (Convert 'with', '+', 'plus' into 'and')
    String cleaned = query.toLowerCase()
        .replaceAll(' with ', ' and ')
        .replaceAll(' + ', ' and ')
        .replaceAll(' plus ', ' and ')
        .trim();
    
    // Split by 'and' to handle combinations
    final parts = cleaned.split(RegExp(r'\s+and\s+')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) {
        parts.add(cleaned); // Fallback to entire query if split resulted in empty
    }

    print('Detected combination parts: $parts');
    
    List<NutritionData> combinedItems = [];
    List<double> portions = [];

    for (var part in parts) {
      double portion = estimatePortion(part);
      // Remove portion words from the string so the search engine only gets the food name
      String searchPart = part.replaceAll(RegExp(r'\b(\d+|one|two|three|four|five|six|seven|eight|nine|ten|half|of)\b', caseSensitive: false), '').trim();
      
      // If stripping left us with nothing, just use the original part
      if (searchPart.isEmpty) searchPart = part;

      NutritionData? partResult = await _searchSingleFood(searchPart, synonyms);
      if (partResult != null) {
        combinedItems.add(partResult);
        portions.add(portion);
      }
    }

    if (combinedItems.isEmpty) return null;

    if (combinedItems.length == 1) {
      return scaleFood(combinedItems.first, portions.first);
    } else {
      return combineFoods(combinedItems, portions);
    }
  }

  NutritionData scaleFood(NutritionData food, double portion) {
    if (portion == 1.0) return food;
    
    Map<String, dynamic> scaledNutrients = {};
    food.nutrients.forEach((key, value) {
      if (value is num) {
        scaledNutrients[key] = double.parse((value * portion).toStringAsFixed(2));
      } else {
        scaledNutrients[key] = value;
      }
    });

    String prefix = portion == portion.toInt() ? portion.toInt().toString() : portion.toStringAsFixed(1);
    
    return NutritionData(
      productName: '${prefix}x ${food.productName}',
      ingredients: food.ingredients,
      nutrients: scaledNutrients,
      categories: food.categories,
      imageUrl: food.imageUrl,
    );
  }

  NutritionData combineFoods(List<NutritionData> foods, List<double> portions) {
    String combinedName = '';
    List<String> combinedIngredients = [];
    Map<String, dynamic> combinedNutrients = {};
    List<String> combinedCategories = [];

    for (int i = 0; i < foods.length; i++) {
      final food = foods[i];
      final portion = portions[i];
      
      String prefix = portion == 1.0 ? "" : "${portion == portion.toInt() ? portion.toInt() : portion.toStringAsFixed(1)}x ";
      combinedName += '$prefix${food.productName}';
      if (i < foods.length - 1) combinedName += " + ";

      combinedIngredients.addAll(food.ingredients);
      combinedCategories.addAll(food.categories);

      food.nutrients.forEach((key, value) {
        if (value is num) {
          combinedNutrients[key] = (combinedNutrients[key] ?? 0.0) + (value * portion);
        } else if (!combinedNutrients.containsKey(key)) {
           combinedNutrients[key] = value;
        }
      });
    }

    // Format all aggregated values to 2 decimal places
    combinedNutrients.forEach((key, value) {
       if (value is num) {
         combinedNutrients[key] = double.parse(value.toStringAsFixed(2));
       }
    });

    return NutritionData(
      productName: combinedName,
      ingredients: combinedIngredients.toSet().toList(),
      nutrients: combinedNutrients,
      categories: combinedCategories.toSet().toList(),
      imageUrl: foods.first.imageUrl, // Inherit image from main component
    );
  }

  Future<NutritionData?> _searchSingleFood(String query, Map<String, String> synonyms) async {
    // Check if the whole query has a synonym (like 'beef curry' -> 'beef fry')
    final mappedQuery = synonyms[query] ?? query;
    
    // Final clean for individual food name
    String cleaned = mappedQuery.replaceAll('and', '').trim();
    
    // Split into words
    final words = cleaned.split(' ').where((w) => w.length >= 3).toList();
    
    print('Searching single food: "$cleaned" (mapped from "$query") (words: $words)');

    // 1. Try fetching potential matches from API
    List<NutritionData> apiResults = await _fetchFromApi(cleaned);
    if (apiResults.isNotEmpty) {
      // Use the best match logic on API results
      NutritionData? best = _findBestMatch(apiResults, words);
      if (best != null) return best;
    }

    // 2. Try each word and its variations
    for (var word in words) {
      // Check synonyms
      final lookup = synonyms[word] ?? word;
      
      // Try phonetic variants and spelling adjustments
      List<String> variants = [
        lookup,
        lookup.replaceAll('y', 'i'),
        lookup.replaceAll('ee', 'i'),
        lookup.replaceAll('o', 'a'),
        lookup.replaceAll('tt', 't'),
      ];

      if (lookup.endsWith('s')) {
        variants.add(lookup.substring(0, lookup.length - 1));
      }

      for (var variant in variants.toSet()) {
        List<NutritionData> variantResults = await _fetchFromApi(variant);
        if (variantResults.isNotEmpty) {
          NutritionData? best = _findBestMatch(variantResults, words);
          if (best != null) return best;
        }
      }
    }

    print('Fuzzy search failed for: "$query". Retrying with full product list...');
    
    // 3. Last Resort: Fetch ALL and match locally (Substring match on names)
    try {
      final allFoods = await _fetchAll();
      return _findBestMatch(allFoods, words);
    } catch (e) {
      print('Local fuzzy match failed: $e');
    }

    print('No regional food found for query: "$query"');
    return null;
  }

  NutritionData? _findBestMatch(List<NutritionData> candidates, List<String> queryWords) {
    NutritionData? bestMatch;
    int maxMatchedWords = 0;

    for (var food in candidates) {
      final name = food.productName.toLowerCase();
      int matchedWords = 0;
      
      for (var word in queryWords) {
        // Skip extremely generic words for fuzzy matching
        if (['curry', 'rice', 'fry', 'style', 'kerala'].contains(word)) continue;
        
        if (name.contains(word) || word.contains(name)) {
          matchedWords++;
        }
      }

      if (matchedWords > maxMatchedWords) {
        maxMatchedWords = matchedWords;
        bestMatch = food;
      }
    }
    
    if (bestMatch != null && maxMatchedWords > 0) {
      print('Best match found: ${bestMatch.productName} (Score: $maxMatchedWords)');
      return bestMatch;
    }
    return null;
  }

  Future<List<NutritionData>> _fetchAll() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/regional-food'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List results = json.decode(response.body);
        return results.map((data) => NutritionData(
          productName: data['name'],
          ingredients: List<String>.from(data['ingredients']),
          nutrients: Map<String, dynamic>.from(data['nutrients']),
          categories: List<String>.from(data['categories']),
          imageUrl: data['imageUrl'],
        )).toList();
      }
    } catch (e) {
      print('Error fetching all foods: $e');
    }
    return [];
  }

  Future<List<NutritionData>> _fetchFromApi(String q) async {
    if (q.isEmpty) return [];
    try {
      final encodedQuery = Uri.encodeComponent(q);
      final response = await http.get(
        Uri.parse('$_baseUrl/search?q=$encodedQuery'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List results = json.decode(response.body);
        return results.map((data) => NutritionData(
          productName: data['name'],
          ingredients: List<String>.from(data['ingredients']),
          nutrients: Map<String, dynamic>.from(data['nutrients']),
          categories: List<String>.from(data['categories']),
          imageUrl: data['imageUrl'],
        )).toList();
      }
    } catch (e) {
      print('Error searching regional food: $e');
    }
    return [];
  }

  // Voice estimation logic for portions
  double estimatePortion(String voiceText) {
    final regex = RegExp(r'\b(\d+|one|two|three|four|five|six|seven|eight|nine|ten|half|quarter)\b', caseSensitive: false);
    final match = regex.firstMatch(voiceText.toLowerCase());
    
    if (match != null) {
      final val = match.group(0);
      switch (val) {
        case 'half': return 0.5;
        case 'quarter': return 0.25;
        case 'one': return 1.0;
        case 'two': return 2.0;
        case 'three': return 3.0;
        case 'four': return 4.0;
        case 'five': return 5.0;
        case 'six': return 6.0;
        case 'seven': return 7.0;
        case 'eight': return 8.0;
        case 'nine': return 9.0;
        case 'ten': return 10.0;
        default:
          return double.tryParse(val!) ?? 1.0;
      }
    }
    return 1.0; // Default portion
  }
}
