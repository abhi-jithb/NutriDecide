import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signup_screen.dart';
import '../services/auth_service.dart';

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
  bool _isLoading = false;
  bool _obscurePassword = true;

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
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    hintText: "Password",
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),

                                ElevatedButton(
                                  onPressed: _isLoading ? null : () async {
                                    final email = emailController.text.trim();
                                    final password = passwordController.text.trim();

                                    if (email.isEmpty || password.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Please fill all fields")),
                                      );
                                      return;
                                    }

                                    setState(() => _isLoading = true);

                                    try {
                                      await AuthService().loginWithEmail(email, password);
                                      // Navigation handled by AuthWrapper
                                    } on Exception catch (e) {
                                      String errorMsg = e.toString();
                                      String title = "Login Failed";
                                      String message = "Please check your network connection and try again.";
                                      bool showReset = false;
                                      bool showSignup = false;
                                      
                                      if (errorMsg.contains('invalid-credential') || 
                                          errorMsg.contains('user-not-found') || 
                                          errorMsg.contains('wrong-password')) {
                                        title = "Incorrect Email or Password";
                                        message = "The email or password you entered is incorrect. Please check again and try again.\n\nDo you really think you have an account?";
                                        showReset = true;
                                        showSignup = true;
                                      } else if (errorMsg.contains('invalid-email')) {
                                        title = "Invalid Email";
                                        message = "The email address you entered is not valid.";
                                      } else if (errorMsg.contains('network-request-failed')) {
                                        title = "Network Connection Error";
                                        message = "Please make sure you are connected to the internet before logging in.";
                                      } else if (errorMsg.contains('api-key-not-valid') || errorMsg.contains('blocked')) {
                                        title = "App Issue";
                                        message = "Our servers are currently rejecting this connection. Please try again later or contact support.";
                                        debugPrint("FIREBASE_AUTH_ERROR: $errorMsg");
                                      }

                                      if (mounted) {
                                        _showAuthError(title, message, showReset: showReset, showSignup: showSignup, email: email);
                                      }
                                    } finally {
                                      if (mounted) setState(() => _isLoading = false);
                                    }
                                  },
                                  child: _isLoading 
                                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Text("LOGIN"),
                                ),
                                const SizedBox(height: 12),

                                Center(
                                  child: TextButton(
                                    onPressed: () => _handleForgotPassword(),
                                    child: Text(
                                      "Forgot Password?",
                                      style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                
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
                                const SizedBox(height: 16),
                                
                                // Admin Login Entry
                                Center(
                                  child: TextButton.icon(
                                    onPressed: () => _showAdminLoginDialog(),
                                    icon: Icon(Icons.admin_panel_settings_outlined, size: 16, color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                                    label: Text(
                                      "Admin Portal", 
                                      style: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.5), fontSize: 12)
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

  void _showAdminLoginDialog() {
    final aEmailController = TextEditingController();
    final aPasswordController = TextEditingController();
    bool _isLocalLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.shield, color: Colors.blueGrey),
                SizedBox(width: 8),
                Text("Admin Login"),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Enter admin credentials to authorize management access.", style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 16),
                TextField(
                  controller: aEmailController,
                  decoration: const InputDecoration(hintText: "Admin Email", prefixIcon: Icon(Icons.email)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: aPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: "Admin Password", prefixIcon: Icon(Icons.lock)),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: _isLocalLoading ? null : () => Navigator.pop(ctx),
                child: const Text("CANCEL"),
              ),
              ElevatedButton(
                onPressed: _isLocalLoading ? null : () async {
                  if (aEmailController.text.isEmpty || aPasswordController.text.isEmpty) return;
                  
                  setDialogState(() => _isLocalLoading = true);
                  try {
                    final cred = await AuthService().loginWithEmail(aEmailController.text.trim(), aPasswordController.text.trim());
                    if (cred?.user != null) {
                      // Force admin role in firestore
                      await FirebaseFirestore.instance.collection('users').doc(cred!.user!.uid).set({
                        'role': 'admin'
                      }, SetOptions(merge: true));
                    }
                    if (mounted) Navigator.pop(ctx); // Close dialog, AuthWrapper handles navigation
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid Admin Credentials or Network Error")));
                  } finally {
                    setDialogState(() => _isLocalLoading = false);
                  }
                },
                child: _isLocalLoading 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text("AUTHORIZE"),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showAuthError(String title, String message, {bool showReset = false, bool showSignup = false, String? email}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CLOSE", style: TextStyle(color: Colors.grey)),
          ),
          if (showReset && email != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _handleForgotPassword(prefilledEmail: email);
              },
              child: const Text("RESET PASSWORD"),
            ),
          if (showSignup)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen()));
              },
              child: const Text("CREATE NEW ACCOUNT"),
            ),
        ],
      ),
    );
  }

  Future<void> _handleForgotPassword({String? prefilledEmail}) async {
    final email = prefilledEmail ?? emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email to reset password")),
      );
      return;
    }

    try {
      await AuthService().resetPassword(email);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
               Icon(Icons.check_circle, color: Colors.green),
               SizedBox(width: 10),
               Text("Email Sent!"),
              ],
            ),
            content: const Text("A password reset link has been sent to your inbox. Please check your email to continue."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}