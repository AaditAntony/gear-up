import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gear_up/vehicle_owner/pages/booking_page.dart';

class CenterDetailPage extends StatelessWidget {
  final String centerId;
  final Map<String, dynamic> centerData;

  const CenterDetailPage({
    super.key,
    required this.centerId,
    required this.centerData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(centerData['companyName'] ?? "Service Center"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CENTER INFO
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    centerData['companyName'] ?? "",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(centerData['location'] ?? ""),

                  Text(
                    "${centerData['district'] ?? ""}, ${centerData['state'] ?? ""}",
                  ),

                  const SizedBox(height: 10),

                  Text(centerData['description'] ?? ""),
                ],
              ),
            ),

            const Divider(),

            // SERVICES TITLE
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Available Services",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // SERVICES LIST
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('center_services')
                  .where('centerId', isEqualTo: centerId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var services = snapshot.data!.docs;

                if (services.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("No services available."),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    var service = services[index];

                    return ListTile(
                      title: Text(service['categoryName']),
                      subtitle: Text("₹ ${service['price']}"),

                      trailing: ElevatedButton(
                        child: const Text("Book"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookingPage(
                                centerId: centerId,
                                centerName: centerData['companyName'],
                                categoryId: service['categoryId'],
                                categoryName: service['categoryName'],
                                price: (service['price'] as num).toDouble(),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
