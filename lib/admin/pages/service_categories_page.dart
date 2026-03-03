import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceCategoriesPage extends StatefulWidget {
  const ServiceCategoriesPage({super.key});

  @override
  State<ServiceCategoriesPage> createState() =>
      _ServiceCategoriesPageState();
}

class _ServiceCategoriesPageState
    extends State<ServiceCategoriesPage> {

  final TextEditingController nameController =
      TextEditingController();
  final TextEditingController priceController =
      TextEditingController();

  Future<void> addCategory() async {
    if (nameController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields")),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('service_categories')
        .add({
      'name': nameController.text.trim(),
      'basePrice':
          double.tryParse(priceController.text.trim()) ?? 0,
      'createdAt': Timestamp.now(),
    });

    nameController.clear();
    priceController.clear();
  }

  Future<void> deleteCategory(String id) async {
    await FirebaseFirestore.instance
        .collection('service_categories')
        .doc(id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          "Service Categories",
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Category Name",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: "Base Price",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: addCategory,
              child: const Text("Add"),
            )
          ],
        ),

        const SizedBox(height: 20),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('service_categories')
                .snapshots(),
            builder: (context, snapshot) {

              if (!snapshot.hasData) {
                return const Center(
                    child: CircularProgressIndicator());
              }

              var categories = snapshot.data!.docs;

              if (categories.isEmpty) {
                return const Center(
                    child: Text("No categories added yet."));
              }

              return ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {

                  var category = categories[index];

                  return Card(
                    child: ListTile(
                      title: Text(category['name']),
                      subtitle: Text(
                          "Base Price: ₹${category['basePrice']}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () =>
                            deleteCategory(category.id),
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