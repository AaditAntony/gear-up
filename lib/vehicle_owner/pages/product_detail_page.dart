import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      appBar: AppBar(title: Text(productData['productName'])),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            if (image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  image,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 20),

            Text(
              productData['productName'],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              "Sold by: ${productData['centerName']}",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            Text(
              "Price: ₹${productData['price']}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            const Text(
              "Description",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(productData['description']),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: const Text("Buy Now"),
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
          ],
        ),
      ),
    );
  }
}
