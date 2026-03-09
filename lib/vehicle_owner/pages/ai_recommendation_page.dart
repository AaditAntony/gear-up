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

  String aiText = "";
  String fullText = "";

  List<Map<String, dynamic>> centers = [];

  @override
  void initState() {
    super.initState();
    startAI();
  }

  Future<void> startAI() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      isThinking = false;
    });

    await runAI();
  }

  Future<void> runAI() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    /// USER DATA
    var userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    String district = userDoc['district'];

    /// GET ALL VEHICLES
    var vehicleSnap = await FirebaseFirestore.instance
        .collection('vehicles')
        .where('userId', isEqualTo: uid)
        .get();

    if (vehicleSnap.docs.isEmpty) return;

    for (var doc in vehicleSnap.docs) {
      var vehicle = doc.data();

      String vehicleNumber = vehicle['vehicleNumber'];
      String brand = vehicle['brand'];
      String model = vehicle['model'];

      int year = vehicle['year'];
      int mileage = vehicle['mileage'];

      Timestamp serviceTimestamp = vehicle['lastServiceDate'];
      DateTime lastServiceDate = serviceTimestamp.toDate();

      int age = DateTime.now().year - year;

      int monthsSinceService =
          DateTime.now().difference(lastServiceDate).inDays ~/ 30;

      List<String> recommendations = [];

      /// AI RULES

      if (age >= 5) {
        recommendations.add("Battery Replacement");
      }

      if (mileage >= 40000) {
        recommendations.add("Brake Service");
      }

      if (monthsSinceService >= 6) {
        recommendations.add("Oil Change");
      }

      if (recommendations.isEmpty) {
        recommendations.add("General Inspection");
      }

      fullText += "\nVehicle: $vehicleNumber ($brand $model)\n\n";

      fullText += "Age: $age years\nMileage: $mileage km\n\n";

      fullText += "Recommended Services:\n";

      for (var service in recommendations) {
        fullText += "• $service\n";
      }

      fullText += "\n";

      await typeText();

      await loadCenters(recommendations.first, district);
    }
  }

  Future<void> typeText() async {
    for (int i = aiText.length; i < fullText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 25));

      if (!mounted) return;

      setState(() {
        aiText += fullText[i];
      });
    }
  }

  Future<void> loadCenters(String service, String district) async {
    var services = await FirebaseFirestore.instance
        .collection('center_services')
        .where('categoryName', isEqualTo: service.trim())
        .get();

    if (services.docs.isEmpty) return;

    List<String> centerIds = services.docs
        .map((e) => e['centerId'] as String)
        .toList();

    var centerDocs = await FirebaseFirestore.instance
        .collection('service_center_details')
        .where(FieldPath.documentId, whereIn: centerIds)
        .where('district', isEqualTo: district)
        .get();

    List<Map<String, dynamic>> list = centerDocs.docs
        .map((e) => e.data())
        .toList();

    /// SORT BY RATING

    list.sort((a, b) => (b['avgRating'] ?? 0).compareTo(a['avgRating'] ?? 0));

    centers = list.take(3).toList();

    if (mounted) {
      setState(() {});
    }
  }

  Widget buildCenter(Map<String, dynamic> center) {
    double rating = (center['avgRating'] ?? 0).toDouble();

    return Card(
      child: ListTile(
        leading: const Icon(Icons.star, color: Colors.amber),
        title: Text(center['companyName']),
        subtitle: Text("Rating: ${rating.toStringAsFixed(1)}"),
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
                    Text("AI is analyzing your vehicles..."),
                  ],
                ),
              )
            else ...[
              const Text(
                "AI Recommendation",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: Text(aiText, style: const TextStyle(fontSize: 16)),
                ),
              ),

              if (centers.isNotEmpty) ...[
                const SizedBox(height: 20),

                const Text(
                  "Top Service Centers",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                ...centers.map(buildCenter),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
