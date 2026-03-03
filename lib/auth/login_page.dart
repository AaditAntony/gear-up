import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gear_up/service-center/pages/verification_pending_page.dart';
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

      // Step 1: Sign in
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      String uid = userCredential.user!.uid;

      // Step 2: Get Firestore user document
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

      // ---------------- ADMIN ----------------
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
      }
      // ---------------- SERVICE CENTER ----------------
      else if (role == "service_center") {
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

        // Fetch details document ONCE
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

      print("LOGIN ERROR: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "GearUp Login",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: isLoading ? null : loginUser,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Login"),
                ),
              ),

              const SizedBox(height: 20),

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
                    MaterialPageRoute(builder: (_) => CenterRegisterPage()),
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
