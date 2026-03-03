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
          MaterialPageRoute(
              builder: (_) =>
                  const CompleteProfilePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  const OwnerDashboard()),
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
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Vehicle Owner Login",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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

              ElevatedButton(
                onPressed: isLoading ? null : loginOwner,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Login"),
              ),

              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OwnerRegisterPage(),
                    ),
                  );
                },
                child: const Text("Create Account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
