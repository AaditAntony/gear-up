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

      body: Column(
        children: [
          /// 🔥 HERO IMAGE SECTION
          Stack(
            children: [
              image != null
                  ? Image.memory(
                      image,
                      height: 280,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(height: 280, color: Colors.grey.shade300),

              /// GRADIENT OVERLAY
              Container(
                height: 280,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(.6), Colors.transparent],
                  ),
                ),
              ),

              /// BACK BUTTON
              Positioned(
                top: 40,
                left: 10,
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(.4),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              /// PRODUCT INFO ON IMAGE
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productData['productName'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "₹${productData['price']}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          /// 🔥 BODY
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// SELLER
                  Row(
                    children: [
                      const Icon(Icons.store, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        productData['centerName'],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// DESCRIPTION
                  const Text(
                    "Description",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      productData['description'],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          /// 🔥 PREMIUM BUY BUTTON
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
              height: 55,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),

                child: const Text(
                  "Buy Now",
                  style: TextStyle(fontSize: 17, color: Colors.white),
                ),

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
