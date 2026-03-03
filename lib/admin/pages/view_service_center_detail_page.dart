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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Application Details")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('service_center_details')
            .doc(centerId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Details not found."));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['companyName'] ?? "",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text("Owner: ${data['ownerName'] ?? ""}"),
                Text("Email: ${data['email'] ?? ""}"),
                Text("Phone: ${data['phone'] ?? ""}"),
                Text("Alt Phone: ${data['alternatePhone'] ?? ""}"),

                const SizedBox(height: 10),

                Text("Address: ${data['location'] ?? ""}"),
                Text("District: ${data['district'] ?? ""}"),
                Text("State: ${data['state'] ?? ""}"),
                Text("Pincode: ${data['pincode'] ?? ""}"),

                const SizedBox(height: 10),

                Text("GST: ${data['gstNumber'] ?? ""}"),
                Text("Experience: ${data['experienceYears'] ?? ""} years"),

                const SizedBox(height: 10),

                const Text(
                  "Description:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(data['description'] ?? ""),

                const SizedBox(height: 20),

                const Text(
                  "Business License:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Image.memory(base64Decode(data['image1']), height: 150),

                const SizedBox(height: 20),

                const Text(
                  "Workshop Image:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Image.memory(base64Decode(data['image2']), height: 150),

                const SizedBox(height: 30),

                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => updateStatus(context, "approved"),
                      child: const Text("Approve"),
                    ),

                    const SizedBox(width: 15),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      onPressed: () => updateStatus(context, "rejected"),
                      child: const Text("Reject"),
                    ),

                    const SizedBox(width: 15),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => updateStatus(context, "blocked"),
                      child: const Text("Block"),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
