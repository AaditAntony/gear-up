import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gear_up/vehicle_owner/pages/invoice_page.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        title: const Text("My Orders", style: TextStyle(color: Colors.white)),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('product_orders')
            .where('userId', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(child: Text("No product orders yet."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,

            itemBuilder: (context, index) {
              var order = orders[index];
              var data = order.data() as Map<String, dynamic>;

              /// 📅 DATE FORMAT
              DateTime date = (data['createdAt'] as Timestamp).toDate();

              String formattedDate = "${date.day}/${date.month}/${date.year}";

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InvoicePage(
                        orderId: order.id,
                        orderData: {
                          "productName": data['productName'],
                          "centerName": data['centerName'],
                          "price": data['price'],
                        },
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

                  child: Padding(
                    padding: const EdgeInsets.all(12),

                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// IMAGE
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: data['productImage'] != null
                              ? Image.memory(
                                  base64Decode(data['productImage']),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.shopping_bag),
                                ),
                        ),

                        const SizedBox(width: 12),

                        /// DETAILS
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// NAME
                              Text(
                                data['productName'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),

                              const SizedBox(height: 6),

                              /// SELLER
                              Text(
                                "Sold by ${data['centerName']}",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),

                              const SizedBox(height: 6),

                              /// DATE
                              Text(
                                "Date: $formattedDate",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),

                              const SizedBox(height: 10),

                              /// PRICE + STATUS
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "₹${data['price']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      "PAID",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        /// ARROW
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}////