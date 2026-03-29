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
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Product Sales",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Track all spare parts and product purchases",
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shopping_bag_rounded, color: Color(0xFF10B981)),
              ),
            ],
          ),

          const SizedBox(height: 32),

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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text(
                          "No product sales yet.",
                          style: TextStyle(fontSize: 16, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    var order = orders[index];
                    var data = order.data() as Map<String, dynamic>;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFFE2E8F0).withOpacity(0.5)),
                      ),

                      child: Row(
                        children: [
                          /// PRODUCT IMAGE
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
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
                                      color: const Color(0xFFF1F5F9),
                                      child: const Icon(Icons.image_not_supported_rounded, color: Color(0xFF94A3B8)),
                                    ),
                            ),
                          ),

                          const SizedBox(width: 24),

                          /// PRODUCT DETAILS
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['productName'] ?? "Unknown Product",
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                infoRow(
                                  Icons.store_rounded,
                                  "Center: ${data['centerName']}",
                                ),

                                infoRow(
                                  Icons.currency_rupee_rounded,
                                  "Price: ₹${data['price']}",
                                ),
                              ],
                            ),
                          ),

                          /// STATUS BADGE (Optional, if exists in data)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Text(
                              "PAID",
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                                letterSpacing: 0.5,
                              ),
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
      ),
    );
  }
}
