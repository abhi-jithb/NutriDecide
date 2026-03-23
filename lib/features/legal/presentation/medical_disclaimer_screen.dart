import 'package:flutter/material.dart';

class MedicalDisclaimerScreen extends StatelessWidget {
  const MedicalDisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Medical Disclaimer")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.medical_services_outlined, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            const Text(
              "NutriDecide is NOT a Medical Diagnostic Tool",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              """
The information provided by NutriDecide, including food analysis, suitability verdicts, and health-specific suggestions, is for informational and educational purposes only.

1. Not Medical Advice: This application does not provide medical diagnosis, treatment, or professional advice. 
2. Consult Your Doctor: Always consult with a qualified healthcare professional before making dietary changes, especially if you have chronic conditions like Diabetes, Hypertension, or PCOS.
3. Accuracy: While we strive for accuracy, nutritional data is sourced from global databases and may vary from actual products.
4. User Responsibility: The user assumes all risks for any decisions made based on the app's analysis.

By using this app, you acknowledge that NutriDecide is a guidance tool and not a substitute for professional medical care.
              """,
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text("I Understand and Accept"),
            ),
          ],
        ),
      ),
    );
  }
}
