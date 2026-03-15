import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../auth/login_page.dart';
import '../service_center_form_page.dart';

class RejectedPage extends StatelessWidget {
  const RejectedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7ED),

      body: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(30),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                color: Colors.black.withOpacity(.08),
              ),
            ],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// ICON
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel,
                  size: 60,
                  color: Colors.red,
                ),
              ),

              const SizedBox(height: 20),

              /// TITLE
              const Text(
                "Application Rejected",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              /// MESSAGE
              const Text(
                "Your submitted documents were not valid or incomplete.\n\n"
                "Please review your details and resubmit your application.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 30),

              /// RESUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ServiceCenterFormPage(),
                      ),
                    );
                  },

                  icon: const Icon(Icons.refresh),

                  label: const Text(
                    "Resubmit Application",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              /// LOGOUT BUTTON
              TextButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(),
                    ),
                    (route) => false,
                  );
                },

                icon: const Icon(Icons.logout, color: Colors.red),

                label: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
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