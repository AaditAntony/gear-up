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
          title: const Text("Add Vehicle"),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                TextField(
                  controller: vehicleNumberController,
                  decoration: const InputDecoration(
                    labelText: "Vehicle Number",
                  ),
                ),

                TextField(
                  controller: brandController,
                  decoration: const InputDecoration(labelText: "Brand"),
                ),

                TextField(
                  controller: modelController,
                  decoration: const InputDecoration(labelText: "Model"),
                ),

                DropdownButtonFormField<String>(
                  value: fuelType,

                  hint: const Text("Fuel Type"),

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

                TextField(
                  controller: yearController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Manufacturing Year",
                  ),
                ),

                TextField(
                  controller: mileageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Current Mileage",
                  ),
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: pickServiceDate,
                  child: const Text("Select Last Service Date"),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),

            ElevatedButton(onPressed: addVehicle, child: const Text("Save")),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("My Vehicles")),

      floatingActionButton: FloatingActionButton(
        onPressed: showAddVehicleDialog,
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
            itemCount: vehicles.length,

            itemBuilder: (context, index) {
              var data = vehicles[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),

                child: ListTile(
                  title: Text(data['vehicleNumber']),

                  subtitle: Text(
                    "${data['brand']} ${data['model']} • ${data['year']}",
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
