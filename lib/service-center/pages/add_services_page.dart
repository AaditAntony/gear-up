import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddServicesPage extends StatefulWidget {
  const AddServicesPage({super.key});

  @override
  State<AddServicesPage> createState() => _AddServicesPageState();
}

class _AddServicesPageState extends State<AddServicesPage> {
  String? selectedCategoryId;
  String? selectedCategoryName;

  final TextEditingController priceController = TextEditingController();

  Future<void> addService() async {
    if (selectedCategoryId == null || priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select category and enter price")),
      );
      return;
    }

    String centerId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('center_services').add({
      'centerId': centerId,
      'categoryId': selectedCategoryId,
      'categoryName': selectedCategoryName,
      'price': double.tryParse(priceController.text.trim()) ?? 0,
      'createdAt': Timestamp.now(),
    });

    priceController.clear();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Service added successfully")));
  }

  Future<void> deleteService(String docId) async {
    await FirebaseFirestore.instance
        .collection('center_services')
        .doc(docId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    String centerId = FirebaseAuth.instance.currentUser!.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Add Services",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 20),

        // 🔹 CATEGORY DROPDOWN
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('service_categories')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            var categories = snapshot.data!.docs;

            return DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Select Category",
                border: OutlineInputBorder(),
              ),
              value: selectedCategoryId,
              items: categories.map((doc) {
                return DropdownMenuItem<String>(
                  value: doc.id,
                  child: Text(doc['name']),
                  onTap: () {
                    selectedCategoryName = doc['name'];
                  },
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategoryId = value;
                });
              },
            );
          },
        ),

        const SizedBox(height: 15),

        TextField(
          controller: priceController,
          decoration: const InputDecoration(
            labelText: "Your Price",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),

        const SizedBox(height: 15),

        ElevatedButton(onPressed: addService, child: const Text("Add Service")),

        const SizedBox(height: 30),

        const Text(
          "My Services",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('center_services')
                .where('centerId', isEqualTo: centerId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var services = snapshot.data!.docs;

              if (services.isEmpty) {
                return const Center(child: Text("No services added yet."));
              }

              return ListView.builder(
                itemCount: services.length,
                itemBuilder: (context, index) {
                  var service = services[index];

                  return Card(
                    child: ListTile(
                      title: Text(service['categoryName']),
                      subtitle: Text("Price: ₹${service['price']}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => deleteService(service.id),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
