import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductSalesPage extends StatelessWidget {
  const ProductSalesPage({super.key});

  Widget infoItem(IconData icon, String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: Color(0xFF94A3B8),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// PAGE HEADER
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 40, 40, 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Revenue Streams",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                      letterSpacing: -1.0,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Comprehensive tracking of all platform product transactions.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
                  ],
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Icon(Icons.analytics_rounded, color: Color(0xFF10B981)),
              ),
            ],
          ),
        ),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('product_orders').orderBy('createdAt', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20),
                          ],
                        ),
                        child: Icon(Icons.shopping_basket_outlined, size: 64, color: Colors.grey[200]),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "No transaction records found.",
                        style: TextStyle(fontSize: 16, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }

              var orders = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                physics: const BouncingScrollPhysics(),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  var order = orders[index];
                  var data = order.data() as Map<String, dynamic>;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          /// PRODUCT IMAGE
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: data['productImage'] != null
                                  ? Image.memory(
                                      base64Decode(data['productImage']),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 100,
                                      height: 100,
                                      color: const Color(0xFFF8FAFC),
                                      child: const Icon(Icons.inventory_2_rounded, color: Color(0xFF94A3B8), size: 32),
                                    ),
                            ),
                          ),

                          const SizedBox(width: 32),

                          /// PRODUCT DETAILS
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      data['productName'] ?? "Unknown Artifact",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF1E293B),
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    _statusBadge("PAID"),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                Row(
                                  children: [
                                    Expanded(child: infoItem(Icons.store_rounded, "Processing Center", data['centerName'] ?? "N/A", const Color(0xFF1E293B))),
                                    const SizedBox(width: 24),
                                    Expanded(child: infoItem(Icons.payments_rounded, "Transaction Value", "₹${data['price']}", const Color(0xFF10B981))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
      ),
      child: const Text(
        "PAID",
        style: TextStyle(
          color: Color(0xFF10B981),
          fontWeight: FontWeight.w900,
          fontSize: 10,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
