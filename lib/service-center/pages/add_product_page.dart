import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  Uint8List? imageBytes;
  String? imageBase64;

  bool isLoading = false;

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file == null) return;

    Uint8List bytes = await file.readAsBytes();

    if (bytes.length > 300 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image must be under 300 KB")),
      );
      return;
    }

    setState(() {
      imageBytes = bytes;
      imageBase64 = base64Encode(bytes);
    });
  }

  Future<void> addProduct() async {
    if (nameController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty ||
        imageBase64 == null) {
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

        'image': imageBase64,

        'createdAt': Timestamp.now(),
      });

      nameController.clear();
      descriptionController.clear();
      priceController.clear();

      setState(() {
        imageBytes = null;
        imageBase64 = null;
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

            const SizedBox(height: 15),

            Row(
              children: [
                imageBytes != null
                    ? Image.memory(imageBytes!, width: 100, height: 100)
                    : const Text("No image selected"),

                const SizedBox(width: 20),

                ElevatedButton(
                  onPressed: pickImage,
                  child: const Text("Upload Image"),
                ),
              ],
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
                      var data = product.data() as Map<String, dynamic>;

                      Uint8List? image;

                      if (data['image'] != null) {
                        image = base64Decode(data['image']);
                      }

                      return Card(
                        child: ListTile(
                          leading: image != null
                              ? Image.memory(image, width: 50, height: 50)
                              : const Icon(Icons.image),

                          title: Text(data['productName']),

                          subtitle: Text("₹ ${data['price']}"),

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
