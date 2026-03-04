import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingDetailPage extends StatelessWidget {
  final String bookingId;

  const BookingDetailPage({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Booking Details")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .doc(bookingId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;

          List updates = data["serviceUpdates"] ?? [];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['centerName'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text("Service: ${data['categoryName']}"),

                Text("Vehicle: ${data['vehicleNumber']}"),

                Text("Date: ${data['bookingDate'].toString().split("T")[0]}"),

                Text("Slot: ${data['bookingSlot']}"),

                const SizedBox(height: 10),

                Text("Complaint: ${data['complaint'] ?? "No complaint"}"),

                const SizedBox(height: 10),

                Text(
                  "Status: ${data['status'].toUpperCase()}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Service Progress",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: updates.isEmpty
                      ? const Center(
                          child: Text("Service updates will appear here"),
                        )
                      : ListView.builder(
                          itemCount: updates.length,
                          itemBuilder: (context, index) {
                            var update = updates[index];

                            Color statusColor;

                            if (update["status"] == "completed") {
                              statusColor = Colors.green;
                            } else if (update["status"] == "in_progress") {
                              statusColor = Colors.orange;
                            } else {
                              statusColor = Colors.grey;
                            }

                            return Card(
                              child: ListTile(
                                title: Text(update["title"]),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(update["description"]),

                                    const SizedBox(height: 4),

                                    Text(
                                      "Status: ${update["status"]}",
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
