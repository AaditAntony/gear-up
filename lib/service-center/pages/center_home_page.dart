import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gear_up/service-center/widgets/service_theme.dart';

class ServiceHomePage extends StatelessWidget {
  const ServiceHomePage({super.key});

  Stream<QuerySnapshot> getBookings() {
    String centerId = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('bookings')
        .where('centerId', isEqualTo: centerId)
        .snapshots();
  }

  int countStatus(List docs, String status) {
    return docs.where((doc) => doc['status'] == status).length;
  }

  /// SERVICE PIPELINE SUMMARY
  Widget servicePipeline(
    int pending,
    int accepted,
    int inProgress,
    int completed,
  ) {
    Widget item(String title, int count, Color color) {
      return Expanded(
        child: Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color, 
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.4), blurRadius: 6),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.w900, 
                fontSize: 18,
                color: ServiceTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11, 
                color: ServiceTheme.textSecondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ServiceTheme.border.withOpacity(0.5)),
        boxShadow: ServiceTheme.softShadow,
      ),
      child: Row(
        children: [
          item("PENDING", pending, ServiceTheme.warning),
          item("ACCEPTED", accepted, ServiceTheme.info),
          item("IN PROGRESS", inProgress, Colors.purpleAccent),
          item("COMPLETED", completed, ServiceTheme.success),
        ],
      ),
    );
  }

  /// BOOKING TREND GRAPH
  Widget bookingTrendChart(List docs) {
    Map<int, int> dailyBookings = {};
    DateTime now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      DateTime day = now.subtract(Duration(days: i));
      dailyBookings[day.day] = 0;
    }

    for (var doc in docs) {
      Timestamp ts = doc['createdAt'];
      DateTime date = ts.toDate();

      if (dailyBookings.containsKey(date.day)) {
        dailyBookings[date.day] = dailyBookings[date.day]! + 1;
      }
    }

    List<FlSpot> spots = [];
    int index = 0;

    dailyBookings.forEach((day, value) {
      spots.add(FlSpot(index.toDouble(), value.toDouble()));
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
              color: ServiceTheme.accent,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 3,
                  strokeColor: ServiceTheme.accent,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    ServiceTheme.accent.withOpacity(0.2),
                    ServiceTheme.accent.withOpacity(0.0),
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

  Widget statCard(String title, int value, IconData icon, Color color) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "+12%",
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 32, 
                fontWeight: FontWeight.w900,
                color: ServiceTheme.textPrimary,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13, 
                color: ServiceTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget statusBadge(String status) {
    Color color;
    IconData icon;

    switch (status) {
      case "pending":
        color = ServiceTheme.warning;
        icon = Icons.access_time_filled_rounded;
        break;
      case "accepted":
        color = ServiceTheme.info;
        icon = Icons.check_circle_rounded;
        break;
      case "in_progress":
        color = Colors.purpleAccent;
        icon = Icons.settings_rounded;
        break;
      case "completed":
        color = ServiceTheme.success;
        icon = Icons.verified_rounded;
        break;
      default:
        color = ServiceTheme.error;
        icon = Icons.error_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget recentBookingTile(Map data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: ServiceTheme.accent.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_car_filled_rounded, 
              color: ServiceTheme.accent,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['vehicleNumber'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: ServiceTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data['categoryName'],
                  style: const TextStyle(
                    color: ServiceTheme.textSecondary, 
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          statusBadge(data['status']),
          const SizedBox(width: 12),
          const Icon(Icons.chevron_right_rounded, color: ServiceTheme.border),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: getBookings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(child: Text("Error loading data"));
        }

        var docs = snapshot.data!.docs;

        int totalBookings = docs.length;
        int pending = countStatus(docs, "pending");
        int accepted = countStatus(docs, "accepted");
        int inProgress = countStatus(docs, "in_progress");
        int completed = countStatus(docs, "completed");

        var recentBookings = docs.take(5).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_graph_rounded, color: ServiceTheme.accent, size: 28),
                  SizedBox(width: 12),
                  Text(
                    "Service Insights",
                    style: ServiceTheme.heading1,
                  ),
                ],
              ),

              const SizedBox(height: 8),
              const Text(
                "Real-time overview of your center performance",
                style: ServiceTheme.body,
              ),

              const SizedBox(height: 32),

              Row(
                children: [
                  statCard(
                    "Grand Total",
                    totalBookings,
                    Icons.apps_rounded,
                    ServiceTheme.primary,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  statCard("Pending", pending, Icons.watch_later_rounded, ServiceTheme.warning),
                  const SizedBox(width: 16),
                  statCard(
                    "Approved",
                    accepted,
                    Icons.task_alt_rounded,
                    ServiceTheme.info,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  statCard(
                    "Ongoing",
                    inProgress,
                    Icons.bolt_rounded,
                    Colors.purpleAccent,
                  ),
                  const SizedBox(width: 16),
                  statCard(
                    "Finished",
                    completed,
                    Icons.verified_user_rounded,
                    ServiceTheme.success,
                  ),
                ],
              ),

              const SizedBox(height: 32),
              
              const Text("Pipeline Velocity", style: ServiceTheme.heading2),
              const SizedBox(height: 16),
              servicePipeline(pending, accepted, inProgress, completed),

              const SizedBox(height: 40),

              const Text(
                "Booking Trends",
                style: ServiceTheme.heading2,
              ),

              const SizedBox(height: 16),

              bookingTrendChart(docs),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent Activity",
                    style: ServiceTheme.heading2,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text("View All"),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              ...recentBookings.map((booking) {
                var data = booking.data() as Map<String, dynamic>;
                return recentBookingTile(data);
              }).toList(),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
