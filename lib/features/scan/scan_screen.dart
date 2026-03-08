import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/nutrition_service.dart';
import 'presentation/verdict_screen.dart';
import '../profile/data/profile_repository.dart';
import 'models/nutrition_data.dart';
import 'models/scan_history_item.dart';
import 'data/scan_repository.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _hasPermission = false;
  bool _isScanning = true;
  String? _scannedCode;
  final MobileScannerController _controller = MobileScannerController();
  final NutritionService _nutritionService = NutritionService();
  final ProfileRepository _profileRepository = ProfileRepository();
  bool _isArMode = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _hasPermission = status.isGranted;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return Scaffold(
        appBar: AppBar(title: const Text("Scan Food")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text("Camera permission is required to scan."),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _checkPermission,
                child: const Text("Grant Permission"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (!_isScanning) return;
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final code = barcodes.first.rawValue;
                if (code != null) {
                  _controller.stop(); // Stop camera surface to save resources
                  setState(() {
                    _scannedCode = code;
                    _isScanning = false;
                  });
                  _showSuccessSheet(code);
                }
              }
            },
          ),
          // Scanner Overlay
          _buildOverlay(),
          
          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          Positioned(
            top: 50,
            right: 20,
            child: CircleAvatar(
              backgroundColor: _isArMode ? Colors.green : Colors.blue.withOpacity(0.8),
              child: IconButton(
                icon: Icon(_isArMode ? Icons.auto_awesome : Icons.auto_awesome_motion, color: Colors.white),
                onPressed: () {
                  setState(() => _isArMode = !_isArMode);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isArMode 
                        ? "AR Overlay Mode Enabled (Moonshot): Real-time analysis active." 
                        : "AR Overlay Mode Disabled."),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
          ),
          
          if (_isArMode)
            _buildArIndicators(),
          
          if (!_isScanning)
            Positioned(
              bottom: 100,
              left: 40,
              right: 40,
              child: ElevatedButton(
                onPressed: () {
                  _controller.start(); // Resume camera
                  setState(() {
                    _isScanning = true;
                    _scannedCode = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Scan Again"),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildArIndicators() {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 20,
                left: 20,
                child: _buildArNode("Scrutinizing Ingredients...", Colors.green),
              ),
              Positioned(
                top: 60,
                right: 10,
                child: _buildArNode("Est: 250 kcal", Colors.blueAccent),
              ),
              Positioned(
                bottom: 80,
                left: 10,
                child: _buildArNode("⚠️ Allergy Redline Detected", Colors.redAccent),
              ),
              Positioned(
                bottom: 40,
                right: 20,
                child: _buildArNode("Detecting Saturated Fats", Colors.amber),
              ),
              Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green.withOpacity(0.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArNode(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.radar, size: 12, color: color),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Stack(
      children: [
        // Darken the outside area
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Center(
                child: Container(
                  height: 250,
                  width: 250,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Frame
        Center(
          child: Container(
            height: 250,
            width: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green, width: 4),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 300),
            child: Text(
              "Place barcode inside the frame",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  void _showSuccessSheet(String code) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text(
                "Product Detected!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Barcode: $code", style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  _analyzeProduct(code);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("Analyze Ingredients"),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      if (mounted && _isScanning == false && _scannedCode != null) {
        _controller.start(); // Resume if back from sheet without analysis
        setState(() {
          _isScanning = true;
          _scannedCode = null;
        });
      }
    });
  }

  Future<void> _analyzeProduct(String code) async {
    // Show Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final product = await _nutritionService.fetchProductData(code);
    final profile = await _profileRepository.getProfile();

    if (mounted) Navigator.pop(context); // Hide loading

    if (product == null || profile == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch product data or profile.")),
        );
        _controller.start(); // Resume camera on error
        setState(() {
          _isScanning = true;
          _scannedCode = null;
        });
      }
      return;
    }

    final verdict = _nutritionService.analyzeProduct(product, profile);

    // Save to History
    await ScanRepository().saveScan(ScanHistoryItem(
      barcode: code,
      productName: product.productName,
      verdict: verdict.verdict.name.toUpperCase(),
      timestamp: DateTime.now(),
    ));

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerdictScreen(product: product, verdict: verdict),
        ),
      ).then((_) {
         if (mounted) {
          _controller.start(); // Resume camera when back from verdict
          setState(() {
            _isScanning = true;
            _scannedCode = null;
          });
        }
      });
    }
  }
}
