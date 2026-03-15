import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SalesDashboardPage extends StatelessWidget {
  const SalesDashboardPage({super.key});

  Stream<QuerySnapshot> getOrders() {
    String centerId = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('product_orders')
        .where('centerId', isEqualTo: centerId)
        .where('status', isEqualTo: 'paid')
        .snapshots();
  }

  double calculateRevenue(List docs) {
    double total = 0;

    for (var doc in docs) {
      total += (doc['price'] ?? 0);
    }

    return total;
  }

  double calculateTodayRevenue(List docs) {
    double total = 0;

    DateTime today = DateTime.now();

    for (var doc in docs) {
      Timestamp ts = doc['createdAt'];
      DateTime date = ts.toDate();

      if (date.year == today.year &&
          date.month == today.month &&
          date.day == today.day) {
        total += (doc['price'] ?? 0);
      }
    }

    return total;
  }

  double calculateMonthlyRevenue(List docs) {
    double total = 0;

    DateTime today = DateTime.now();

    for (var doc in docs) {
      Timestamp ts = doc['createdAt'];
      DateTime date = ts.toDate();

      if (date.year == today.year && date.month == today.month) {
        total += (doc['price'] ?? 0);
      }
    }

    return total;
  }

  Widget statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(.05)),
          ],
        ),

        child: Column(
          children: [
            Icon(icon, size: 32, color: color),

            const SizedBox(height: 10),

            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: getOrders(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var orders = snapshot.data!.docs;

        double totalRevenue = calculateRevenue(orders);
        double todayRevenue = calculateTodayRevenue(orders);
        double monthlyRevenue = calculateMonthlyRevenue(orders);

        int totalOrders = orders.length;

        return Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Sales Dashboard",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 25),

              /// ROW 1
              Row(
                children: [
                  statCard(
                    "Total Revenue",
                    "₹${totalRevenue.toStringAsFixed(0)}",
                    Icons.attach_money,
                    Colors.green,
                  ),

                  const SizedBox(width: 12),

                  statCard(
                    "Products Sold",
                    totalOrders.toString(),
                    Icons.shopping_cart,
                    Colors.blue,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// ROW 2
              Row(
                children: [
                  statCard(
                    "Today's Sales",
                    "₹${todayRevenue.toStringAsFixed(0)}",
                    Icons.today,
                    Colors.orange,
                  ),

                  const SizedBox(width: 12),

                  statCard(
                    "Monthly Sales",
                    "₹${monthlyRevenue.toStringAsFixed(0)}",
                    Icons.calendar_month,
                    Colors.purple,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                "Recent Orders",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              Expanded(
                child: ListView.builder(
                  itemCount: orders.length,

                  itemBuilder: (context, index) {
                    var order = orders[index];

                    Timestamp ts = order['createdAt'];
                    DateTime date = ts.toDate();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),

                      padding: const EdgeInsets.all(14),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),

                        boxShadow: [
                          BoxShadow(
                            blurRadius: 6,
                            color: Colors.black.withOpacity(.05),
                          ),
                        ],
                      ),

                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(.15),
                              borderRadius: BorderRadius.circular(8),
                            ),

                            child: const Icon(
                              Icons.shopping_bag,
                              color: Colors.orange,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order['productName'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  "₹${order['price']} • ${date.toString().split(" ")[0]}",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),

                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
