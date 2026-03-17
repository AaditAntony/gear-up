import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_detail_page.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        title: const Text(
          "Products Marketplace",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var products = snapshot.data!.docs;

          if (products.isEmpty) {
            return const Center(child: Text("No products available"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,

            itemBuilder: (context, index) {
              var product = products[index];
              var data = product.data() as Map<String, dynamic>;

              Uint8List? image;

              if (data['image'] != null) {
                image = base64Decode(data['image']);
              }

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailPage(
                        productId: product.id,
                        productData: data,
                      ),
                    ),
                  );
                },

                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.black.withOpacity(.05),
                      ),
                    ],
                  ),

                  child: Row(
                    children: [
                      /// IMAGE
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                        child: image != null
                            ? Image.memory(
                                image,
                                width: 110,
                                height: 110,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 110,
                                height: 110,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image),
                              ),
                      ),

                      /// DETAILS
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// PRODUCT NAME
                              Text(
                                data['productName'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 6),

                              /// CENTER
                              Text(
                                data['centerName'],
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),

                              const SizedBox(height: 10),

                              /// PRICE
                              Text(
                                "₹${data['price']}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      /// ARROW
                      const Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    ],
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
////