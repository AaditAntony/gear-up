import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gear_up/service-center/widgets/service_theme.dart';
import '../auth/login_page.dart';

class CenterRegisterPage extends StatefulWidget {
  const CenterRegisterPage({super.key});

  @override
  State<CenterRegisterPage> createState() => _CenterRegisterPageState();
}

class _CenterRegisterPageState extends State<CenterRegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;

  Future<void> registerCenter() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields.")));
      return;
    }

    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match.")));
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'role': 'service_center',
        'isApproved': false,
        'isSuperAdmin': false,
        'profileCompleted': false,
        'createdAt': Timestamp.now(),
      });

      setState(() {
        isLoading = false;
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registration successful. Waiting for admin approval."),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });

      String errorMessage = "Registration failed.";

      if (e.code == 'email-already-in-use') {
        errorMessage = "This email is already registered.";
      } else if (e.code == 'weak-password') {
        errorMessage = "Password must be at least 6 characters.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email format.";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong.")));
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
          color: ServiceTheme.textSecondary, fontWeight: FontWeight.w500),
      prefixIcon: Icon(icon, color: ServiceTheme.accent),
      filled: true,
      fillColor: ServiceTheme.background.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ServiceTheme.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ServiceTheme.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ServiceTheme.accent, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ServiceTheme.background,
      body: Stack(
        children: [
          /// DECORATIVE BLOBS
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: ServiceTheme.primary.withOpacity(0.04),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: 480,
                padding: const EdgeInsets.all(40),
                decoration: ServiceTheme.cardDecoration.copyWith(
                  boxShadow: ServiceTheme.cardShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// GEAR ICON
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: ServiceTheme.accent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.settings_suggest_rounded, // Premium Gear Icon
                        size: 56,
                        color: ServiceTheme.accent,
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      "Join the Network",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: ServiceTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Text(
                      "Service Center Enrollment",
                      style: TextStyle(
                        fontSize: 14,
                        color: ServiceTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 40),

                    TextField(
                      controller: nameController,
                      decoration: _inputDecoration("Company Name", Icons.business_rounded),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: emailController,
                      decoration: _inputDecoration("Email Address", Icons.email_rounded),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: _inputDecoration("Password", Icons.lock_rounded),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: _inputDecoration("Confirm Password", Icons.lock_outline_rounded),
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: Container(
                        decoration: ServiceTheme.accentButtonDecoration,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),

                          onPressed: isLoading ? null : registerCenter,

                          icon: const Icon(Icons.arrow_forward_rounded),

                          label: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "Create Account",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already part of the network?",
                          style: TextStyle(color: ServiceTheme.textSecondary, fontSize: 13),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Sign In",
                            style: TextStyle(
                              color: ServiceTheme.accent,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
