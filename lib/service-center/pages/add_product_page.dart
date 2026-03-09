import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  bool isLoading = false;

  Future<void> addProduct() async {
    if (nameController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      String uid = FirebaseAuth.instance.currentUser!.uid;

      /// GET CENTER NAME
      var centerDoc = await FirebaseFirestore.instance
          .collection('service_center_details')
          .doc(uid)
          .get();

      String centerName = centerDoc['companyName'];

      await FirebaseFirestore.instance.collection('products').add({
        'centerId': uid,
        'centerName': centerName,

        'productName': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'price': double.tryParse(priceController.text.trim()) ?? 0,

        'createdAt': Timestamp.now(),
      });

      nameController.clear();
      descriptionController.clear();
      priceController.clear();

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product added successfully")),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to add product")));
    }
  }

  @override
  Widget build(BuildContext context) {
    String centerId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Add Products")),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              "Add New Product",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Product Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Price",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : addProduct,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Add Product"),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "My Products",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .where('centerId', isEqualTo: centerId)
                    .snapshots(),

                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var products = snapshot.data!.docs;

                  if (products.isEmpty) {
                    return const Center(child: Text("No products added yet"));
                  }

                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      var product = products[index];

                      return Card(
                        child: ListTile(
                          title: Text(product['productName']),
                          subtitle: Text("₹ ${product['price']}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('products')
                                  .doc(product.id)
                                  .delete();
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
