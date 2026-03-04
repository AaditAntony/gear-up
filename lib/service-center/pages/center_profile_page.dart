import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CenterProfilePage extends StatelessWidget {
  const CenterProfilePage({super.key});

  Future<DocumentSnapshot> getCenterDetails() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('service_center_details')
        .doc(uid)
        .get();
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

        return Scaffold(
          appBar: AppBar(title: const Text("Company Profile")),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                const Text(
                  "Service Center Details",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                infoTile("Company Name", data['companyName']),
                infoTile("Owner Name", data['ownerName']),
                infoTile("Phone", data['phone']),
                infoTile("Email", data['email']),
                infoTile("Location", data['location']),
                infoTile("District", data['district']),
                infoTile("State", data['state']),
                infoTile("Description", data['description']),

                const SizedBox(height: 20),

                Text(
                  "Status: ${data['status']}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget infoTile(String title, String value) {
    return Card(
      child: ListTile(title: Text(title), subtitle: Text(value)),
    );
  }
}
