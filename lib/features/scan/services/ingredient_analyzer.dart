import '../models/nutrition_data.dart';

class IngredientAnalysisResult {
  final List<String> warnings;
  final bool hasHarmfulAdditives;
  final bool hasArtificialSweeteners;
  final bool hasRefinedSugars;

  IngredientAnalysisResult({
    required this.warnings,
    this.hasHarmfulAdditives = false,
    this.hasArtificialSweeteners = false,
    this.hasRefinedSugars = false,
  });
}

class IngredientAnalyzer {
  static const Map<String, String> _harmfulAdditives = {
    'msg': 'Monosodium Glutamate',
    'aspartame': 'Aspartame (Artificial Sweetener)',
    'sucralose': 'Sucralose (Artificial Sweetener)',
    'e102': 'Tartrazine (E102)',
    'e110': 'Sunset Yellow (E110)',
    'e129': 'Allura Red (E129)',
    'high fructose corn syrup': 'High Fructose Corn Syrup (HFCS)',
    'hfcs': 'High Fructose Corn Syrup (HFCS)',
    'hydrogenated oil': 'Hydrogenated / Trans Fats',
    'palm oil': 'Palm Oil (High Saturated Fat)',
    'artificial flavor': 'Artificial Flavors',
    'artificial color': 'Artificial Colors',
  };

  static const List<String> _refinedSugars = [
    'high fructose corn syrup',
    'hfcs',
    'glucose syrup',
    'corn syrup solids',
    'maltose',
    'added sugar',
    'inverted sugar',
  ];

  static const List<String> _sweeteners = [
    'aspartame',
    'sucralose',
    'acesulfame k',
    'saccharin',
    'xylitol',
    'erythritol',
  ];

  /// Analyzes the ingredient list and returns identified warnings and flags.
  static IngredientAnalysisResult analyze(List<String> ingredients) {
    final List<String> warnings = [];
    bool harmfulFound = false;
    bool sweetenerFound = false;
    bool refinedFound = false;

    final lowerIngredients = ingredients.map((e) => e.toLowerCase()).toList();

    // Check for specific harmful additives
    _harmfulAdditives.forEach((key, label) {
      if (lowerIngredients.any((ing) => ing.contains(key))) {
        warnings.add('Detected: $label');
        harmfulFound = true;
      }
    });

    // Check for refined sugars
    if (lowerIngredients.any((ing) => _refinedSugars.any((rs) => ing.contains(rs)))) {
      refinedFound = true;
    }

    // Check for sweeteners
    if (lowerIngredients.any((ing) => _sweeteners.any((sw) => ing.contains(sw)))) {
      sweetenerFound = true;
    }

    return IngredientAnalysisResult(
      warnings: warnings.toSet().toList(), // Deduplicate
      hasHarmfulAdditives: harmfulFound,
      hasArtificialSweeteners: sweetenerFound,
      hasRefinedSugars: refinedFound,
    );
  }
}
