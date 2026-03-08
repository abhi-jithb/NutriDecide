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
    };

    // Clean query (Preserve 'and' for splitting)
    String cleaned = query.toLowerCase()
        .replaceAll(RegExp(r'\d+'), '')
        .replaceAll('one', '')
        .replaceAll('two', '')
        .replaceAll('three', '')
        .replaceAll('four', '')
        .replaceAll('five', '')
        .replaceAll('ten', '')
        .replaceAll('half', '')
        // .replaceAll('and', '') // REMOVED: Need this for splitting below
        .replaceAll('with', '')
        .trim();
    
    // 1. Try splitting by 'and' to handle combinations
    if (cleaned.contains(' and ')) {
      final parts = cleaned.split(' and ').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      print('Detected combination items: $parts');
      for (var part in parts) {
         NutritionData? partResult = await _searchSingleFood(part, synonyms);
         if (partResult != null) return partResult; 
      }
    }
    // Also try splitting by direct 'and' if spaces are missing or captured weirdly
    else if (cleaned.contains('and')) {
       final parts = cleaned.split('and').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
       for (var part in parts) {
         NutritionData? partResult = await _searchSingleFood(part, synonyms);
         if (partResult != null) return partResult; 
      }
    }

    return await _searchSingleFood(cleaned, synonyms);
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
    if (voiceText.contains('2') || voiceText.contains('two')) return 2.0;
    if (voiceText.contains('3') || voiceText.contains('three')) return 3.0;
    if (voiceText.contains('half') || voiceText.contains('1/2')) return 0.5;
    return 1.0; // Default portion
  }
}
