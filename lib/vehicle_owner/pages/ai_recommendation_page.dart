import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AIRecommendationPage extends StatefulWidget {
  const AIRecommendationPage({super.key});

  @override
  State<AIRecommendationPage> createState() => _AIRecommendationPageState();
}

class _AIRecommendationPageState extends State<AIRecommendationPage> {
  String introText = "";
  String fullIntro =
      "Hello! I analyzed your vehicle data and generated maintenance recommendations.";

  @override
  void initState() {
    super.initState();
    startTyping();
  }

  Future<void> startTyping() async {
  for (int i = 0; i < fullIntro.length; i++) {

    await Future.delayed(const Duration(milliseconds: 35));

    if (!mounted) return;

    setState(() {
      introText += fullIntro[i];
    });
  }
}

  List<Map<String, String>> generateRecommendations(
    Map<String, dynamic> vehicle,
  ) {
    List<Map<String, String>> recs = [];

    int mileage = int.tryParse(vehicle['mileage'].toString()) ?? 0;
    int lastServiceKm = int.tryParse(vehicle['lastServiceKm'].toString()) ?? 0;
    int year = int.tryParse(vehicle['year'].toString()) ?? DateTime.now().year;

    int vehicleAge = DateTime.now().year - year;
    int distance = mileage - lastServiceKm;

    if (distance > 5000) {
      recs.add({
        "title": "Oil Change Required",
        "reason": "Vehicle travelled $distance km since last service.",
      });
    }

    if (vehicleAge > 3) {
      recs.add({
        "title": "Brake Inspection Suggested",
        "reason": "Vehicle is $vehicleAge years old.",
      });
    }

    if (mileage > 20000) {
      recs.add({
        "title": "Engine Inspection Recommended",
        "reason": "Vehicle mileage exceeded 20,000 km.",
      });
    }

    if (vehicleAge > 4) {
      recs.add({
        "title": "Battery Check Recommended",
        "reason": "Battery efficiency may reduce after 4 years.",
      });
    }

    return recs;
  }

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("AI Assistant")),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('vehicles')
            .where('userId', isEqualTo: uid)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var vehicles = snapshot.data!.docs;

          if (vehicles.isEmpty) {
            return const Center(
              child: Text("Add a vehicle to get AI recommendations"),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              /// AI intro message
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.smart_toy, color: Colors.blue),

                    const SizedBox(width: 10),

                    Expanded(child: Text(introText)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// Vehicle recommendations
              ...vehicles.map((doc) {
                var vehicle = doc.data() as Map<String, dynamic>;

                var recs = generateRecommendations(vehicle);

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(14),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Vehicle: ${vehicle['vehicleNumber']}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        if (recs.isEmpty)
                          const Text(
                            "No maintenance required right now.",
                            style: TextStyle(color: Colors.green),
                          )
                        else
                          Column(
                            children: recs.map((rec) {
                              return Card(
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.warning,
                                    color: Colors.orange,
                                  ),
                                  title: Text(rec["title"]!),
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
