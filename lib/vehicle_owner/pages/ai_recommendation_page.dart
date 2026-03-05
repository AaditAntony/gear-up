import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AIRecommendationPage extends StatelessWidget {
  const AIRecommendationPage({super.key});

  List<String> generateRecommendations(Map<String, dynamic> vehicle) {
    List<String> recommendations = [];

    int mileage = vehicle['mileage'] ?? 0;
    int lastServiceKm = vehicle['lastServiceKm'] ?? 0;
    int year = vehicle['year'] ?? DateTime.now().year;

    int vehicleAge = DateTime.now().year - year;

    if (mileage - lastServiceKm > 5000) {
      recommendations.add("Oil Change Recommended");
    }

    if (vehicleAge > 3) {
      recommendations.add("Brake Inspection Recommended");
    }

    if (mileage > 20000) {
      recommendations.add("Engine Inspection Recommended");
    }

    if (vehicleAge > 4) {
      recommendations.add("Battery Check Recommended");
    }

    if (mileage - lastServiceKm > 7000) {
      recommendations.add("⚠ Service Overdue");
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

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var vehicles = snapshot.data!.docs;

          if (vehicles.isEmpty) {
            return const Center(
              child: Text("Add a vehicle to get AI recommendations."),
            );
          }

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

                      Text(
                        "Vehicle: ${vehicle['vehicleNumber']}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      if (recommendations.isEmpty)
                        const Text("No maintenance needed right now.")
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: recommendations.map((rec) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                children: [
                                  const Icon(Icons.build, size: 18),
                                  const SizedBox(width: 6),
                                  Text(rec),
                                ],
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