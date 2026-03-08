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

    /// GET USER
    var userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    String district = userDoc['district'];

    /// GET VEHICLE
    var vehicleSnap = await FirebaseFirestore.instance
        .collection('vehicles')
        .where('userId', isEqualTo: uid)
        .limit(1)
        .get();

    if (vehicleSnap.docs.isEmpty) return;

    var vehicle = vehicleSnap.docs.first.data();

    int year = int.parse(vehicle['year'].toString());
    int age = DateTime.now().year - year;

    String recommendedService;

    if (age >= 5) {
      recommendedService = "battery replacement";
    } else if (age >= 3) {
      recommendedService = "brake service";
    } else {
      recommendedService = "oil change";
    }

    fullText =
        "Your vehicle is $age years old.\n\nRecommended service: ${recommendedService.toUpperCase()}.";

    await typeText();

    await loadCenters(recommendedService, district);
  }

  Future<void> typeText() async {
    for (int i = 0; i < fullText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 35));

      if (!mounted) return;

      setState(() {
        aiText += fullText[i];
      });
    }
  }

  Future<void> loadCenters(String service, String district) async {
    /// FIND SERVICES
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

              Text(aiText, style: const TextStyle(fontSize: 16)),

              const SizedBox(height: 30),

              if (centers.isNotEmpty) ...[
                const Text(
                  "Best Centers Near You",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: ListView(children: centers.map(buildCenter).toList()),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
