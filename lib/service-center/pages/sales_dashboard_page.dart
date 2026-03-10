import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SalesDashboardPage extends StatelessWidget {
  const SalesDashboardPage({super.key});

  Stream<QuerySnapshot> getSales() {
    String centerId = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('product_orders')
        .where('centerId', isEqualTo: centerId)
        .snapshots();
  }

  double getTotalRevenue(List docs) {
    double total = 0;

    for (var doc in docs) {
      total += (doc['totalAmount'] ?? 0);
    }

    return total;
  }

  int getTotalProducts(List docs) {
    int total = 0;

    for (var doc in docs) {
      total += (doc['quantity'] ?? 0) as int;
    }

    return total;
  }

  double getTodayRevenue(List docs) {
    double total = 0;

    DateTime today = DateTime.now();

    for (var doc in docs) {
      Timestamp ts = doc['createdAt'];
      DateTime date = ts.toDate();

      if (date.year == today.year &&
          date.month == today.month &&
          date.day == today.day) {
        total += (doc['totalAmount'] ?? 0);
      }
    }

    return total;
  }

  Widget statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 35, color: color),
              const SizedBox(height: 10),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: getSales(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var orders = snapshot.data!.docs;

        double totalRevenue = getTotalRevenue(orders);
        int totalProducts = getTotalProducts(orders);
        double todayRevenue = getTodayRevenue(orders);

        return Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Sales Dashboard",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  statCard(
                    "Total Revenue",
                    "₹${totalRevenue.toStringAsFixed(0)}",
                    Icons.attach_money,
                    Colors.green,
                  ),

                  const SizedBox(width: 10),

                  statCard(
                    "Products Sold",
                    totalProducts.toString(),
                    Icons.shopping_cart,
                    Colors.blue,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  statCard(
                    "Today's Sales",
                    "₹${todayRevenue.toStringAsFixed(0)}",
                    Icons.today,
                    Colors.orange,
                  ),

                  const SizedBox(width: 10),

                  statCard(
                    "Orders",
                    orders.length.toString(),
                    Icons.receipt,
                    Colors.purple,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                "Recent Orders",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    var order = orders[index];

                    return Card(
                      child: ListTile(
                        title: Text(order['productName']),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Quantity: ${order['quantity']}"),
                            Text("Total: ₹${order['totalAmount']}"),
                          ],
                        ),

                        trailing: const Icon(Icons.arrow_forward_ios),
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
