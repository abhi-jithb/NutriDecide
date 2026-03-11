import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/nutrition_service.dart';
import 'presentation/verdict_screen.dart';
import '../profile/data/profile_repository.dart';
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
  final MobileScannerController _scannerController = MobileScannerController();
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
    _scannerController.dispose();
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
            controller: _scannerController,
            onDetect: (capture) {
              if (!_isScanning) return;
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final code = barcodes.first.rawValue;
                if (code != null) {
                  _scannerController.stop();
                  setState(() {
                    _scannedCode = code;
                    _isScanning = false;
                  });
                  _analyzeProduct(code);
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

          // AR Toggle Button
          Positioned(
            top: 50,
            right: 20,
            child: CircleAvatar(
              backgroundColor:
                  _isArMode ? Colors.green : Colors.blue.withOpacity(0.8),
              child: IconButton(
                icon: Icon(
                    _isArMode
                        ? Icons.auto_awesome
                        : Icons.auto_awesome_motion,
                    color: Colors.white),
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

          // AR Overlay
          if (_isArMode) const _ArSimulatedOverlay(),

          // Scan Again Button
          if (!_isScanning)
            Positioned(
              bottom: 100,
              left: 40,
              right: 40,
              child: ElevatedButton(
                onPressed: () {
                  _scannerController.start();
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

  Widget _buildOverlay() {
    return Stack(
      children: [
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
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _analyzeProduct(String code) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator()),
    );

    final product = await _nutritionService.fetchProductData(code);
    final profile = await _profileRepository.getProfile();

    if (mounted) Navigator.pop(context);

    if (product == null || profile == null) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Not Found"),
            content:
                const Text("Product not available in offline database."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              )
            ],
          ),
        );
        _scannerController.start();
        setState(() {
          _isScanning = true;
          _scannedCode = null;
        });
      }
      return;
    }

    final verdict = _nutritionService.analyzeProduct(product, profile);

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
          _scannerController.start();
          setState(() {
            _isScanning = true;
            _scannedCode = null;
          });
        }
      });
    }
  }
}

// ─── AR Simulated Overlay (Separate Widget) ───────────────────────────────────

class _ArSimulatedOverlay extends StatefulWidget {
  const _ArSimulatedOverlay();

  @override
  State<_ArSimulatedOverlay> createState() => _ArSimulatedOverlayState();
}

class _ArSimulatedOverlayState extends State<_ArSimulatedOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(
                color: Colors.greenAccent.withOpacity(0.3), width: 2),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Stack(
            children: [
              // Sweeping scanner line
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Positioned(
                    top: _animController.value * 280,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.greenAccent.withOpacity(0.8),
                              blurRadius: 10,
                              spreadRadius: 3)
                        ],
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                top: 20,
                left: 20,
                child:
                    _buildArNode("Scrutinizing Ingredients...", Colors.green),
              ),
              Positioned(
                top: 80,
                right: 5,
                child: _buildArNode("Est: 250 kcal", Colors.blueAccent),
              ),
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Positioned(
                    bottom: 60,
                    left: 10,
                    child: Opacity(
                      opacity: 0.5 + (_animController.value * 0.5),
                      child: _buildArNode(
                          "⚠️ Allergy Redline Detected", Colors.redAccent),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: _buildArNode("Detecting Saturated Fats", Colors.amber),
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
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.radar, size: 12, color: color),
          const SizedBox(width: 8),
          Text(text,
              style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
