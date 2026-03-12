import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductSalesPage extends StatelessWidget {
  const ProductSalesPage({super.key});

  Widget infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Product Sales",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          "Track all spare parts and product purchases",
          style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        ),

        const SizedBox(height: 25),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('product_orders')
                .orderBy('createdAt', descending: true)
                .snapshots(),

            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var orders = snapshot.data!.docs;

              if (orders.isEmpty) {
                return const Center(
                  child: Text(
                    "No product sales yet.",
                    style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                  ),
                );
              }

              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  var order = orders[index];
                  var data = order.data() as Map<String, dynamic>;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),

                    child: Row(
                      children: [
                        /// PRODUCT IMAGE
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: data['productImage'] != null
                              ? Image.memory(
                                  base64Decode(data['productImage']),
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 70,
                                  height: 70,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image_not_supported),
                                ),
                        ),

                        const SizedBox(width: 16),

                        /// PRODUCT DETAILS
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['productName'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),

                              const SizedBox(height: 10),

                              infoRow(
                                Icons.store,
                                "Center: ${data['centerName']}",
                              ),

                              infoRow(
                                Icons.currency_rupee,
                                "Price: ₹${data['price']}",
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
        ),
      ],
    );
  }
}
