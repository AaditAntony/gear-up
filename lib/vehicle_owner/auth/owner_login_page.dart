import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gear_up/vehicle_owner/pages/complete_profile_page.dart';
import 'package:gear_up/vehicle_owner/pages/owner_dashboard.dart';
import 'owner_register_page.dart';

class OwnerLoginPage extends StatefulWidget {
  const OwnerLoginPage({super.key});

  @override
  State<OwnerLoginPage> createState() => _OwnerLoginPageState();
}

class _OwnerLoginPageState extends State<OwnerLoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> loginOwner() async {
    try {
      setState(() => isLoading = true);

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      String uid = userCredential.user!.uid;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User data not found.")));
        return;
      }

      var data = userDoc.data() as Map<String, dynamic>;

      if (data['role'] != 'vehicle_owner') {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Access denied.")));
        return;
      }

      bool profileCompleted = data['profileCompleted'] ?? false;

      setState(() => isLoading = false);

      if (!profileCompleted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CompleteProfilePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OwnerDashboard()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "Error")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          /// LEFT SIDE - BRANDING (Visible on larger screens)
          if (MediaQuery.of(context).size.width > 900)
            Expanded(
              flex: 1,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.settings_suggest_rounded, size: 80, color: Colors.white),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        "GearUp",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Your ultimate vehicle companion",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          /// RIGHT SIDE - LOGIN FORM
          Expanded(
            flex: 1,
            child: Container(
              color: const Color(0xFFF8FAFC),
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// MOBILE LOGO
                        if (MediaQuery.of(context).size.width <= 900) ...[
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.settings_suggest_rounded, color: Colors.white, size: 32),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Center(
                            child: Text(
                              "GearUp",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1E293B),
                                letterSpacing: -1.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],

                        const Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Sign in to your account and manage your vehicles with ease.",
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 40),

                        /// EMAIL FIELD
                        _buildLabel("EMAIL ADDRESS"),
                        TextField(
                          controller: emailController,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          decoration: _inputDecoration("Enter your email", Icons.email_rounded),
                        ),
                        const SizedBox(height: 24),

                        /// PASSWORD FIELD
                        _buildLabel("PASSWORD"),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          decoration: _inputDecoration("Enter your password", Icons.lock_rounded),
                        ),
                        const SizedBox(height: 32),

                        /// LOGIN BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E293B),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: isLoading ? null : loginOwner,
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                  )
                                : const Text(
                                    "Sign In",
                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 0.5),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// REGISTER LINK
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account?",
                              style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const OwnerRegisterPage()),
                                );
                              },
                              child: const Text(
                                "Create Account",
                                style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: Color(0xFF94A3B8),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w500, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF1E293B), width: 1.5),
      ),
    );
  }
}
