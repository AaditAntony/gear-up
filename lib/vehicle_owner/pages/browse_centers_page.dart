import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BrowseCentersPage extends StatelessWidget {
  const BrowseCentersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Service Centers")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('service_center_details')
            .where('status', isEqualTo: 'approved')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No service centers available."));
          }

          var centers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: centers.length,
            itemBuilder: (context, index) {
              var data = centers[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(
                    data['companyName'] ?? "Service Center",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['location'] ?? ""),

                      Text("${data['district'] ?? ""}, ${data['state'] ?? ""}"),

                      const SizedBox(height: 4),

                      Text(
                        data['description'] ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  trailing: const Icon(Icons.arrow_forward_ios),

                  onTap: () {
                    // Next step we will open center details page
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
