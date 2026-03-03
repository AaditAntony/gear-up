import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApproveAdminsPage extends StatelessWidget {
  const ApproveAdminsPage({super.key});

  Future<void> approveAdmin(BuildContext context, String uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'isApproved': true});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Admin approved successfully.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          "Approve Admins",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 20),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'admin')
                .where('isApproved', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text("No pending admin approvals."),
                );
              }

              var admins = snapshot.data!.docs;

              return ListView.builder(
                itemCount: admins.length,
                itemBuilder: (context, index) {

                  var admin = admins[index];
                  String uid = admin.id;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(admin['name'] ?? ''),
                      subtitle: Text(admin['email'] ?? ''),
                      trailing: ElevatedButton(
                        onPressed: () =>
                            approveAdmin(context, uid),
                        child: const Text("Approve"),
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