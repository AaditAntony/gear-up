import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  Widget statCard(String title, int value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            /// ICON CONTAINER
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),

            const SizedBox(width: 16),

            /// TEXT SECTION
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('service_center_details')
          .snapshots(),
      builder: (context, centerSnapshot) {
        if (!centerSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var centers = centerSnapshot.data!.docs;

        int totalCenters = centers.length;

        int pendingCenters = centers
            .where((c) => c['status'] == "pending")
            .length;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
          builder: (context, bookingSnapshot) {
            if (!bookingSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            var bookings = bookingSnapshot.data!.docs;

            int totalBookings = bookings.length;

            int completedBookings = bookings
                .where((b) => b['status'] == "completed")
                .length;

            return Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// PAGE TITLE
                  const Text(
                    "Dashboard Overview",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Monitor platform activity and service statistics",
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  ),

                  const SizedBox(height: 30),

                  /// FIRST ROW
                  Row(
                    children: [
                      statCard(
                        "Service Centers",
                        totalCenters,
                        Icons.business,
                        const Color(0xFF3B82F6),
                      ),

                      const SizedBox(width: 16),

                      statCard(
                        "Pending Approval",
                        pendingCenters,
                        Icons.hourglass_bottom,
                        const Color(0xFFF59E0B),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// SECOND ROW
                  Row(
                    children: [
                      statCard(
                        "Total Bookings",
                        totalBookings,
                        Icons.analytics,
                        const Color(0xFF1E293B),
                      ),

                      const SizedBox(width: 16),

                      statCard(
                        "Completed Services",
                        completedBookings,
                        Icons.done_all,
                        const Color(0xFF22C55E),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
