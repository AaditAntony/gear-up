import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gear_up/service-center/widgets/service_theme.dart';
import 'edit_center_profile_page.dart';

class CenterProfilePage extends StatelessWidget {
  const CenterProfilePage({super.key});

  Future<DocumentSnapshot> getCenterDetails() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('service_center_details')
        .doc(uid)
        .get();
  }

  Color statusColor(String status) {
    switch (status) {
      case "approved":
        return ServiceTheme.success;
      case "pending":
        return ServiceTheme.warning;
      case "blocked":
        return ServiceTheme.error;
      default:
        return ServiceTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: getCenterDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("Profile not found"));
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;
        String status = data['status'] ?? "unknown";

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                   Icon(Icons.business_center_rounded, color: ServiceTheme.accent, size: 28),
                   SizedBox(width: 12),
                   Text("Workshop Profile", style: ServiceTheme.heading1),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Public identity of your service center on GearUp.", 
                style: ServiceTheme.body,
              ),

              const SizedBox(height: 32),

              /// HEADER CARD
              Container(
                padding: const EdgeInsets.all(32),
                decoration: ServiceTheme.cardDecoration,
                child: Column(
                  children: [
                    /// COMPANY IMAGE
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: ServiceTheme.accent.withOpacity(0.2), width: 3),
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: ServiceTheme.background,
                            backgroundImage: data['image'] != null
                                ? MemoryImage(base64Decode(data['image']))
                                : null,
                            child: data['image'] == null
                                ? const Icon(Icons.storefront_rounded, size: 48, color: ServiceTheme.textSecondary)
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: ServiceTheme.accent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    /// COMPANY NAME
                    Text(
                      data['companyName'] ?? "Unnamed Workshop",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: ServiceTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// DISTRICT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on_rounded, size: 14, color: ServiceTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          "${data['district']}, ${data['state']}",
                          style: const TextStyle(color: ServiceTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// STATUS BADGE
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: statusColor(status).withOpacity(.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: statusColor(status), shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              color: statusColor(status),
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Corporate Details", style: ServiceTheme.heading2),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditCenterProfilePage()),
                      );
                    },
                    icon: const Icon(Icons.edit_note_rounded, size: 20),
                    label: const Text("Edit Information"),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              infoTile(Icons.person_outline_rounded, "Legal Representative", data['ownerName'] ?? "Not specified"),
              infoTile(Icons.alternate_email_rounded, "Official Email", data['email'] ?? "Not specified"),
              infoTile(Icons.contact_phone_outlined, "Direct Contact", data['phone'] ?? "Not specified"),
              infoTile(Icons.map_outlined, "Address Line", data['location'] ?? "Not specified"),
              infoTile(Icons.description_outlined, "Business Brief", data['description'] ?? "No description provided."),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget infoTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ServiceTheme.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ServiceTheme.accent.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: ServiceTheme.accent, size: 20),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(fontSize: 10, color: ServiceTheme.textSecondary, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: ServiceTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
