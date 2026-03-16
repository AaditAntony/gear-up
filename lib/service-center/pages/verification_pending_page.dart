import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../auth/login_page.dart';

class VerificationPendingPage extends StatelessWidget {
  const VerificationPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7ED),

      body: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(35),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(blurRadius: 12, color: Colors.black.withOpacity(.08)),
            ],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// ICON BADGE
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top,
                  size: 55,
                  color: Colors.orange,
                ),
              ),

              const SizedBox(height: 20),

              /// TITLE
              const Text(
                "Application Under Verification",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 15),

              /// DESCRIPTION
              const Text(
                "Your company registration is currently under review.\n\n"
                "Verification may take 7–10 business days.\n\n"
                "You will gain access to your dashboard once approved.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey, height: 1.6),
              ),

              const SizedBox(height: 30),

              /// LOGOUT BUTTON
              SizedBox(
                width: double.infinity,
                height: 48,

                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  },

                  icon: const Icon(Icons.logout),

                  label: const Text(
                    "Logout",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
