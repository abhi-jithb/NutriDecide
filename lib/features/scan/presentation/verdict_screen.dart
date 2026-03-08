import 'package:flutter/material.dart';
import '../../profile/models/user_profile.dart';
import '../models/nutrition_data.dart';
import '../services/nutrition_service.dart';

class VerdictScreen extends StatelessWidget {
  final NutritionData product;
  final ProductVerdict verdict;

  const VerdictScreen({
    super.key,
    required this.product,
    required this.verdict,
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    if (product.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          product.imageUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      const Icon(Icons.fastfood, size: 80, color: Colors.grey),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.productName,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          if (product.brand != null)
                            Text(product.brand!,
                                style: const TextStyle(color: Colors.grey)),
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
                  const SizedBox(height: 16),
                  const Text(
                    "Analysis Details",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ...verdict.reasons.map((reason) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.circle, size: 8, color: color),
                            const SizedBox(width: 8),
                            Expanded(child: Text(reason)),
                          ],
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 24),
            
            // Ingredients Card
            ExpansionTile(
              title: const Text("View Ingredients"),
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
                        labelStyle: const TextStyle(fontSize: 12),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),

            // Better Alternatives (Phase 4a: Swap Engine)
            if (verdict.verdict != Verdict.good)
              _BetterAlternativesSection(product: product),

            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
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
        return Colors.green;
      case Verdict.caution:
        return Colors.orange;
      case Verdict.avoid:
        return Colors.red;
    }
  }

  IconData _getVerdictIcon() {
    switch (verdict.verdict) {
      case Verdict.good:
        return Icons.check_circle;
      case Verdict.caution:
        return Icons.warning_amber_rounded;
      case Verdict.avoid:
        return Icons.dangerous;
    }
  }
}

class _BetterAlternativesSection extends StatelessWidget {
  final NutritionData product;

  const _BetterAlternativesSection({required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Better Alternatives",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "Based on your health profile, consider these instead:",
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<NutritionData>>(
          future: NutritionService().fetchAlternatives(product),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text("No alternatives found for this category.");
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
                      child: Column(
                        children: [
                          if (alt.imageUrl != null)
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                child: Image.network(alt.imageUrl!, fit: BoxFit.cover, width: double.infinity),
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
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (alt.nutritionGrade != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    alt.nutritionGrade!.toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.thumb_up_alt_outlined, size: 16),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Upvoted ${alt.productName}! Added to Safety Swaps.")),
                                  );
                                },
                              ),
                            ],
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
