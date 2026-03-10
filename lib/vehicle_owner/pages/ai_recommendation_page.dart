import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'booking_page.dart';

class AIRecommendationPage extends StatefulWidget {
  const AIRecommendationPage({super.key});

  @override
  State<AIRecommendationPage> createState() => _AIRecommendationPageState();
}

class _AIRecommendationPageState extends State<AIRecommendationPage> {
  bool isThinking = true;

  String aiSummary = "";

  List<Map<String, dynamic>> vehicles = [];
  List<Map<String, dynamic>> services = [];
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

  Future<void> typeSummary(String text) async {
    for (int i = 0; i < text.length; i++) {
      await Future.delayed(const Duration(milliseconds: 25));

      if (!mounted) return;

      setState(() {
        aiSummary += text[i];
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

    List<String> recommendations = [];

    String summaryText = "Analyzing your vehicles...\n\n";

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

      vehicles.add({
        "vehicleNumber": data['vehicleNumber'],
        "brand": data['brand'],
        "model": data['model'],
        "age": age,
        "mileage": mileage,
        "health": health,
      });

      summaryText += "Vehicle ${data['vehicleNumber']} analyzed.\n";

      if (age >= 5) recommendations.add("Battery Replacement");

      if (mileage >= 40000) recommendations.add("Brake Service");

      if (monthsSinceService >= 6) recommendations.add("Oil Change");

      if (age >= 8) recommendations.add("Engine Check");
    }

    if (recommendations.isEmpty) {
      recommendations.add("General Inspection");
    }

    summaryText += "\nMaintenance recommendations generated.\n";

    await typeSummary(summaryText);

    for (var service in recommendations.toSet()) {
      var category = await FirebaseFirestore.instance
          .collection('service_categories')
          .where('name', isEqualTo: service)
          .limit(1)
          .get();

      double price = 0;
      String categoryId = "";

      if (category.docs.isNotEmpty) {
        price = (category.docs.first['basePrice'] as num).toDouble();
        categoryId = category.docs.first.id;
      }

      services.add({"name": service, "price": price, "id": categoryId});
    }

    if (services.isNotEmpty) {
      var service = services.first['name'];

      var serviceDocs = await FirebaseFirestore.instance
          .collection('center_services')
          .where('categoryName', isEqualTo: service)
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

        centers = centerDocs.docs.map((e) => e.data()).toList();

        centers.sort(
          (a, b) => (b['avgRating'] ?? 0).compareTo(a['avgRating'] ?? 0),
        );
      }
    }

    setState(() {});
  }

  Widget vehicleCard(Map vehicle) {
    Color color;

    if (vehicle['health'] == "Good") {
      color = Colors.green;
    } else if (vehicle['health'] == "Moderate") {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Card(
      child: ListTile(
        title: Text(vehicle['vehicleNumber']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${vehicle['brand']} ${vehicle['model']}"),
            Text("Age: ${vehicle['age']} years"),
            Text("Mileage: ${vehicle['mileage']} km"),
          ],
        ),
        trailing: Text(
          vehicle['health'],
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget serviceCard(Map service) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.build),

        title: Text(service['name']),

        subtitle: Text("Estimated Cost: ₹${service['price']}"),

        trailing: const Icon(Icons.arrow_forward_ios),

        onTap: () {
          if (centers.isEmpty) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookingPage(
                centerId: centers.first['centerId'],
                centerName: centers.first['companyName'],
                categoryId: service['id'],
                categoryName: service['name'],
                price: service['price'],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget centerCard(Map center) {
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

      body: isThinking
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),

                  SizedBox(height: 20),

                  Text(
                    "AI is analyzing your vehicles...",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),

              child: ListView(
                children: [
                  Text(aiSummary, style: const TextStyle(fontSize: 16)),

                  const SizedBox(height: 20),

                  const Text(
                    "Vehicle Health",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  ...vehicles.map(vehicleCard),

                  const SizedBox(height: 20),

                  const Text(
                    "Recommended Services",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  ...services.map(serviceCard),

                  const SizedBox(height: 20),

                  if (centers.isNotEmpty) ...[
                    const Text(
                      "Top Service Centers",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    ...centers.take(3).map(centerCard),
                  ],
                ],
              ),
            ),
    );
  }
}
