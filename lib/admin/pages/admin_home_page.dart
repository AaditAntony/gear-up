import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  Widget statCard(String title, int value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 35, color: color),

              const SizedBox(height: 10),

              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Admin Dashboard",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      statCard(
                        "Service Centers",
                        totalCenters,
                        Icons.business,
                        Colors.blue,
                      ),

                      const SizedBox(width: 10),

                      statCard(
                        "Pending Approval",
                        pendingCenters,
                        Icons.hourglass_bottom,
                        Colors.orange,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      statCard(
                        "Total Bookings",
                        totalBookings,
                        Icons.analytics,
                        Colors.black,
                      ),

                      const SizedBox(width: 10),

                      statCard(
                        "Completed Services",
                        completedBookings,
                        Icons.done_all,
                        Colors.green,
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
