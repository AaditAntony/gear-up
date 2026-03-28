import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gear_up/service-center/widgets/service_theme.dart';
import '../../auth/login_page.dart';
import '../service_center_form_page.dart';

class RejectedPage extends StatelessWidget {
  const RejectedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ServiceTheme.background,
      body: Center(
        child: Container(
          width: 440,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(48),
          decoration: ServiceTheme.cardDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// ICON
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: ServiceTheme.error.withOpacity(.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.assignment_late_rounded,
                  size: 64,
                  color: ServiceTheme.error,
                ),
              ),

              const SizedBox(height: 32),

              /// TITLE
              const Text(
                "Feedback Required",
                style: ServiceTheme.heading1,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              /// MESSAGE
              const Text(
                "Your recent workshop application was not approved by our compliance department.\n\n"
                "Common reasons include blurred documentation or missing business permits. Please correct your details and resubmit.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: ServiceTheme.textSecondary, height: 1.6, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 48),

              /// RESUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ServiceTheme.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

                  icon: const Icon(Icons.description_rounded, size: 20),
                  label: const Text(
                    "Correct & Resubmit",
                    style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// LOGOUT BUTTON
              TextButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();

                  if (!context.mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },

                icon: const Icon(Icons.logout_rounded, color: ServiceTheme.error, size: 18),
                label: const Text(
                  "Sign Out",
                  style: TextStyle(
                    color: ServiceTheme.error,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
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