import 'package:flutter/material.dart';

class Helpers {
  Helpers._();

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}
