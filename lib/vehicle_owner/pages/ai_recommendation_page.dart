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

      int year = int.tryParse(data['year']?.toString() ?? '0') ?? 0;
      int mileage = int.tryParse(data['mileage']?.toString() ?? '0') ?? 0;

      Timestamp? serviceTimestamp = data['lastServiceDate'] as Timestamp?;
      DateTime lastService = serviceTimestamp?.toDate() ?? DateTime.now();

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
      color = const Color(0xFF10B981);
    } else if (vehicle['health'] == "Moderate") {
      color = const Color(0xFFF59E0B);
    } else {
      color = const Color(0xFFEF4444);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.directions_car_rounded, color: Color(0xFF2563EB), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle['vehicleNumber'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2563EB),
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        "${vehicle['brand']} ${vehicle['model']}",
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Text(
                    vehicle['health'].toUpperCase(),
                    style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// STATS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statItem("Age", "${vehicle['age']} Yrs"),
                    _statItem("Mileage", "${vehicle['mileage']} Km"),
                    _statItem("Score", "${vehicle['score']}/100", isScore: true),
                  ],
                ),

                const SizedBox(height: 24),

                /// RECOMMENDATIONS
                const Text(
                  "RECOMMENDED SERVICES",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: vehicle['recommendations']
                      .map<Widget>(
                        (service) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            service,
                            style: const TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 24),

                /// CENTERS
                if (vehicle['centers'].isNotEmpty) ...[
                  const Text(
                    "TOP SERVICE CENTERS",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...vehicle['centers'].take(3).map<Widget>((center) {
                    double rating = (center['avgRating'] ?? 0).toDouble();
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.store_rounded, color: Color(0xFF2563EB), size: 20),
                      ),
                      title: Text(
                        center['companyName'],
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF2563EB)),
                      ),
                      subtitle: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFCBD5E1)),
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
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, {bool isScore = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: isScore ? const Color(0xFF2563EB) : const Color(0xFF2563EB),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "AI Vehicle Assistant",
          style: TextStyle(
            color: Color(0xFF2563EB),
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2563EB), size: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: isThinking
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20),
                    ]),
                    child: const CircularProgressIndicator(color: Color(0xFF2563EB), strokeWidth: 5),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "AI Analysis in Progress...",
                    style: TextStyle(color: Color(0xFF2563EB), fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Reviewing your vehicle records",
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
              children: [
                /// AI TEXT BOX
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: Color(0xFF60A5FA), size: 20),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          aiText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.6,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                ...vehicles.map(buildVehicle),
              ],
            ),
    );
  }
}
////