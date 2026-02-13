import 'package:flutter/material.dart';
import '../../navigation/bottom_nav_screen.dart';

class ProfileSetupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Health Profile")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(decoration: InputDecoration(labelText: "Age")),
            SizedBox(height: 16),
            TextField(decoration: InputDecoration(labelText: "Weight")),
            SizedBox(height: 16),
            TextField(decoration: InputDecoration(labelText: "Allergies")),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => BottomNavScreen()),
                );
              },
              child: Text("Finish Setup"),
            )
          ],
        ),
      ),
    );
  }
}
