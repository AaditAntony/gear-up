import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gear_up/service-center/widgets/service_theme.dart';

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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
               Icon(Icons.add_shopping_cart_rounded, color: ServiceTheme.accent, size: 28),
               SizedBox(width: 12),
               Text("Inventory Manager", style: ServiceTheme.heading1),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Showcase and sell your spare parts, accessories, and maintenance products.", 
            style: ServiceTheme.body,
          ),

          const SizedBox(height: 32),

          /// ADD PRODUCT CARD
          Container(
            padding: const EdgeInsets.all(32),
            decoration: ServiceTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// IMAGE PICKER
                    Column(
                      children: [
                        const Text("PRODUCT IMAGE", style: ServiceTheme.label),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: pickImage,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              color: ServiceTheme.background,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: imageBytes != null ? ServiceTheme.accent.withOpacity(0.3) : ServiceTheme.border,
                                width: 2,
                                style: imageBytes != null ? BorderStyle.solid : BorderStyle.none,
                              ),
                            ),
                            child: imageBytes != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: Image.memory(imageBytes!, fit: BoxFit.cover),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo_rounded, size: 32, color: ServiceTheme.textSecondary.withOpacity(0.5)),
                                      const SizedBox(height: 8),
                                      const Text("Upload Photo", style: TextStyle(fontSize: 12, color: ServiceTheme.textSecondary, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 32),

                    /// PRODUCT DETAILS FIELDS
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("IDENTIFICATION", style: ServiceTheme.label),
                          const SizedBox(height: 12),
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              hintText: "Product Name (e.g. Engine Oil 5W-30)",
                              filled: true,
                              fillColor: ServiceTheme.background,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text("MARKET VALUE", style: ServiceTheme.label),
                          const SizedBox(height: 12),
                          TextField(
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "Price in INR",
                              prefixIcon: const Icon(Icons.currency_rupee_rounded, size: 18),
                              filled: true,
                              fillColor: ServiceTheme.background,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Text("SHORT DESCRIPTION", style: ServiceTheme.label),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: "Briefly describe the product's features and compatibility...",
                    filled: true,
                    fillColor: ServiceTheme.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),

                const SizedBox(height: 32),

                /// ADD BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ServiceTheme.accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isLoading ? null : addProduct,
                    icon: isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.publish_rounded),
                    label: Text(
                      isLoading ? "Publishing..." : "Publish to Storefront", 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 48),

          /// PRODUCTS LISTING
          const Row(
            children: [
               Icon(Icons.inventory_rounded, color: ServiceTheme.accent, size: 28),
               SizedBox(width: 12),
               Text("Active Product Listing", style: ServiceTheme.heading1),
            ],
          ),
          const SizedBox(height: 8),
          const Text("Manage your current store catalog.", style: ServiceTheme.body),

          const SizedBox(height: 32),

          /// PRODUCT LIST
          StreamBuilder<QuerySnapshot>(
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
                return Center(
                  child: Column(
                    children: [
                       const SizedBox(height: 40),
                       Icon(Icons.shopping_basket_outlined, size: 64, color: ServiceTheme.border.withOpacity(0.5)),
                       const SizedBox(height: 16),
                       const Text("No products cataloged yet.", style: ServiceTheme.body),
                    ],
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 24,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  var product = products[index];
                  var data = product.data() as Map<String, dynamic>;

                  Uint8List? image;
                  if (data['image'] != null) {
                    image = base64Decode(data['image']);
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: ServiceTheme.border.withOpacity(0.5)),
                      boxShadow: ServiceTheme.softShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: image != null
                                    ? ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                        child: Image.memory(image, fit: BoxFit.cover),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                          color: ServiceTheme.background,
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                        ),
                                        child: const Icon(Icons.image_not_supported_outlined, color: ServiceTheme.border),
                                      ),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: InkWell(
                                  onTap: () async {
                                    await FirebaseFirestore.instance
                                        .collection('products')
                                        .doc(product.id)
                                        .delete();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['productName'],
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: ServiceTheme.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "₹${data['price']}",
                                style: const TextStyle(
                                  color: ServiceTheme.accent,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
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
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
