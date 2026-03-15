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
    if (selectedCategoryId == null ||
        selectedCategoryName == null ||
        priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select category and enter price")),
      );
      return;
    }

    String centerId = FirebaseAuth.instance.currentUser!.uid;

    var existing = await FirebaseFirestore.instance
        .collection('center_services')
        .where('centerId', isEqualTo: centerId)
        .where('categoryId', isEqualTo: selectedCategoryId)
        .get();

    if (existing.docs.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Service already added")));
      return;
    }

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
        /// PAGE TITLE
        const Text(
          "Service Manager",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 6),

        Text(
          "Add and manage services offered by your workshop",
          style: TextStyle(color: Colors.grey[600]),
        ),

        const SizedBox(height: 25),

        /// ADD SERVICE CARD
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(.05)),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.build, color: Colors.orange),
                  SizedBox(width: 10),
                  Text(
                    "Add New Service",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// CATEGORY DROPDOWN
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
                    decoration: InputDecoration(
                      labelText: "Select Category",
                      prefixIcon: const Icon(Icons.miscellaneous_services),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    value: selectedCategoryId,
                    items: categories.map((doc) {
                      return DropdownMenuItem<String>(
                        value: doc.id,
                        child: Text(doc['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      var selectedDoc = categories.firstWhere(
                        (doc) => doc.id == value,
                      );

                      setState(() {
                        selectedCategoryId = value;
                        selectedCategoryName = selectedDoc['name'];
                      });
                    },
                  );
                },
              ),

              const SizedBox(height: 15),

              /// PRICE FIELD
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: "Your Price",
                  prefixIcon: const Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 18),

              /// ADD BUTTON
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                ),
                onPressed: addService,
                icon: const Icon(Icons.add),
                label: const Text("Add Service"),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        /// MY SERVICES TITLE
        const Row(
          children: [
            Icon(Icons.home_repair_service, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              "My Services",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 15),

        /// SERVICE LIST
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

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 8,
                          color: Colors.black.withOpacity(.05),
                        ),
                      ],
                    ),

                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.build, color: Colors.orange),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service['categoryName'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "Price: ₹${service['price']}",
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteService(service.id),
                        ),
                      ],
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
