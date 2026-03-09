import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApproveAdminsPage extends StatelessWidget {
  const ApproveAdminsPage({super.key});

  Future<void> approveAdmin(BuildContext context, String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'isApproved': true,
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Admin approved successfully.")),
      );
    } catch (e) {
      debugPrint("APPROVE ADMIN ERROR: $e");

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to approve admin.")));
    }
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
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No pending admin approvals."));
              }

              var admins = snapshot.data!.docs;

              return ListView.builder(
                itemCount: admins.length,
                itemBuilder: (context, index) {
                  var admin = admins[index];
                  String uid = admin.id;

                  Map<String, dynamic> data =
                      admin.data() as Map<String, dynamic>;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(data['name'] ?? "No Name"),
                      subtitle: Text(data['email'] ?? "No Email"),

                      trailing: ElevatedButton(
                        onPressed: () {
                          approveAdmin(context, uid);
                        },
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
