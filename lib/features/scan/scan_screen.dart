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
  final MobileScannerController _scannerController = MobileScannerController();
  final NutritionService _nutritionService = NutritionService();
  final ProfileRepository _profileRepository = ProfileRepository();

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
              Icon(Icons.camera_alt_outlined, size: 64, color: Theme.of(context).colorScheme.onBackground.withOpacity(0.2)),
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
                  setState(() => _isScanning = false);
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

          // Scan Status Indicator
          if (!_isScanning)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
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
              border: Border.all(color: Theme.of(context).colorScheme.primary, width: 4),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 300),
            child: Text(
              "Place barcode inside the frame",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _analyzeProduct(String code) async {
    try {
      final product = await _nutritionService.fetchProductData(code);
      final profile = await _profileRepository.getProfile();

      if (product == null || profile == null) {
        _showNoDataDialog(code);
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
            builder: (_) => VerdictScreen(
              product: product,
              verdict: verdict,
              profile: profile,
            ),
          ),
        ).then((_) => _restartScanning());
      }
    } catch (e) {
      _handleScanError(e);
    }
  }

  void _showNoDataDialog(String code) {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              "Product Not Found",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              "We couldn't find a barcode for $code.\nWould you like to search manually?",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _restartScanning();
                    },
                    child: const Text("TRY AGAIN"),
                  ),
                ),
          ],
        ),
      ),
    ).then((_) => _restartScanning());
  }


  void _restartScanning() {
    if (mounted) {
      _scannerController.start();
      setState(() {
        _isScanning = true;
      });
    }
  }

  void _handleScanError(dynamic error) {
    debugPrint('❌ Scan Analysis Error: $error');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Network or data error. Falling back to offline mode."),
          backgroundColor: Colors.orange.shade800,
        ),
      );
      _restartScanning();
    }
  }
}
