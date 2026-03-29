import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRegisterPage extends StatefulWidget {
  const AdminRegisterPage({super.key});

  @override
  State<AdminRegisterPage> createState() => _AdminRegisterPageState();
}

class _AdminRegisterPageState extends State<AdminRegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;

  final String superAdminEmail = "superadmin@gearup.com";

  Future<void> registerAdmin() async {
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

      bool isSuperAdmin =
          emailController.text.trim().toLowerCase() == superAdminEmail;

      bool isApproved = isSuperAdmin ? true : false;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'role': 'admin',
        'isApproved': isApproved,
        'isSuperAdmin': isSuperAdmin,
        'createdAt': Timestamp.now(),
      });

      await FirebaseAuth.instance.signOut();

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Admin registered. Waiting for approval."),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          /// BACKGROUND DECORATION
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.03),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.03),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 60),
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// BRANDING SECTION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1E293B).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.settings_suggest_rounded, size: 32, color: Colors.white),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "GEAR UP",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E293B),
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            "ADMINISTRATION PORTAL",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF3B82F6),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  /// FORM CONTAINER
                  Container(
                    width: 520,
                    padding: const EdgeInsets.all(56),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Registry Enrollment",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1E293B),
                            letterSpacing: -1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Configure new administrative credentials for platform oversight.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 48),

                        /// FORM FIELDS
                        _buildInputLabel("ADMINISTRATIVE IDENTITY"),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: nameController,
                          hint: "Enter Full Legal Name",
                          icon: Icons.badge_rounded,
                        ),

                        const SizedBox(height: 28),

                        _buildInputLabel("COMMUNICATION CHANNEL"),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: emailController,
                          hint: "official.email@gearup.com",
                          icon: Icons.alternate_email_rounded,
                        ),

                        const SizedBox(height: 28),

                        _buildInputLabel("SECURITY PASSPHRASE"),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: passwordController,
                          hint: "••••••••",
                          icon: Icons.lock_person_rounded,
                          isPassword: true,
                        ),

                        const SizedBox(height: 28),

                        _buildInputLabel("AUTHENTICATION CONFIRMATION"),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: confirmPasswordController,
                          hint: "••••••••",
                          icon: Icons.verified_user_rounded,
                          isPassword: true,
                        ),

                        const SizedBox(height: 48),

                        /// REGISTER ACTION
                        SizedBox(
                          width: double.infinity,
                          height: 64,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E293B),
                              foregroundColor: Colors.white,
                              elevation: 12,
                              shadowColor: const Color(0xFF1E293B).withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: isLoading ? null : registerAdmin,
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
                                    "AUTHORIZE & ENROLL",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        /// BACK NAVIGATION
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF64748B),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
                                ),
                                const SizedBox(width: 16),
                                const Text(
                                  "Return to Security Gate",
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: Color(0xFF94A3B8),
        letterSpacing: 1.5,
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
      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: const Color(0xFF94A3B8).withOpacity(0.4), fontSize: 14),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Icon(icon, color: const Color(0xFF1E293B), size: 20),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.all(22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFF1F5F9), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFF1F5F9), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
        ),
      ),
    );
  }
}
