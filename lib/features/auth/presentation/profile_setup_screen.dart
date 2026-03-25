import 'package:flutter/material.dart';
import '../../navigation/bottom_nav_screen.dart';
import '../../profile/models/user_profile.dart';
import '../../profile/data/profile_repository.dart';

class ProfileSetupScreen extends StatefulWidget {
  final UserProfile? existingProfile;
  final String uid;

  const ProfileSetupScreen({
    super.key, 
    required this.uid,
    this.existingProfile,
  });

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {

  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final targetWeightController = TextEditingController();
  final allergiesController = TextEditingController();

  String? selectedGender;
  String? selectedGoal;
  String? selectedActivity;
  String? selectedDiet;

  bool diabetes = false;
  bool hypertension = false;
  bool pcos = false;
  bool _isLoading = false;

  final List<String> selectedConditions = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingProfile != null) {
      final p = widget.existingProfile!;
      ageController.text = p.age.toString();
      heightController.text = p.height.toString();
      weightController.text = p.weight.toString();
      targetWeightController.text = p.targetWeight.toString();
      selectedGender = p.gender;
      selectedGoal = p.goal;
      selectedActivity = p.activityLevel;
      selectedDiet = p.dietType;
      diabetes = p.hasDiabetes;
      hypertension = p.hasHypertension;
      pcos = p.hasPcos;
      allergiesController.text = p.allergies.join(', ');
    }
  }

  String _getWeightHint() {
    final h = double.tryParse(heightController.text) ?? 0;
    final w = double.tryParse(weightController.text) ?? 0;
    if (h > 0 && w > 0) {
      final bmi = w / ((h / 100) * (h / 100));
      if (bmi < 18.5) return "Low range weight";
      if (bmi < 25) return "Solid healthy weight";
      if (bmi < 30) return "Slightly above range weight";
      return "Above range weight";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    final hint = _getWeightHint();

    return Scaffold(
      appBar: AppBar(title: const Text("Health Profile")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_outline, color: Colors.teal),
                          const SizedBox(width: 8),
                          const Text("Core Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Age", hintText: "e.g. 25"),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: heightController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(labelText: "Height (cm)", hintText: "e.g. 175"),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: weightController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(labelText: "Current Weight (kg)", hintText: "e.g. 70"),
                      ),
                      if (hint.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            "💡 $hint",
                            style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text("Medical Conditions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(label: const Text("Diabetes"), selected: diabetes, onSelected: (v) => setState(() => diabetes = v)),
                  FilterChip(label: const Text("Hypertension"), selected: hypertension, onSelected: (v) => setState(() => hypertension = v)),
                  FilterChip(label: const Text("PCOS"), selected: pcos, onSelected: (v) => setState(() => pcos = v)),
                ],
              ),

              const SizedBox(height: 32),
              const Text("Food Allergies", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              TextField(
                controller: allergiesController,
                decoration: const InputDecoration(
                  labelText: "Enter allergies",
                  hintText: "e.g. Peanuts, Milk, Soy (comma separated)",
                  prefixIcon: Icon(Icons.warning_amber_rounded),
                ),
              ),

              const SizedBox(height: 32),
              const Text("Primay Goal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ["Weight Loss", "Maintain", "Weight Gain"].map((g) {
                  return ChoiceChip(
                    label: Text(g),
                    selected: selectedGoal == g,
                    onSelected: (val) => setState(() => selectedGoal = val ? g : null),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),
              const Text("Diet Preference", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ["No Restriction", "Vegan", "Vegetarian", "Keto"].map((d) {
                  return ChoiceChip(
                    label: Text(d),
                    selected: selectedDiet == d,
                    onSelected: (val) => setState(() => selectedDiet = val ? d : null),
                  );
                }).toList(),
              ),

              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  if (ageController.text.isEmpty || heightController.text.isEmpty || weightController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill in your core measurements.")),
                    );
                    return;
                  }

                  setState(() => _isLoading = true);
                  final List<String> cond = [];
                  if (diabetes) cond.add("Diabetes");
                  if (hypertension) cond.add("Hypertension");
                  if (pcos) cond.add("PCOS");

                  final profile = UserProfile(
                    uid: widget.uid,
                    age: int.tryParse(ageController.text) ?? 25,
                    height: double.tryParse(heightController.text) ?? 0,
                    weight: double.tryParse(weightController.text) ?? 0,
                    gender: selectedGender ?? 'Prefer not to say',
                    goal: selectedGoal ?? 'Maintain',
                    targetWeight: double.tryParse(targetWeightController.text) ?? 0,
                    activityLevel: selectedActivity ?? 'Sedentary',
                    dietType: selectedDiet ?? 'No Restriction',
                    hasDiabetes: diabetes,
                    hasHypertension: hypertension,
                    hasPcos: pcos,
                    conditions: cond,
                    allergies: allergiesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                  );

                  try {
                    await ProfileRepository().saveProfile(profile);
                    if (mounted) _showSuccessAndRedirect();
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Save failed: $e"), backgroundColor: Colors.red),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(widget.existingProfile != null ? "SAVE CHANGES" : "FINISH SETUP"),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessAndRedirect() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 24),
            const Text("Profile Ready!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            const Text("Your health profile is now active.", textAlign: TextAlign.center),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const BottomNavScreen()),
                  (route) => false,
                );
              },
              child: const Text("LET'S GO"),
            ),
          ],
        ),
      ),
    );
  }
}