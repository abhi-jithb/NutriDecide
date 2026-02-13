import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Center(
        child: Text(
          "Scan your food to analyze health impact",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
