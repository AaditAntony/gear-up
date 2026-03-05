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
              child: Text("Add a vehicle to get AI recommendations."),
            );
          }

          var vehicles = snapshot.data!.docs;

          return ListView.builder(
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              var vehicle = vehicles[index].data() as Map<String, dynamic>;

              var recommendations = generateRecommendations(vehicle);

              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(14),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Vehicle title
                      Text(
                        "Vehicle: ${vehicle['vehicleNumber']}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// No recommendations
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
                              margin: const EdgeInsets.symmetric(vertical: 6),

                              child: ListTile(
                                leading: const Icon(
                                  Icons.smart_toy,
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
            },
          );
        },
      ),
    );
  }
}
