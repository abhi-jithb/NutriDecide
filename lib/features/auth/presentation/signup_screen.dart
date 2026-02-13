import 'package:flutter/material.dart';
import 'profile_setup_screen.dart';

class SignupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(decoration: InputDecoration(labelText: "Name")),
            SizedBox(height: 16),
            TextField(decoration: InputDecoration(labelText: "Email")),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ProfileSetupScreen()),
                );
              },
              child: Text("Create Account"),
            )
          ],
        ),
      ),
    );
  }
}
