import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'center_detail_page.dart';

class AIRecommendationPage extends StatefulWidget {
  const AIRecommendationPage({super.key});

  @override
  State<AIRecommendationPage> createState() => _AIRecommendationPageState();
}

class _AIRecommendationPageState extends State<AIRecommendationPage> {
  bool isThinking = true;

  String aiText = "";

  List<Map<String, dynamic>> vehicles = [];

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

  Future<void> typeText(String text) async {
    for (int i = 0; i < text.length; i++) {
      await Future.delayed(const Duration(milliseconds: 20));

      if (!mounted) return;

      setState(() {
        aiText += text[i];
      });
    }
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

    for (var doc in vehicleSnap.docs) {
      var data = doc.data();

      int year = int.parse(data['year'].toString());
      int mileage = int.parse(data['mileage'].toString());

      Timestamp serviceTimestamp = data['lastServiceDate'];
      DateTime lastService = serviceTimestamp.toDate();

      int age = DateTime.now().year - year;

      int monthsSinceService =
          DateTime.now().difference(lastService).inDays ~/ 30;

      int healthScore = 100;

      if (age >= 5) healthScore -= 25;
      if (mileage >= 40000) healthScore -= 25;
      if (monthsSinceService >= 6) healthScore -= 25;

      String health;

      if (healthScore >= 80) {
        health = "Good";
      } else if (healthScore >= 50) {
        health = "Moderate";
      } else {
        health = "Needs Attention";
      }

      List<String> recommendations = [];

      if (age >= 5) recommendations.add("Battery Replacement");
      if (mileage >= 40000) recommendations.add("Brake Service");
      if (monthsSinceService >= 6) recommendations.add("Oil Change");
      if (age >= 8) recommendations.add("Engine Check");

      if (recommendations.isEmpty) {
        recommendations.add("General Inspection");
      }

      List<Map<String, dynamic>> vehicleCenters = [];

      var serviceDocs = await FirebaseFirestore.instance
          .collection('center_services')
          .where('categoryName', isEqualTo: recommendations.first)
          .get();

      List<String> centerIds = serviceDocs.docs
          .map((e) => e['centerId'] as String)
          .toList();

      if (centerIds.isNotEmpty) {
        var centerDocs = await FirebaseFirestore.instance
            .collection('service_center_details')
            .where(FieldPath.documentId, whereIn: centerIds)
            .where('district', isEqualTo: district)
            .get();

        vehicleCenters = centerDocs.docs.map((doc) {
          var centerData = doc.data();
          centerData['uid'] = doc.id;

          return centerData;
        }).toList();

        vehicleCenters.sort(
          (a, b) => (b['avgRating'] ?? 0).compareTo(a['avgRating'] ?? 0),
        );
      }

      vehicles.add({
        "vehicleNumber": data['vehicleNumber'],
        "brand": data['brand'],
        "model": data['model'],
        "age": age,
        "mileage": mileage,
        "health": health,
        "score": healthScore,
        "recommendations": recommendations,
        "centers": vehicleCenters,
      });

      await typeText("Analyzing vehicle ${data['vehicleNumber']}...\n");
    }

    await typeText("\nAI analysis completed.\n\n");

    if (mounted) setState(() {});
  }

  Widget buildVehicle(Map<String, dynamic> vehicle) {
    Color color;

    if (vehicle['health'] == "Good") {
      color = Colors.green;
    } else if (vehicle['health'] == "Moderate") {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vehicle['vehicleNumber'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text("${vehicle['brand']} ${vehicle['model']}"),

            const SizedBox(height: 8),

            Text("Age: ${vehicle['age']} years"),
            Text("Mileage: ${vehicle['mileage']} km"),

            const SizedBox(height: 8),

            Row(
              children: [
                const Text("Health: "),

                Text(
                  vehicle['health'],
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),

                const SizedBox(width: 10),

                Text("Score ${vehicle['score']}/100"),
              ],
            ),

            const SizedBox(height: 14),

            const Text(
              "Recommended Services",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            ...vehicle['recommendations'].map<Widget>((service) {
              return ListTile(
                leading: const Icon(Icons.build),
                title: Text(service),
              );
            }).toList(),

            const SizedBox(height: 10),

            if (vehicle['centers'].isNotEmpty) ...[
              const Text(
                "Top Service Centers",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              ...vehicle['centers'].take(3).map<Widget>((center) {
                double rating = (center['avgRating'] ?? 0).toDouble();

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.store, color: Colors.blue),

                    title: Text(center['companyName']),

                    subtitle: Text("Rating ${rating.toStringAsFixed(1)}"),

                    trailing: const Icon(Icons.arrow_forward_ios),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CenterDetailPage(
                            centerId: center['uid'],
                            centerData: Map<String, dynamic>.from(center),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Vehicle Assistant")),

      body: isThinking
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("AI is analyzing your vehicles..."),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  Text(aiText, style: const TextStyle(fontSize: 16)),

                  const SizedBox(height: 20),

                  ...vehicles.map(buildVehicle),
                ],
              ),
            ),
    );
  }
}
