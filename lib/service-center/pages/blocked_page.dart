import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gear_up/service-center/widgets/service_theme.dart';
import '../../auth/login_page.dart';

class BlockedPage extends StatelessWidget {
  const BlockedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ServiceTheme.background,
      body: Stack(
        children: [
          /// BACKGROUND ACCENT
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: ServiceTheme.error.withOpacity(0.04),
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
                  /// ICON
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: ServiceTheme.error.withOpacity(.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.block_flipped,
                      size: 72,
                      color: ServiceTheme.error,
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// TITLE
                  const Text(
                    "Access Suspended",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: ServiceTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  /// MESSAGE
                  const Text(
                    "Your workshop terminal has been administratively suspended due to a violation of our Service Provider Agreement.\n\n"
                    "Please reach out to our Operations Team to appeal this decision.",
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
                    "Compliance ID: #SUSP-9921",
                    style: TextStyle(
                      fontSize: 11,
                      color: ServiceTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
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