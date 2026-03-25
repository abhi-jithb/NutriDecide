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
  bool _isLoading = false;

  final List<String> allergies = [];
  final List<String> intolerances = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingProfile != null) {
      final p = widget.existingProfile!;
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
    }
  }

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

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.straighten, color: Colors.teal),
                          const SizedBox(width: 8),
                          const Text("Measurements", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: heightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Height (cm)", hintText: "e.g. 175"),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: weightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Current Weight (kg)", hintText: "e.g. 70"),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text("Biological Gender", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ["Male", "Female", "Other"].map((g) {
                  return ChoiceChip(
                    label: Text(g),
                    selected: selectedGender == g,
                    onSelected: (val) => setState(() => selectedGender = val ? g : null),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),
              const Text("Primary Goal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
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
              const Text("Diet Type", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ["No Restriction", "Vegan", "Vegetarian", "Keto", "Low-carb"].map((d) {
                  return ChoiceChip(
                    label: Text(d),
                    selected: selectedDiet == d,
                    onSelected: (val) => setState(() => selectedDiet = val ? d : null),
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  if (selectedGender == null || selectedGoal == null || selectedDiet == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select all lifestyle options ❤️")),
                    );
                    return;
                  }

                  setState(() => _isLoading = true);
                  final profile = UserProfile(
                    uid: widget.uid,
                    height: double.tryParse(heightController.text) ?? 0,
                    weight: double.tryParse(weightController.text) ?? 0,
                    gender: selectedGender ?? '',
                    goal: selectedGoal ?? '',
                    targetWeight: double.tryParse(targetWeightController.text) ?? 0,
                    activityLevel: selectedActivity ?? 'Sedentary',
                    dietType: selectedDiet ?? '',
                    hasDiabetes: diabetes,
                    hasHypertension: hypertension,
                    hasPcos: pcos,
                    allergies: widget.existingProfile?.allergies ?? [], 
                  );

                  try {
                    await ProfileRepository().saveProfile(profile);
                    
                    if (mounted) {
                      _showSuccessAndRedirect();
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Save Failed: $e"), backgroundColor: Colors.red),
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
            const Text("Your customized health path is now set up.", textAlign: TextAlign.center),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                if (widget.existingProfile != null) {
                   Navigator.pop(context, true); // Go back if editing
                }
                // For new users, AuthWrapper will auto-switch to BottomNavScreen 
                // because the Firestore stream just fired with data.
              },
              child: const Text("LET'S GO"),
            ),
          ],
        ),
      ),
    );
  }
}