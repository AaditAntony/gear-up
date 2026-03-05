import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AIRecommendationWidget extends StatelessWidget {
  const AIRecommendationWidget({super.key});

  List<String> generateRecommendations(Map<String, dynamic> vehicle) {
    List<String> recommendations = [];

    int mileage = vehicle['mileage'] ?? 0;
    int lastServiceKm = vehicle['lastServiceKm'] ?? 0;
    int year = vehicle['year'] ?? 2024;

    int vehicleAge = DateTime.now().year - year;

    /// Rule 1
    if (mileage - lastServiceKm > 5000) {
      recommendations.add("Oil Change Recommended");
    }

    /// Rule 2
    if (vehicleAge > 3) {
      recommendations.add("Brake Inspection Recommended");
    }

    /// Rule 3
    if (mileage > 20000) {
      recommendations.add("Engine Inspection Recommended");
    }

    /// Rule 4
    if (vehicleAge > 4) {
      recommendations.add("Battery Check Recommended");
    }

    return recommendations;
  }

  @override
  Widget build(BuildContext context) {

    String userId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('vehicles')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var vehicles = snapshot.data!.docs;

        if (vehicles.isEmpty) {
          return const Text("No vehicles added.");
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "AI Maintenance Recommendations",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ...vehicles.map((doc) {

              var vehicle = doc.data() as Map<String, dynamic>;

              List<String> recommendations =
                  generateRecommendations(vehicle);

              if (recommendations.isEmpty) {
                return const SizedBox();
              }

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        "Vehicle: ${vehicle['vehicleNumber']}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      ...recommendations.map((rec) => Row(
                        children: [
                          const Icon(Icons.build, size: 18),
                          const SizedBox(width: 6),
                          Text(rec),
                        ],
                      )),

                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}