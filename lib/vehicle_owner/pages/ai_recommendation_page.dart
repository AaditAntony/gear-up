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

    /// VEHICLES

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

      List<String> healthIssues = [];

      int healthScore = 100;

      /// AGE IMPACT

      if (age >= 5) {
        healthScore -= 15;
        healthIssues.add("Vehicle age is high");
        recommendations.add("Battery Replacement");
      }

      /// MILEAGE IMPACT

      if (mileage >= 40000) {
        healthScore -= 15;
        healthIssues.add("High mileage detected");
        recommendations.add("Brake Service");
      }

      if (mileage >= 60000) {
        healthScore -= 10;
        recommendations.add("Clutch Inspection");
      }

      /// SERVICE INTERVAL

      if (monthsSinceService >= 6) {
        healthScore -= 10;
        healthIssues.add("Last service overdue");
        recommendations.add("Oil Change");
      }

      /// LAST COMPLAINT

      var bookingSnap = await FirebaseFirestore.instance
          .collection('bookings')
          .where('vehicleNumber', isEqualTo: vehicleNumber)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (bookingSnap.docs.isNotEmpty) {
        var booking = bookingSnap.docs.first.data();

        String complaint = booking['complaint'] ?? "";

        if (complaint == "Engine Noise") {
          healthScore -= 10;
          healthIssues.add("Engine noise reported");
          recommendations.add("Engine Inspection");
        }

        if (complaint == "Brake Noise") {
          healthScore -= 10;
          healthIssues.add("Brake noise reported");
          recommendations.add("Brake Pad Replacement");
        }

        if (complaint == "Battery Drain") {
          healthScore -= 10;
          healthIssues.add("Battery drain issue");
          recommendations.add("Battery Replacement");
        }

        if (complaint == "Vibration") {
          healthScore -= 5;
          healthIssues.add("Vehicle vibration detected");
          recommendations.add("Wheel Alignment");
        }

        if (complaint == "Oil Leakage") {
          healthScore -= 10;
          healthIssues.add("Oil leakage issue");
          recommendations.add("Engine Oil Seal Check");
        }

        if (complaint == "Low Mileage") {
          healthScore -= 5;
          recommendations.add("Engine Tune-up");
        }

        if (complaint == "Engine Overheating") {
          healthScore -= 10;
          recommendations.add("Coolant System Check");
        }
      }

      if (healthScore < 0) healthScore = 0;

      /// DEFAULT

      if (recommendations.isEmpty) {
        recommendations.add("General Inspection");
      }

      /// BUILD AI TEXT

      fullText += "\nVehicle: $vehicleNumber ($brand $model)\n\n";

      fullText += "Vehicle Health Score: $healthScore%\n\n";

      if (healthIssues.isNotEmpty) {
        fullText += "Issues Detected:\n";

        for (var issue in healthIssues) {
          fullText += "• $issue\n";
        }

        fullText += "\n";
      }

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
      await Future.delayed(const Duration(milliseconds: 30));

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
