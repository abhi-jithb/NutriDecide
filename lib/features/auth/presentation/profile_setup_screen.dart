import 'package:flutter/material.dart';
import '../../navigation/bottom_nav_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {

  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final targetWeightController = TextEditingController();

  String? selectedGender;
  String? selectedGoal;
  String? selectedActivity;
  String? selectedDiet;

  bool diabetes = false;
  bool hypertension = false;
  bool pcos = false;

  final List<String> allergies = [];
  final List<String> intolerances = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Health Profile")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text("Measurements",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              TextField(
                controller: heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Height (cm)"),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Weight (kg)"),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Gender"),
                items: ["Male", "Female", "Prefer not to say"]
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (value) => setState(() => selectedGender = value),
              ),

              const SizedBox(height: 24),

              const Text("Goals",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Goal"),
                items: ["Weight Loss", "Maintain", "Weight Gain"]
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (value) => setState(() => selectedGoal = value),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: targetWeightController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: "Target Weight (kg)"),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Activity Level"),
                items: [
                  "Sedentary",
                  "Lightly Active",
                  "Moderately Active",
                  "Very Active"
                ]
                    .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => selectedActivity = value),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Diet Type"),
                items: [
                  "No Restriction",
                  "Vegan",
                  "Vegetarian",
                  "Keto",
                  "Low-carb"
                ]
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (value) => setState(() => selectedDiet = value),
              ),

              const SizedBox(height: 24),

              const Text("Health Conditions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              CheckboxListTile(
                title: const Text("Diabetes"),
                value: diabetes,
                onChanged: (val) => setState(() => diabetes = val!),
              ),

              CheckboxListTile(
                title: const Text("Hypertension"),
                value: hypertension,
                onChanged: (val) => setState(() => hypertension = val!),
              ),

              CheckboxListTile(
                title: const Text("PCOS"),
                value: pcos,
                onChanged: (val) => setState(() => pcos = val!),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BottomNavScreen(),
                    ),
                  );
                },
                child: const Text("Finish Setup"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}