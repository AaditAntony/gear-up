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
      setState(() {
        lastServiceDate = picked;
      });
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

    vehicleNumberController.clear();
    brandController.clear();
    modelController.clear();
    yearController.clear();
    mileageController.clear();
  }

  void showAddVehicleDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          title: const Text(
            "Add Vehicle",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          content: SingleChildScrollView(
            child: Column(
              children: [
                _field(vehicleNumberController, "Vehicle Number"),
                _field(brandController, "Brand"),
                _field(modelController, "Model"),

                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: fuelType,
                  decoration: _inputDecoration("Fuel Type"),
                  items: const [
                    DropdownMenuItem(value: "Petrol", child: Text("Petrol")),
                    DropdownMenuItem(value: "Diesel", child: Text("Diesel")),
                    DropdownMenuItem(
                      value: "Electric",
                      child: Text("Electric"),
                    ),
                    DropdownMenuItem(value: "Hybrid", child: Text("Hybrid")),
                  ],
                  onChanged: (value) {
                    fuelType = value;
                  },
                ),

                const SizedBox(height: 10),

                _field(
                  yearController,
                  "Manufacturing Year",
                  keyboard: TextInputType.number,
                ),

                _field(
                  mileageController,
                  "Current Mileage",
                  keyboard: TextInputType.number,
                ),

                const SizedBox(height: 12),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: pickServiceDate,
                  child: Text(
                    lastServiceDate == null
                        ? "Select Last Service Date"
                        : lastServiceDate.toString().split(" ")[0],
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),
              onPressed: addVehicle,
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: _inputDecoration(label),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2563EB),
        onPressed: showAddVehicleDialog,
        child: const Icon(Icons.add, color: Colors.white),
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
              var data = vehicles[index].data() as Map<String, dynamic>;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.black.withOpacity(.05),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    /// ICON
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.directions_car,
                        color: Color(0xFF2563EB),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// DETAILS
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['vehicleNumber'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            "${data['brand']} ${data['model']}",
                            style: const TextStyle(color: Colors.grey),
                          ),

                          Text(
                            "Year: ${data['year']} • ${data['fuelType']}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
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
}
