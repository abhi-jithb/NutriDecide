import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [

            // Header
            Container(
              padding: EdgeInsets.only(top: 60, bottom: 30),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person,
                        size: 50, color: Colors.green),
                  ),
                  SizedBox(height: 12),
                  Text("John Doe",
                      style:
                          TextStyle(fontSize: 20, color: Colors.white)),
                  Text("Age: 24",
                      style:
                          TextStyle(color: Colors.white70)),
                ],
              ),
            ),

            SizedBox(height: 20),

            _buildInfoCard("Height", "170 cm"),
            _buildInfoCard("Weight", "70 kg"),
            _buildInfoCard("Goal", "Weight Loss"),
            _buildInfoCard("Activity", "Moderately Active"),
            _buildInfoCard("Conditions", "Diabetes"),
            _buildInfoCard("Allergies", "Nuts"),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Card(
        elevation: 4,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          title: Text(title),
          trailing: Text(value,
              style:
                  TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}