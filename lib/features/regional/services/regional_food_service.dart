import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../scan/models/nutrition_data.dart';

class RegionalFoodService {
  static const String _baseUrl = 'http://localhost:5000/api';

  Future<NutritionData?> searchFood(String query) async {
    final q = query.toLowerCase();
    
    try {
      final response = await http.get(Uri.parse('$_baseUrl/search?q=$q'));
      if (response.statusCode == 200) {
        final List results = json.decode(response.body);
        if (results.isNotEmpty) {
          final data = results.first;
          return NutritionData(
            productName: data['name'],
            ingredients: List<String>.from(data['ingredients']),
            nutrients: data['nutrients'],
            categories: List<String>.from(data['categories']),
            imageUrl: data['imageUrl'],
          );
        }
      }
    } catch (e) {
      print('Error searching regional food: $e');
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
