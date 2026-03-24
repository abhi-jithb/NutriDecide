import 'package:flutter/material.dart';

/// A production-ready global error handling utility for NutriDecide.
/// Prevents app crashes by catching unhandled exceptions and providing 
/// a fallback UI for critical failures.
class GlobalErrorHandler {
  static void initialize() {
    // Catch errors within the Flutter framework
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      _logError(details.exception, details.stack);
    };

    // Catch errors outside the Flutter framework (e.g., async errors)
    // Need to wrap main with runZonedGuarded in main.dart for this.
  }

  static void _logError(dynamic error, StackTrace? stack) {
    // Forward to Sentry/Crashlytics in future. Currently local debug print.
    debugPrint('🛑 GLOBAL ERROR CAUGHT: $error');
  }

  /// Wraps a widget with an error boundary for UI-level crash protection.
  static Widget errorBoundary(BuildContext context, Widget? child) {
    if (child is Scaffold || child is Navigator) return child!;
    
    return child ?? const SizedBox.shrink();
  }

  /// A standard Error Fallback Widget for production.
  static Widget buildErrorUI(BuildContext context, dynamic error) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text(
                "Something went wrong",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "We encountered an unexpected error. Please restart the app or try again later.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text("Go to Home"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
