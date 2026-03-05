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
  List<Map<String, String>> visibleRecommendations = [];

  String fullIntro =
      "Hello! I analyzed your vehicle data and generated maintenance recommendations.";

  @override
  void initState() {
    super.initState();
  }

  Future<void> typeIntro() async {
    for (int i = 0; i < fullIntro.length; i++) {
      await Future.delayed(const Duration(milliseconds: 25));

      setState(() {
        introText += fullIntro[i];
      });
    }
  }

  Future<void> showRecommendations(List<Map<String, String>> recs) async {
    for (var rec in recs) {
      await Future.delayed(const Duration(milliseconds: 600));

      setState(() {
        visibleRecommendations.add(rec);
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

          if (introText.isEmpty) {
            typeIntro();
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              /// AI intro chat
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

              ...vehicles.map((doc) {
                var vehicle = doc.data() as Map<String, dynamic>;

                var recs = generateRecommendations(vehicle);

                if (visibleRecommendations.isEmpty) {
                  showRecommendations(recs);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Vehicle: ${vehicle['vehicleNumber']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 10),

                    ...visibleRecommendations.map((rec) {
                      return Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.warning,
                            color: Colors.orange,
                          ),
                          title: Text(rec['title']!),
                          subtitle: Text(rec['reason']!),
                        ),
                      );
                    }).toList(),
                  ],
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
