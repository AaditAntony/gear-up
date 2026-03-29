import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewServiceCenterDetailPage extends StatelessWidget {
  final String centerId;

  const ViewServiceCenterDetailPage({super.key, required this.centerId});

  Future<void> updateStatus(BuildContext context, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('service_center_details')
        .doc(centerId)
        .update({'status': newStatus});

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Status updated to $newStatus")));

    Navigator.pop(context);
  }

  Widget infoTile(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF3B82F6), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget imagePreview(String title, String base64Image) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_rounded, size: 18, color: Color(0xFF64748B)),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              base64Decode(base64Image),
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget statusChip(String status) {
    Color color = Colors.orange;
    IconData icon = Icons.hourglass_empty_rounded;

    if (status == "approved") {
      color = Colors.green;
      icon = Icons.check_circle_rounded;
    }
    if (status == "rejected") {
      color = Colors.red;
      icon = Icons.cancel_rounded;
    }
    if (status == "blocked") {
      color = Colors.grey;
      icon = Icons.block_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Credential Verification",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF1E293B), letterSpacing: -0.5),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_left_rounded, size: 24, color: Color(0xFF1E293B)),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('service_center_details').doc(centerId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Specified credentials not found in registry."));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          String status = data['status'] ?? "pending";

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// HEADER ENTITY CARD
                      Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 20,
                              color: Colors.black.withOpacity(.02),
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B).withOpacity(.05),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(
                                Icons.verified_user_rounded,
                                color: Color(0xFF1E293B),
                                size: 48,
                              ),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['companyName'] ?? "N/A",
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF1E293B),
                                      letterSpacing: -1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3B82F6).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.military_tech_rounded, size: 16, color: Color(0xFF3B82F6)),
                                            const SizedBox(width: 8),
                                            Text(
                                              "${data['experienceYears']}Y Professional Experience",
                                              style: const TextStyle(
                                                color: Color(0xFF3B82F6),
                                                fontWeight: FontWeight.w900,
                                                fontSize: 12,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            statusChip(status),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      /// DATA GRID ARCHITECTURE
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// LEFT COMPARTMENT: REGISTRY INFO
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                sectionTitle("Ownership & Contact"),
                                const SizedBox(height: 16),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Wrap(
                                      spacing: 20,
                                      runSpacing: 20,
                                      children: [
                                        SizedBox(width: (constraints.maxWidth - 20) / 2, child: infoTile(Icons.assignment_ind_rounded, "LEGAL OWNER", data['ownerName'] ?? "")),
                                        SizedBox(width: (constraints.maxWidth - 20) / 2, child: infoTile(Icons.alternate_email_rounded, "OFFICIAL EMAIL", data['email'] ?? "")),
                                        SizedBox(width: (constraints.maxWidth - 20) / 2, child: infoTile(Icons.phone_in_talk_rounded, "PRIMARY CONTACT", data['phone'] ?? "")),
                                        SizedBox(width: (constraints.maxWidth - 20) / 2, child: infoTile(Icons.contact_phone_rounded, "ALT CONTACT", data['alternatePhone'] ?? "")),
                                      ],
                                    );
                                  },
                                ),

                                const SizedBox(height: 48),

                                sectionTitle("Geographical Logistics"),
                                const SizedBox(height: 16),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Wrap(
                                      spacing: 20,
                                      runSpacing: 20,
                                      children: [
                                        SizedBox(width: (constraints.maxWidth - 20) / 2, child: infoTile(Icons.map_rounded, "PRECISE LOCATION", data['location'] ?? "")),
                                        SizedBox(width: (constraints.maxWidth - 20) / 2, child: infoTile(Icons.domain_rounded, "REGIONAL DISTRICT", data['district'] ?? "")),
                                        SizedBox(width: (constraints.maxWidth - 20) / 2, child: infoTile(Icons.language_rounded, "ADMIN STATE", data['state'] ?? "")),
                                        SizedBox(width: (constraints.maxWidth - 20) / 2, child: infoTile(Icons.tag_rounded, "POSTAL INDEX", data['pincode'] ?? "")),
                                      ],
                                    );
                                  },
                                ),

                                const SizedBox(height: 24),
                                infoTile(Icons.verified_rounded, "TAXATION: GST REGISTRATION NUMBER", data['gstNumber'] ?? ""),

                                const SizedBox(height: 48),

                                sectionTitle("Corporate Summary"),
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: const Color(0xFFF1F5F9)),
                                  ),
                                  child: Text(
                                    data['description'] ?? "No narrative description available in state registry.",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF475569),
                                      height: 1.8,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 48),

                          /// RIGHT COMPARTMENT: DOCUMENTATION
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                sectionTitle("Documentary Evidence"),
                                const SizedBox(height: 16),
                                imagePreview("Operational License", data['image1']),
                                const SizedBox(height: 32),
                                imagePreview("Physical Infrastructure", data['image2']),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              /// PERSISTENT ACTION HUD
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 30,
                      color: Colors.black.withOpacity(.05),
                      offset: const Offset(0, -10),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            "ADMINISTRATIVE OVERRIDE",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF94A3B8),
                              letterSpacing: 2.0,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Final Determination",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      _actionButton("AUTHORIZE", const Color(0xFF10B981), () => updateStatus(context, "approved")),
                      const SizedBox(width: 16),
                      _actionButton("DECLINE", const Color(0xFFF59E0B), () => updateStatus(context, "rejected")),
                      const SizedBox(width: 16),
                      _actionButton("DEACTIVATE", const Color(0xFFEF4444), () => updateStatus(context, "blocked")),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        shadowColor: color.withOpacity(0.4),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.0),
      ),
    );
  }
}
