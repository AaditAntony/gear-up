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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xfff8fafc),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.memory(
              base64Decode(base64Image),
              height: 200,
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget statusChip(String status) {
    Color color = Colors.orange;

    if (status == "approved") color = Colors.green;
    if (status == "rejected") color = Colors.red;
    if (status == "blocked") color = Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6fb),

      appBar: AppBar(
        title: const Text("Service Center Application Review"),
        elevation: 0,
      ),

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
          String status = data['status'] ?? "pending";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                /// HEADER
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.black.withOpacity(.05),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.store,
                          color: Colors.blue,
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
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
                            const SizedBox(height: 4),
                            Text(
                              "Experience: ${data['experienceYears']} Years",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      statusChip(status),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// MAIN LAYOUT
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// LEFT SIDE INFO
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          sectionTitle("Owner Details"),

                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 3.3,
                            children: [
                              infoTile(
                                Icons.person,
                                "Owner",
                                data['ownerName'] ?? "",
                              ),
                              infoTile(
                                Icons.email,
                                "Email",
                                data['email'] ?? "",
                              ),
                              infoTile(
                                Icons.phone,
                                "Phone",
                                data['phone'] ?? "",
                              ),
                              infoTile(
                                Icons.phone_android,
                                "Alt Phone",
                                data['alternatePhone'] ?? "",
                              ),
                            ],
                          ),

                          const SizedBox(height: 25),

                          sectionTitle("Location"),

                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 3.3,
                            children: [
                              infoTile(
                                Icons.location_on,
                                "Address",
                                data['location'] ?? "",
                              ),
                              infoTile(
                                Icons.map,
                                "District",
                                data['district'] ?? "",
                              ),
                              infoTile(
                                Icons.flag,
                                "State",
                                data['state'] ?? "",
                              ),
                              infoTile(
                                Icons.pin_drop,
                                "Pincode",
                                data['pincode'] ?? "",
                              ),
                            ],
                          ),

                          const SizedBox(height: 25),

                          sectionTitle("Business Information"),

                          infoTile(
                            Icons.receipt,
                            "GST Number",
                            data['gstNumber'] ?? "",
                          ),

                          const SizedBox(height: 15),

                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xfff8fafc),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(data['description'] ?? ""),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 25),

                    /// RIGHT SIDE DOCUMENTS
                    Expanded(
                      child: Column(
                        children: [
                          imagePreview("Business License", data['image1']),
                          const SizedBox(height: 20),
                          imagePreview("Workshop Image", data['image2']),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 35),

                /// ACTION BUTTON BAR
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.black.withOpacity(.05),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () => updateStatus(context, "approved"),
                          child: const Text("Approve"),
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () => updateStatus(context, "rejected"),
                          child: const Text("Reject"),
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () => updateStatus(context, "blocked"),
                          child: const Text("Block"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
