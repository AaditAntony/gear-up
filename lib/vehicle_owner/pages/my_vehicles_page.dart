/// ONLY UI + UX + SMALL UTIL LOGIC ADDED
/// FIREBASE LOGIC NOT CHANGED

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyVehiclesPage extends StatefulWidget {
  const MyVehiclesPage({super.key});

  @override
  State<MyVehiclesPage> createState() => _MyVehiclesPageState();
}

class _MyVehiclesPageState extends State<MyVehiclesPage> {
  final vehicleNumberController = TextEditingController();
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final yearController = TextEditingController();
  final mileageController = TextEditingController();

  String? fuelType;
  DateTime? lastServiceDate;

  Future<void> pickServiceDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => lastServiceDate = picked);
    }
  }

  Future<void> addVehicle() async {
    if (vehicleNumberController.text.isEmpty ||
        brandController.text.isEmpty ||
        modelController.text.isEmpty ||
        yearController.text.isEmpty ||
        mileageController.text.isEmpty ||
        fuelType == null ||
        lastServiceDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    String uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('vehicles').add({
      "userId": uid,
      "vehicleNumber": vehicleNumberController.text.trim(),
      "brand": brandController.text.trim(),
      "model": modelController.text.trim(),
      "fuelType": fuelType,
      "year": int.parse(yearController.text),
      "mileage": int.parse(mileageController.text),
      "lastServiceDate": Timestamp.fromDate(lastServiceDate!),
      "createdAt": Timestamp.now(),
    });

    Navigator.pop(context);
  }

  Future<void> deleteVehicle(String id) async {
    await FirebaseFirestore.instance.collection('vehicles').doc(id).delete();
  }

  /// HEALTH
  int calculateHealth(Map data) {
    int score = 100;

    int year = int.parse(data['year'].toString());
    int mileage = int.parse(data['mileage'].toString());

    DateTime lastService = (data['lastServiceDate'] as Timestamp).toDate();

    int age = DateTime.now().year - year;
    int months = DateTime.now().difference(lastService).inDays ~/ 30;

    if (age >= 5) score -= 25;
    if (mileage >= 40000) score -= 25;
    if (months >= 6) score -= 25;

    return score.clamp(0, 100);
  }

  int monthsSinceService(Timestamp ts) {
    return DateTime.now().difference(ts.toDate()).inDays ~/ 30;
  }

  Color healthColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  /// 🔥 MODERN SHEET (same as before, trimmed for clarity)
  void showAddVehicleSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(16),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Add Vehicle",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              _field(vehicleNumberController, "Vehicle Number"),
              _field(brandController, "Brand"),
              _field(modelController, "Model"),

              DropdownButtonFormField<String>(
                value: fuelType,
                decoration: _inputDecoration("Fuel Type"),
                items: const [
                  DropdownMenuItem(value: "Petrol", child: Text("Petrol")),
                  DropdownMenuItem(value: "Diesel", child: Text("Diesel")),
                  DropdownMenuItem(value: "Electric", child: Text("Electric")),
                  DropdownMenuItem(value: "Hybrid", child: Text("Hybrid")),
                ],
                onChanged: (value) => fuelType = value,
              ),

              const SizedBox(height: 10),

              _field(yearController, "Year"),
              _field(mileageController, "Mileage"),

              ElevatedButton(
                onPressed: pickServiceDate,
                child: const Text("Select Last Service Date"),
              ),

              const SizedBox(height: 10),

              ElevatedButton(onPressed: addVehicle, child: const Text("Save")),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        title: const Text("My Vehicles", style: TextStyle(color: Colors.white)),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2563EB),
        onPressed: showAddVehicleSheet,
        child: const Icon(Icons.add),
      ),

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
            return const Center(child: Text("No vehicles added"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vehicles.length,

            itemBuilder: (context, index) {
              var doc = vehicles[index];
              var data = doc.data() as Map<String, dynamic>;

              int score = calculateHealth(data);
              Color color = healthColor(score);

              int months = monthsSinceService(data['lastServiceDate']);

              bool needsService = months >= 6;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.black.withOpacity(.05),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🚨 WARNING
                    if (needsService)
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "⚠ Service Due",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),

                    /// HEADER
                    Row(
                      children: [
                        const Icon(
                          Icons.directions_car,
                          color: Color(0xFF2563EB),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            data['vehicleNumber'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),

                        Text("$score%", style: TextStyle(color: color)),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text("${data['brand']} ${data['model']}"),

                    const SizedBox(height: 10),

                    LinearProgressIndicator(
                      value: score / 100,
                      color: color,
                      backgroundColor: Colors.grey.shade200,
                    ),

                    const SizedBox(height: 10),

                    Text("Mileage: ${data['mileage']} km"),
                    Text("Last Service: $months months ago"),

                    const SizedBox(height: 10),

                    /// ACTIONS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteVehicle(doc.id),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _field(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(controller: c, decoration: _inputDecoration(label)),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    );
  }
}
////