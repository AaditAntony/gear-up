import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyVehiclesPage extends StatelessWidget {
  const MyVehiclesPage({super.key});

  void showAddVehicleDialog(BuildContext context) {
    final vehicleNumberController = TextEditingController();
    final brandController = TextEditingController();
    final modelController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Vehicle"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: vehicleNumberController,
                decoration: const InputDecoration(labelText: "Vehicle Number"),
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
            ],
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

                String vehicleNumber =
                    vehicleNumberController.text.trim().toUpperCase();

                if (vehicleNumber.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Enter vehicle number")),
                  );
                  return;
                }

                // Check duplicate vehicle
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
                  'createdAt': Timestamp.now(),
                });

                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  Future<void> deleteVehicle(String vehicleId) async {
    await FirebaseFirestore.instance
        .collection('vehicles')
        .doc(vehicleId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Vehicles"),
      ),
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
                      deleteVehicle(vehicle.id);
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