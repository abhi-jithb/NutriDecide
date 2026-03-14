import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:lottie/lottie.dart';
import '../regional/services/regional_food_service.dart';
import '../scan/services/nutrition_service.dart';
import '../profile/data/profile_repository.dart';
import '../scan/presentation/verdict_screen.dart';

class VoiceLogScreen extends StatefulWidget {
  const VoiceLogScreen({super.key});

  @override
  State<VoiceLogScreen> createState() => _VoiceLogScreenState();
}

class _VoiceLogScreenState extends State<VoiceLogScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Tap the mic and say something like '2 puttu and fish curry'";
  double _confidence = 1.0;

  final RegionalFoodService _regionalService = RegionalFoodService();
  final NutritionService _nutritionService = NutritionService();
  final ProfileRepository _profileRepo = ProfileRepository();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      _processVoiceInput(_text);
    }
  }

  void _processVoiceInput(String text) async {
    // Show Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final food = await _regionalService.searchFood(text);
    final profile = await _profileRepo.getProfile();

    if (mounted) Navigator.pop(context); // Hide loading
    
    if (food != null && profile != null) {
      final verdict = _nutritionService.analyzeProduct(food, profile);
      
      if (!mounted) return;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerdictScreen(
            product: food,
            verdict: verdict,
            profile: profile,
          ),
        ),
      );
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Product Not Available"),
            content: Text("We couldn't identify '$text' in our database.\n\nPlease select/say something from the currently identified list below."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Voice Nutrition AI")),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              const Text(
                "Identify Street food with voice",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: _listen,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isListening ? 120 : 100,
                  height: _isListening ? 120 : 100,
                  decoration: BoxDecoration(
                    color: _isListening ? Colors.red : Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isListening ? Colors.red : Theme.of(context).colorScheme.primary).withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: _isListening ? 10 : 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isListening ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
              if (_isListening)
                const Padding(
                  padding: EdgeInsets.only(top: 24.0),
                  child: Text("Listening for Kerala foods...", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                     const Text(
                      "Currently identifying:",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildFoodChip("Puttu"),
                      _buildFoodChip("Appam"),
                      _buildFoodChip("Parotta"),
                      _buildFoodChip("Idli"),
                      _buildFoodChip("Vada"),
                      _buildFoodChip("Sambar"),
                      _buildFoodChip("Fish Curry"),
                      _buildFoodChip("Beef Fry"),
                    ],
                  ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 48.0),
                child: Text(
                  "Tip: Specify portions like 'Two parotta' or 'Half appam'",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodChip(String label) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 10)),
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
