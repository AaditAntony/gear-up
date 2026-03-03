import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'view_service_center_detail_page.dart';

class ApproveServiceCentersPage extends StatelessWidget {
  const ApproveServiceCentersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          "Service Center Applications",
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 20),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('service_center_details')
                .where('status', isEqualTo: 'pending')
                .snapshots(),
            builder: (context, snapshot) {

              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator());
              }

              if (!snapshot.hasData ||
                  snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text("No pending applications."),
                );
              }

              var centers = snapshot.data!.docs;

              return ListView.builder(
                itemCount: centers.length,
                itemBuilder: (context, index) {

                  var center = centers[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8),
                    child: ListTile(
                      title: Text(
                          center['companyName'] ?? "N/A"),
                      subtitle: Text(
                          "${center['district'] ?? ""}, ${center['state'] ?? ""}"),
                      trailing: ElevatedButton(
                        child: const Text("View Details"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ViewServiceCenterDetailPage(
                                      centerId: center.id),
                            ),
                          );
                        },
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