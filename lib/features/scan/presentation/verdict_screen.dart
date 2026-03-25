import 'package:flutter/material.dart';
import '../../profile/models/user_profile.dart';
import '../models/nutrition_data.dart';
import '../services/nutrition_service.dart';

class VerdictScreen extends StatelessWidget {
  final NutritionData product;
  final ProductVerdict verdict;
  final UserProfile profile;

  const VerdictScreen({
    super.key,
    required this.product,
    required this.verdict,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getVerdictColor();
    final icon = _getVerdictIcon();

    return Scaffold(
      appBar: AppBar(title: const Text("Analysis Result")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Product Info Card
            Card(
              color: Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          product.imageUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 80,
                              height: 80,
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => 
                            Icon(Icons.broken_image_outlined, size: 80, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                        ),
                      )
                    else
                      Icon(Icons.fastfood, size: 80, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.productName,
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          if (product.brand != null)
                            Text(
                              product.brand!,
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Verdict Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color, width: 2),
              ),
              child: Column(
                children: [
                  Icon(icon, color: color, size: 64),
                  const SizedBox(height: 12),
                  Text(
                    verdict.verdict.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Score Impact Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          verdict.verdict == Verdict.good ? Icons.add_circle : Icons.remove_circle,
                          color: color,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "SCORE IMPACT: ${verdict.verdict == Verdict.good ? '+5' : (verdict.verdict == Verdict.caution ? '-8' : '-20')}",
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  
                  if (verdict.confidence != ConfidenceLevel.high)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: verdict.confidence == ConfidenceLevel.medium 
                          ? Colors.amber.withOpacity(0.1) 
                          : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: verdict.confidence == ConfidenceLevel.medium 
                            ? Colors.amber 
                            : Colors.red,
                          width: 1
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.report_problem_outlined, 
                            color: verdict.confidence == ConfidenceLevel.medium 
                              ? Colors.amber 
                              : Colors.red,
                            size: 18
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              verdict.confidence == ConfidenceLevel.medium
                                ? "PARTIAL DATA: Nutrients estimated from generic brand database."
                                : "UNCERTAIN DATA: Minimum facts detected. Use with caution.",
                              style: TextStyle(
                                fontSize: 11, 
                                fontWeight: FontWeight.bold,
                                color: verdict.confidence == ConfidenceLevel.medium 
                                  ? Colors.amber 
                                  : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Text(
                    "Analysis Details",
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...verdict.reasons.map((reason) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.circle, size: 8, color: color),
                            const SizedBox(width: 8),
                            Expanded(child: Text(
                              reason,
                              style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                            )),
                          ],
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 24),
            
            // Ingredients Card
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(
                  "View Ingredients",
                  style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: product.ingredients.map((ingredient) {
                        return Chip(
                          label: Text(ingredient),
                          backgroundColor: color.withOpacity(0.05),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          side: BorderSide(color: color.withOpacity(0.2)),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // Better Alternatives
            if (verdict.verdict != Verdict.good)
              _BetterAlternativesSection(product: product, profile: profile),

            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Scan Another Product"),
            ),
          ],
        ),
      ),
    );
  }

  Color _getVerdictColor() {
    switch (verdict.verdict) {
      case Verdict.good:
        return Colors.green.shade600;
      case Verdict.caution:
        return Colors.orange.shade600;
      case Verdict.avoid:
        return Colors.red.shade600;
    }
  }

  IconData _getVerdictIcon() {
    switch (verdict.verdict) {
      case Verdict.good:
        return Icons.check_circle_rounded;
      case Verdict.caution:
        return Icons.warning_amber_rounded;
      case Verdict.avoid:
        return Icons.dangerous_rounded;
    }
  }
}

class _BetterAlternativesSection extends StatelessWidget {
  final NutritionData product;
  final UserProfile profile;

  const _BetterAlternativesSection({required this.product, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Better Alternatives",
          style: TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Based on your health profile, consider these instead:",
          style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6)),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<NutritionData>>(
          future: NutritionService().fetchAlternatives(product, profile),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text(
                "No alternatives found for this category.",
                style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5)),
              );
            }
            return SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final alt = snapshot.data![index];
                  return Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 16),
                    child: Card(
                      color: Theme.of(context).cardColor,
                      child: Column(
                        children: [
                          if (alt.imageUrl != null && alt.imageUrl!.isNotEmpty)
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                child: Image.network(
                                  alt.imageUrl!, 
                                  fit: BoxFit.cover, 
                                  width: double.infinity,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(child: CircularProgressIndicator(strokeWidth: 1));
                                  },
                                  errorBuilder: (context, error, stackTrace) => 
                                    const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                                ),
                              ),
                            )
                          else
                            const Expanded(child: Icon(Icons.image_not_supported)),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              alt.productName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12, 
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (alt.nutritionGrade != null)
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade600,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        alt.nutritionGrade!.toUpperCase(),
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: Icon(
                                    Icons.thumb_up_alt_outlined, 
                                    size: 16,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Upvoted ${alt.productName}! Added to Safety Swaps.")),
                                    );
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
