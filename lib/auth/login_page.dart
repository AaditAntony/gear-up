import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gear_up/service-center/pages/blocked_page.dart';
import 'package:gear_up/service-center/pages/rejected_page.dart';
import 'package:gear_up/service-center/pages/verification_pending_page.dart';
import 'package:gear_up/service-center/service_center_dashboard.dart';
import 'package:gear_up/service-center/service_center_form_page.dart';

import '../admin/admin_register.dart';
import '../admin/admin_dashboard.dart';
import '../service-center/center-register-page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> loginUser() async {
    try {
      setState(() {
        isLoading = true;
      });

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User account data not found.")),
        );
        return;
      }

      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

      String role = data['role'] ?? "";
      bool isApproved = data['isApproved'] ?? false;

      if (role == "admin") {
        if (!isApproved) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Admin account is waiting for approval."),
            ),
          );
          return;
        }

        setState(() => isLoading = false);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
        );
      } else if (role == "service_center") {
        bool profileCompleted = data.containsKey('profileCompleted')
            ? data['profileCompleted']
            : false;

        if (!profileCompleted) {
          setState(() => isLoading = false);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ServiceCenterFormPage()),
          );
          return;
        }

        DocumentSnapshot detailsDoc = await FirebaseFirestore.instance
            .collection('service_center_details')
            .doc(uid)
            .get();

        if (!detailsDoc.exists) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile details not found.")),
          );
          return;
        }

        String status = detailsDoc['status'] ?? "pending";

        setState(() => isLoading = false);

        if (status == "pending") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const VerificationPendingPage()),
          );
          return;
        }

        if (status == "approved") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ServiceCenterDashboard()),
          );
          return;
        }

        if (status == "rejected") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const RejectedPage()),
          );
          return;
        }

        if (status == "blocked") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const BlockedPage()),
          );
          return;
        }
      } else {
        setState(() => isLoading = false);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Invalid user role.")));
      }
    } on FirebaseAuthException catch (e) {
      setState(() => isLoading = false);

      String errorMessage = "Login failed. Please try again.";

      if (e.code == 'user-not-found') {
        errorMessage = "No account found with this email.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email format.";
      } else if (e.code == 'user-disabled') {
        errorMessage = "This account has been disabled.";
      } else if (e.code == 'too-many-requests') {
        errorMessage = "Too many login attempts. Try again later.";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// BRANDING / LOGO
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E293B).withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.settings_suggest_rounded,
                        size: 56,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 32),

                    const Text(
                      "GearUp",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Your professional vehicle service companion",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    /// LOGIN CARD
                    Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel("EMAIL ADDRESS"),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: emailController,
                            hint: "name@example.com",
                            icon: Icons.email_outlined,
                          ),

                          const SizedBox(height: 24),

                          _buildInputLabel("PASSWORD"),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: passwordController,
                            hint: "••••••••",
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                          ),

                          const SizedBox(height: 40),

                          /// LOGIN BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E293B),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: isLoading ? null : loginUser,
                              child: isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      "Login to Account",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    /// REGISTRATION OPTIONS
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _registrationOption(
                          label: "Admin",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AdminRegisterPage()),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        const Text("•", style: TextStyle(color: Color(0xFFCBD5E1))),
                        const SizedBox(width: 8),
                        _registrationOption(
                          label: "Service Center",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CenterRegisterPage()),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: Color(0xFF94A3B8),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: const Color(0xFF94A3B8).withOpacity(0.6)),
        prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
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
      ),
    );
  }

  Widget _registrationOption({required String label, required VoidCallback onPressed}) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF3B82F6),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
