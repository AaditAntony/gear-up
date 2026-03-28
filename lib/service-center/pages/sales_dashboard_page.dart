import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gear_up/service-center/widgets/service_theme.dart';

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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ServiceTheme.border.withOpacity(0.5)),
          boxShadow: ServiceTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 20),
            Text(
              value,
              style: const TextStyle(
                fontSize: 26, 
                fontWeight: FontWeight.w900,
                color: ServiceTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12, 
                color: ServiceTheme.textSecondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget salesChart(List docs) {
    Map<int, double> dailySales = {};
    DateTime now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      DateTime day = now.subtract(Duration(days: i));
      dailySales[day.day] = 0;
    }

    for (var doc in docs) {
      Timestamp ts = doc['createdAt'];
      DateTime date = ts.toDate();

      if (dailySales.containsKey(date.day)) {
        dailySales[date.day] =
            (dailySales[date.day] ?? 0) + (doc['price'] ?? 0);
      }
    }

    List<FlSpot> spots = [];
    int index = 0;

    dailySales.forEach((day, value) {
      spots.add(FlSpot(index.toDouble(), value));
      index++;
    });

    return Container(
      height: 240,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ServiceTheme.border.withOpacity(0.5)),
        boxShadow: ServiceTheme.softShadow,
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: ServiceTheme.border.withOpacity(0.3),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 5,
              color: ServiceTheme.info,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 3,
                  strokeColor: ServiceTheme.info,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    ServiceTheme.info.withOpacity(0.2),
                    ServiceTheme.info.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
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

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                   Icon(Icons.query_stats_rounded, color: ServiceTheme.accent, size: 28),
                   SizedBox(width: 12),
                   Text("Financial Overview", style: ServiceTheme.heading1),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Detailed breakdown of your parts & product sales performance.", 
                style: ServiceTheme.body,
              ),

              const SizedBox(height: 32),

              Row(
                children: [
                  statCard(
                    "Total Collected",
                    "₹${totalRevenue.toStringAsFixed(0)}",
                    Icons.account_balance_wallet_rounded,
                    ServiceTheme.success,
                  ),
                  const SizedBox(width: 16),
                  statCard(
                    "Orders Fulfilled",
                    totalOrders.toString(),
                    Icons.local_shipping_rounded,
                    ServiceTheme.info,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  statCard(
                    "Today's Revenue",
                    "₹${todayRevenue.toStringAsFixed(0)}",
                    Icons.today_rounded,
                    ServiceTheme.warning,
                  ),
                  const SizedBox(width: 16),
                  statCard(
                    "Monthly Goal",
                    "₹${monthlyRevenue.toStringAsFixed(0)}",
                    Icons.insights_rounded,
                    Colors.purpleAccent,
                  ),
                ],
              ),

              const SizedBox(height: 40),

              const Text("Sales Velocity", style: ServiceTheme.heading2),
              const SizedBox(height: 16),
              salesChart(orders),

              const SizedBox(height: 40),

              const Text("Transaction History", style: ServiceTheme.heading2),
              const SizedBox(height: 16),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  var order = orders[index];

                  Timestamp ts = order['createdAt'];
                  DateTime date = ts.toDate();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ServiceTheme.border.withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: ServiceTheme.accent.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: ServiceTheme.accent,
                            size: 20,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order['productName'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: ServiceTheme.textPrimary,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${date.toString().split(" ")[0]} · Electronic Receipt",
                                style: const TextStyle(color: ServiceTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),

                        Text(
                          "₹${order['price']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: ServiceTheme.success,
                            fontSize: 15,
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: ServiceTheme.border,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
