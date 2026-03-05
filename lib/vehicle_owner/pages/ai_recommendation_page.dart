import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AIRecommendationPage extends StatelessWidget {
  const AIRecommendationPage({super.key});

  List<Map<String, String>> generateRecommendations(
    Map<String, dynamic> vehicle,
  ) {
    List<Map<String, String>> recommendations = [];

    int mileage = int.tryParse(vehicle['mileage'].toString()) ?? 0;
    int lastServiceKm = int.tryParse(vehicle['lastServiceKm'].toString()) ?? 0;
    int year = int.tryParse(vehicle['year'].toString()) ?? DateTime.now().year;

    int vehicleAge = DateTime.now().year - year;
    int distanceSinceService = mileage - lastServiceKm;

    if (distanceSinceService > 5000) {
      recommendations.add({
        "title": "Oil Change Required",
        "reason":
            "Vehicle travelled $distanceSinceService km since last service.",
      });
    }

    if (vehicleAge > 3) {
      recommendations.add({
        "title": "Brake Inspection Suggested",
        "reason": "Vehicle is $vehicleAge years old.",
      });
    }

    if (mileage > 20000) {
      recommendations.add({
        "title": "Engine Inspection Recommended",
        "reason": "Vehicle mileage exceeded 20,000 km.",
      });
    }

    if (vehicleAge > 4) {
      recommendations.add({
        "title": "Battery Check Recommended",
        "reason": "Vehicle battery performance may degrade after 4 years.",
      });
    }

    if (distanceSinceService > 7000) {
      recommendations.add({
        "title": "Service Overdue",
        "reason": "Vehicle exceeded recommended service interval.",
      });
    }

    return recommendations;
  }

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("AI Maintenance Assistant")),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('vehicles')
            .where('userId', isEqualTo: userId)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Add a vehicle to receive AI recommendations."),
            );
          }

          var vehicles = snapshot.data!.docs;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              /// AI HEADER
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.smart_toy, size: 40, color: Colors.blue),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Your AI assistant analyzes vehicle data and recommends maintenance before problems occur.",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// VEHICLE LIST
              ...vehicles.map((doc) {
                var vehicle = doc.data() as Map<String, dynamic>;

                int mileage = int.tryParse(vehicle['mileage'].toString()) ?? 0;

                int lastService =
                    int.tryParse(vehicle['lastServiceKm'].toString()) ?? 0;

                int year =
                    int.tryParse(vehicle['year'].toString()) ??
                    DateTime.now().year;

                var recommendations = generateRecommendations(vehicle);

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// VEHICLE TITLE
                        Text(
                          "Vehicle: ${vehicle['vehicleNumber']}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        /// VEHICLE DETAILS
                        Text(
                          "${vehicle['brand']} ${vehicle['model']}",
                          style: const TextStyle(color: Colors.grey),
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Text("Mileage: $mileage km"),
                            const SizedBox(width: 20),
                            Text("Last Service: $lastService km"),
                          ],
                        ),

                        const SizedBox(height: 15),

                        /// AI RESULTS
                        if (recommendations.isEmpty)
                          const Text(
                            "No maintenance needed right now.",
                            style: TextStyle(color: Colors.green),
                          )
                        else
                          Column(
                            children: recommendations.map((rec) {
                              return Card(
                                color: Colors.orange.shade50,
                                margin: const EdgeInsets.symmetric(vertical: 5),

                                child: ListTile(
                                  leading: const Icon(
                                    Icons.warning_amber,
                                    color: Colors.orange,
                                  ),

                                  title: Text(
                                    rec["title"]!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  subtitle: Text(rec["reason"]!),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
