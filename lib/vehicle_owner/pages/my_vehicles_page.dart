import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyVehiclesPage extends StatelessWidget {
  const MyVehiclesPage({super.key});

  void showAddVehicleDialog(BuildContext context) {
    final vehicleNumberController = TextEditingController();
    final brandController = TextEditingController();
    final modelController = TextEditingController();
    final mileageController = TextEditingController();
    final lastServiceController = TextEditingController();
    final yearController = TextEditingController();

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

                const SizedBox(height: 10),

                TextField(
                  controller: brandController,
                  decoration: const InputDecoration(labelText: "Brand"),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: modelController,
                  decoration: const InputDecoration(labelText: "Model"),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: mileageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Current Mileage (km)",
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: lastServiceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Last Service Mileage (km)",
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: yearController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Manufacturing Year",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),

            ElevatedButton(
              child: const Text("Save"),
              onPressed: () async {
                String uid = FirebaseAuth.instance.currentUser!.uid;

                String vehicleNumber = vehicleNumberController.text
                    .trim()
                    .toUpperCase();

                if (vehicleNumber.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Enter vehicle number")),
                  );
                  return;
                }

                /// Duplicate check
                var existingVehicle = await FirebaseFirestore.instance
                    .collection('vehicles')
                    .where('userId', isEqualTo: uid)
                    .where('vehicleNumber', isEqualTo: vehicleNumber)
                    .get();

                if (existingVehicle.docs.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("This vehicle is already added"),
                    ),
                  );
                  return;
                }

                await FirebaseFirestore.instance.collection('vehicles').add({
                  'userId': uid,
                  'vehicleNumber': vehicleNumber,
                  'brand': brandController.text.trim(),
                  'model': modelController.text.trim(),
                  'mileage': int.tryParse(mileageController.text) ?? 0,
                  'lastServiceKm':
                      int.tryParse(lastServiceController.text) ?? 0,
                  'year':
                      int.tryParse(yearController.text) ?? DateTime.now().year,
                  'createdAt': Timestamp.now(),
                });

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteVehicle(
    BuildContext context,
    String vehicleId,
    String vehicleNumber,
  ) async {
    var bookingCheck = await FirebaseFirestore.instance
        .collection('bookings')
        .where('vehicleNumber', isEqualTo: vehicleNumber)
        .where('status', whereIn: ['pending', 'accepted', 'in_progress'])
        .get();

    if (bookingCheck.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot delete vehicle with active bookings"),
        ),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('vehicles')
        .doc(vehicleId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("My Vehicles")),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddVehicleDialog(context);
        },
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('vehicles')
            .where('userId', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No vehicles added"));
          }

          var vehicles = snapshot.data!.docs;

          return ListView.builder(
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              var vehicle = vehicles[index];
              var data = vehicle.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data['vehicleNumber']),

                  subtitle: Text("${data['brand']} - ${data['model']}"),

                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      deleteVehicle(context, vehicle.id, data['vehicleNumber']);
                    },
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
