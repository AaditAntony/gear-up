import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gear_up/vehicle_owner/pages/invoice_page.dart';

class ProductDetailPage extends StatelessWidget {
  final String productId;
  final Map<String, dynamic> productData;

  const ProductDetailPage({
    super.key,
    required this.productId,
    required this.productData,
  });

  @override
  Widget build(BuildContext context) {
    Uint8List? image;

    if (productData['image'] != null) {
      image = base64Decode(productData['image']);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        title: Text(
          productData['productName'],
          style: const TextStyle(color: Colors.white),
        ),
      ),

      body: Column(
        children: [
          /// SCROLLABLE CONTENT
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔥 PRODUCT IMAGE
                  if (image != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      child: Image.memory(
                        image,
                        height: 260,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      height: 260,
                      color: Colors.grey.shade200,
                      child: const Center(child: Icon(Icons.image, size: 60)),
                    ),

                  const SizedBox(height: 16),

                  /// 🔥 MAIN CARD
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),

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

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// PRODUCT NAME
                        Text(
                          productData['productName'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        /// SELLER
                        Row(
                          children: [
                            const Icon(
                              Icons.store,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              productData['centerName'],
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        /// PRICE
                        Text(
                          "₹${productData['price']}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔥 DESCRIPTION SECTION
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Description",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          productData['description'],
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          /// 🔥 BUY BUTTON (FIXED)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(.05)),
              ],
            ),

            child: SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                child: const Text("Buy Now", style: TextStyle(fontSize: 16)),

                onPressed: () async {
                  String uid = FirebaseAuth.instance.currentUser!.uid;

                  var order = await FirebaseFirestore.instance
                      .collection('product_orders')
                      .add({
                        "userId": uid,

                        "centerId": productData['centerId'],
                        "centerName": productData['centerName'],

                        "productId": productId,
                        "productName": productData['productName'],
                        "productImage": productData['image'],

                        "price": productData['price'],

                        "status": "paid",

                        "createdAt": Timestamp.now(),
                      });

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InvoicePage(
                        orderId: order.id,
                        orderData: {
                          "productName": productData['productName'],
                          "centerName": productData['centerName'],
                          "price": productData['price'],
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
