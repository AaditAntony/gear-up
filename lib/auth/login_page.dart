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
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(30),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(blurRadius: 15, color: Colors.black.withOpacity(.08)),
            ],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// LOGO
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withOpacity(.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.settings,
                  size: 45,
                  color: Color(0xFFF97316),
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                "GearUp",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 5),

              const Text(
                "Login to your account",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF334155),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isLoading ? null : loginUser,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Login"),
                ),
              ),

              const SizedBox(height: 25),

              const Divider(),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminRegisterPage(),
                    ),
                  );
                },
                child: const Text("Register as Admin"),
              ),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CenterRegisterPage(),
                    ),
                  );
                },
                child: const Text("Register as Service Center"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
