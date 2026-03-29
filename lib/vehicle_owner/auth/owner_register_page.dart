import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'owner_login_page.dart';

class OwnerRegisterPage extends StatefulWidget {
  const OwnerRegisterPage({super.key});

  @override
  State<OwnerRegisterPage> createState() => _OwnerRegisterPageState();
}

class _OwnerRegisterPageState extends State<OwnerRegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> registerOwner() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fill all fields")));
      return;
    }

    try {
      setState(() => isLoading = true);

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'role': 'vehicle_owner',
        'profileCompleted': false,
        'createdAt': Timestamp.now(),
      });

      setState(() => isLoading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OwnerLoginPage()),
      );
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
                    colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
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
                        "Join the premium vehicle network",
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

          /// RIGHT SIDE - REGISTER FORM
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
                                color: const Color(0xFF2563EB),
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
                                color: Color(0xFF2563EB),
                                letterSpacing: -1.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],

                        const Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2563EB),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Join GearUp today and experience premium vehicle care management.",
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
                          decoration: _inputDecoration("Create a password", Icons.lock_rounded),
                        ),
                        const SizedBox(height: 32),

                        /// REGISTER BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: isLoading ? null : registerOwner,
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                  )
                                : const Text(
                                    "Register Now",
                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 0.5),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// LOGIN LINK
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already have an account?",
                              style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const OwnerLoginPage()),
                                );
                              },
                              child: const Text(
                                "Sign In",
                                style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w800),
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
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
    );
  }
}
