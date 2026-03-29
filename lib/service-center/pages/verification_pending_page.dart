import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gear_up/service-center/widgets/service_theme.dart';
import '../../auth/login_page.dart';

class VerificationPendingPage extends StatelessWidget {
  const VerificationPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ServiceTheme.background,
      body: Stack(
        children: [
          /// BACKGROUND ACCENT
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: ServiceTheme.info.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: ServiceTheme.accent.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Center(
            child: Container(
              width: 440,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(48),
              decoration: ServiceTheme.cardDecoration.copyWith(
                boxShadow: ServiceTheme.cardShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// ICON BADGE
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: ServiceTheme.info.withOpacity(.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified_user_rounded,
                      size: 72,
                      color: ServiceTheme.info,
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// TITLE
                  const Text(
                    "In Review",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: ServiceTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  /// DESCRIPTION
                  const Text(
                    "Your workshop enrollment is currently being verified by our compliance team.\n\n"
                    "Standard verification takes 2–3 business days. We will notify you once your terminal is active.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: ServiceTheme.textSecondary,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 48),

                  /// LOGOUT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Container(
                      decoration: ServiceTheme.accentButtonDecoration,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();

                          if (!context.mounted) return;

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                            (route) => false,
                          );
                        },

                        icon: const Icon(Icons.logout_rounded, size: 20),
                        label: const Text(
                          "Switch Account",
                          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Text(
                    "Need help? Contact support@gearup.com",
                    style: TextStyle(
                      fontSize: 12,
                      color: ServiceTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
