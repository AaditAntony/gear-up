import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AIRecommendationPage extends StatefulWidget {
  const AIRecommendationPage({super.key});

  @override
  State<AIRecommendationPage> createState() => _AIRecommendationPageState();
}

class _AIRecommendationPageState extends State<AIRecommendationPage> {
  bool isThinking = true;

  String typedText = "";

  String finalText = "";

  List<Map<String, dynamic>> recommendedCenters = [];

  @override
  void initState() {
    super.initState();
    runAI();
  }

  Future<void> runAI() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      isThinking = false;
    });

    await generateRecommendation();
  }

  Future<void> generateRecommendation() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    /// Get user profile
    var userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    String district = userDoc['district'];

    /// Get vehicle
    var vehicleSnapshot = await FirebaseFirestore.instance
        .collection('vehicles')
        .where('userId', isEqualTo: uid)
        .limit(1)
        .get();

    if (vehicleSnapshot.docs.isEmpty) return;

    var vehicle = vehicleSnapshot.docs.first.data();

    int year = int.parse(vehicle['year'].toString());

    int vehicleAge = DateTime.now().year - year;

    String recommendation;

    if (vehicleAge >= 5) {
      recommendation =
          "Your vehicle is $vehicleAge years old.\n\nBattery check and brake inspection are recommended.";
    } else if (vehicleAge >= 3) {
      recommendation =
          "Your vehicle is $vehicleAge years old.\n\nOil change and brake inspection are recommended.";
    } else {
      recommendation =
          "Your vehicle is $vehicleAge years old.\n\nRegular oil change is recommended.";
    }

    finalText = recommendation;

    await typeText();

    await loadRecommendedCenters(district);
  }

  Future<void> typeText() async {
    for (int i = 0; i < finalText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 40));

      if (!mounted) return;

      setState(() {
        typedText += finalText[i];
      });
    }
  }

  Future<void> loadRecommendedCenters(String district) async {
    var centers = await FirebaseFirestore.instance
        .collection('service_center_details')
        .where('district', isEqualTo: district)
        .orderBy('avgRating', descending: true)
        .limit(3)
        .get();

    recommendedCenters = centers.docs.map((e) => e.data()).toList();

    if (mounted) {
      setState(() {});
    }
  }

  Widget buildCenterCard(Map<String, dynamic> center) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.star, color: Colors.amber),
        title: Text(center['companyName']),
        subtitle: Text("Rating: ${center['avgRating'] ?? 0}"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Vehicle Assistant")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            if (isThinking)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text("AI is analyzing your vehicle..."),
                  ],
                ),
              )
            else ...[
              const Text(
                "AI Recommendation",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              Text(typedText, style: const TextStyle(fontSize: 16)),

              const SizedBox(height: 30),

              const Text(
                "Best Service Centers Near You",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: ListView(
                  children: recommendedCenters.map(buildCenterCard).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
