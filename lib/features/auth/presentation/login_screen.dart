import 'package:flutter/material.dart';
import 'signup_screen.dart';
import '../../navigation/bottom_nav_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 1000)
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Premium Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.8),
                  colorScheme.secondary.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Logo / Icon
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: const Icon(Icons.restaurant_menu, size: 60, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "NutriDecide",
                          style: TextStyle(
                            fontSize: 32, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.white,
                            letterSpacing: 1.2
                          ),
                        ),
                        const Text(
                          "Decision for a healthier you",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 48),

                        // Login Card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 24, 
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Enter your credentials to continue",
                                  style: TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                                const SizedBox(height: 32),

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
                                  controller: passwordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    hintText: "Password",
                                    prefixIcon: Icon(Icons.lock_outline),
                                  ),
                                ),
                                const SizedBox(height: 32),

                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (_, __, ___) => const BottomNavScreen(),
                                        transitionsBuilder: (_, animation, __, child) {
                                          return FadeTransition(opacity: animation, child: child);
                                        },
                                      ),
                                    );
                                  },
                                  child: const Text("LOGIN"),
                                ),
                                const SizedBox(height: 16),
                                
                                Center(
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                                      );
                                    },
                                    child: RichText(
                                      text: TextSpan(
                                        text: "New here? ",
                                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                                        children: [
                                          TextSpan(
                                            text: "Create Account",
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}