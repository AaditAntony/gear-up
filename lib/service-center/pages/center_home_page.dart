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

              Text(title, style: const TextStyle(fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }

  Widget recentBookingTile(Map data) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.directions_car),
        title: Text(data['vehicleNumber']),
        subtitle: Text(data['categoryName']),
        trailing: Text(
          data['status'].toUpperCase(),
          style: TextStyle(
            color: data['status'] == "pending"
                ? Colors.orange
                : data['status'] == "accepted"
                ? Colors.blue
                : data['status'] == "in_progress"
                ? Colors.purple
                : data['status'] == "completed"
                ? Colors.green
                : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Dashboard",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              /// TOTAL BOOKINGS
              Row(
                children: [
                  statCard(
                    "Total Bookings",
                    totalBookings,
                    Icons.analytics,
                    Colors.black,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  statCard("Pending", pending, Icons.schedule, Colors.orange),

                  const SizedBox(width: 10),

                  statCard(
                    "Accepted",
                    accepted,
                    Icons.check_circle,
                    Colors.blue,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  statCard(
                    "In Progress",
                    inProgress,
                    Icons.build,
                    Colors.purple,
                  ),

                  const SizedBox(width: 10),

                  statCard(
                    "Completed",
                    completed,
                    Icons.done_all,
                    Colors.green,
                  ),
                ],
              ),

              const SizedBox(height: 25),

              /// RECENT BOOKINGS
              const Text(
                "Recent Bookings",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

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
