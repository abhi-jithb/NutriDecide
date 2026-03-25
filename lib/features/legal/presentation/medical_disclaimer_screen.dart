import 'package:flutter/material.dart';

class MedicalDisclaimerScreen extends StatelessWidget {
  final VoidCallback onAccept;
  const MedicalDisclaimerScreen({super.key, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            children: [
              const Icon(Icons.shield_outlined, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                "Important Medical Notice",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const Text(
                """
NutriDecide provides personalized food intelligence but is NOT a substitute for professional medical advice.

1. GUIDANCE ONLY: Verdicts (GOOD/AVOID) are based on nutritional datasets and may not account for individual medical nuances.
2. CONSULTATION: Always speak with a doctor before changing your diet, especially if you have chronic health conditions.
3. DATA LIMITATIONS: While optimized for Kerala regional data, nutrition estimates are for information only.
4. NO WARRANTY: We do not guarantee 100% accuracy of ingredients or nutritional values.

By continuing, you agree that you understand NutriDecide is a nutritional guidance companion and not a medical tool.
                """,
                style: TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: onAccept,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("I ACCEPT AND UNDERSTAND", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
