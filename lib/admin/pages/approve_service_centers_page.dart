import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApproveServiceCentersPage extends StatelessWidget {
  const ApproveServiceCentersPage({super.key});

  Future<void> approveCenter(BuildContext context, String uid) async {
    try {
      await FirebaseFirestore.instance
          .collection('service_center_details')
          .doc(uid)
          .update({'status': 'approved'});

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'isApproved': true,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Service Center Approved")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Approval failed.")));
    }
  }

  Future<void> rejectCenter(BuildContext context, String uid) async {
    try {
      await FirebaseFirestore.instance
          .collection('service_center_details')
          .doc(uid)
          .update({'status': 'rejected'});

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Service Center Rejected")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Rejection failed.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Approve Service Centers",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 20),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('service_center_details')
                .where('status', isEqualTo: 'pending')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text("No pending service center approvals."),
                );
              }

              var centers = snapshot.data!.docs;

              return ListView.builder(
                itemCount: centers.length,
                itemBuilder: (context, index) {
                  var center = centers[index];
                  String uid = center.id;

                  String phone = center['phone'] ?? '';
                  String location = center['location'] ?? '';
                  String description = center['description'] ?? '';

                  String image1 = center['image1'];
                  String image2 = center['image2'];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Phone: $phone"),
                          Text("Location: $location"),
                          const SizedBox(height: 5),
                          Text("Description: $description"),

                          const SizedBox(height: 15),

                          Row(
                            children: [
                              Image.memory(
                                base64Decode(image1),
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(width: 20),
                              Image.memory(
                                base64Decode(image2),
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () => approveCenter(context, uid),
                                child: const Text("Approve"),
                              ),
                              const SizedBox(width: 20),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () => rejectCenter(context, uid),
                                child: const Text("Reject"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
