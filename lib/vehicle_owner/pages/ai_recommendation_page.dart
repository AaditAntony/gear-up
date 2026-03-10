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

    var userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    String district = userDoc['district'];

    var vehicleSnap = await FirebaseFirestore.instance
        .collection('vehicles')
        .where('userId', isEqualTo: uid)
        .get();

    if (vehicleSnap.docs.isEmpty) return;

    List<String> finalRecommendations = [];

    fullText += "AI Vehicle Health Report\n";
    fullText += "--------------------------------\n\n";

    for (var doc in vehicleSnap.docs) {
      var vehicle = doc.data();

      String vehicleNumber = vehicle['vehicleNumber'];
      String brand = vehicle['brand'];
      String model = vehicle['model'];

      int year = int.parse(vehicle['year'].toString());
      int mileage = int.parse(vehicle['mileage'].toString());

      Timestamp serviceTimestamp = vehicle['lastServiceDate'];
      DateTime lastServiceDate = serviceTimestamp.toDate();

      int age = DateTime.now().year - year;

      int monthsSinceService =
          DateTime.now().difference(lastServiceDate).inDays ~/ 30;

      int healthScore = 100;

      if (age >= 5) healthScore -= 25;
      if (mileage >= 40000) healthScore -= 25;
      if (monthsSinceService >= 6) healthScore -= 25;

      String healthStatus;

      if (healthScore >= 80) {
        healthStatus = "GOOD";
      } else if (healthScore >= 50) {
        healthStatus = "MODERATE";
      } else {
        healthStatus = "NEEDS ATTENTION";
      }

      fullText += "Vehicle: $vehicleNumber ($brand $model)\n\n";

      fullText += "Age: $age years\n";
      fullText += "Mileage: $mileage km\n";
      fullText += "Last Service: $monthsSinceService months ago\n\n";

      fullText += "Vehicle Health: $healthStatus\n";

      fullText += "\n--------------------------------\n\n";

      if (age >= 5) finalRecommendations.add("Battery Replacement");

      if (mileage >= 40000) finalRecommendations.add("Brake Service");

      if (monthsSinceService >= 6) finalRecommendations.add("Oil Change");

      if (age >= 8) finalRecommendations.add("Engine Check");
    }

    if (finalRecommendations.isEmpty) {
      finalRecommendations.add("General Inspection");
    }

    fullText += "Recommended Services\n\n";

    for (var service in finalRecommendations.toSet()) {
      fullText += "• $service\n";
    }

    fullText += "\n";

    await typeText();

    await loadCenters(finalRecommendations.first, district);
  }

  Future<void> typeText() async {
    for (int i = aiText.length; i < fullText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 30));

      if (!mounted) return;

      setState(() {
        aiText += fullText[i];
      });
    }
  }

  Future<void> loadCenters(String service, String district) async {
    /// FIND SERVICES OFFERED BY CENTERS

    var services = await FirebaseFirestore.instance
        .collection('center_services')
        .where('categoryName', isEqualTo: service)
        .get();

    if (services.docs.isEmpty) return;

    List<String> centerIds = services.docs
        .map((e) => e['centerId'] as String)
        .toList();

    /// GET CENTER DETAILS

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
                  "Top Service Centers Near You",
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
