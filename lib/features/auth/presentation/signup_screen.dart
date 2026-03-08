import 'package:flutter/material.dart';
import 'profile_setup_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final ageController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    ageController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Create Account", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.9),
                  colorScheme.secondary.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_add_outlined, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 32),
                  
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Get Started",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Create an account to start your journey",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          const SizedBox(height: 32),
                          
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              hintText: "Full Name",
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: "Email Address",
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          TextField(
                            controller: ageController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: "Age",
                              prefixIcon: Icon(Icons.calendar_today_outlined),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: "Create Password",
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                          ),
                          const SizedBox(height: 40),
                          
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => ProfileSetupScreen()),
                              );
                            },
                            child: const Text("CONTINUE"),
                          ),
                          const SizedBox(height: 16),
                          
                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: RichText(
                                text: TextSpan(
                                  text: "Already have an account? ",
                                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                                  children: [
                                    TextSpan(
                                      text: "Sign In",
                                      style: TextStyle(
                                        color: colorScheme.primary, 
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}