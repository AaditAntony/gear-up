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

  /// 🔥 INPUT STYLE (FIXED VISIBILITY)
  InputDecoration inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black87, fontSize: 14),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),

      body: Column(
        children: [
          /// 🔵 HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome Back 👋",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Login to your account",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          /// 🔥 FORM
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  width: 350,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.black.withOpacity(.05),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Vehicle Owner Login",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// EMAIL
                      TextField(
                        controller: emailController,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                        cursorColor: const Color(0xFF2563EB),
                        decoration: inputStyle("Email"),
                      ),

                      const SizedBox(height: 15),

                      /// PASSWORD
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                        cursorColor: const Color(0xFF2563EB),
                        decoration: inputStyle("Password"),
                      ),

                      const SizedBox(height: 20),

                      /// LOGIN BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white, // 🔥 FIX
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isLoading ? null : loginOwner,
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text("Login"),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// REGISTER BUTTON
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const OwnerRegisterPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Create Account",
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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
