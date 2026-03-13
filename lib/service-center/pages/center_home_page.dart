import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Widget statCard(String title, int value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(.05)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color),
            ),

            const SizedBox(height: 15),

            Text(
              value.toString(),
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget statusBadge(String status) {
    Color color;

    switch (status) {
      case "pending":
        color = Colors.orange;
        break;
      case "accepted":
        color = Colors.blue;
        break;
      case "in_progress":
        color = Colors.purple;
        break;
      case "completed":
        color = Colors.green;
        break;
      default:
        color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget recentBookingTile(Map data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(.04)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.directions_car, color: Colors.orange),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['vehicleNumber'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  data['categoryName'],
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),

          statusBadge(data['status']),
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Service Dashboard",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 25),

              /// STATS
              Row(
                children: [
                  statCard(
                    "Total Bookings",
                    totalBookings,
                    Icons.analytics,
                    Colors.orange,
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  statCard("Pending", pending, Icons.schedule, Colors.orange),
                  const SizedBox(width: 12),
                  statCard(
                    "Accepted",
                    accepted,
                    Icons.check_circle,
                    Colors.blue,
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  statCard(
                    "In Progress",
                    inProgress,
                    Icons.build,
                    Colors.purple,
                  ),
                  const SizedBox(width: 12),
                  statCard(
                    "Completed",
                    completed,
                    Icons.done_all,
                    Colors.green,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// RECENT BOOKINGS
              const Text(
                "Recent Bookings",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              ...recentBookings.map((booking) {
                var data = booking.data() as Map<String, dynamic>;
                return recentBookingTile(data);
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}
