import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'center_booking_detail_page.dart';

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  Future<void> updateStatus(String bookingId, String status) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .update({'status': status});
  }

  @override
  Widget build(BuildContext context) {
    String centerId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('centerId', isEqualTo: centerId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          var bookings = snapshot.data!.docs;

          if (bookings.isEmpty) {
            return const Center(
              child: Text("No bookings yet"),
            );
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {

              var booking = bookings[index];
              var data = booking.data() as Map<String, dynamic>;

              String status = data['status'];

              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        data['categoryName'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text("Vehicle: ${data['vehicleNumber']}"),

                      Text(
                        "Date: ${data['bookingDate'].toString().split("T")[0]}",
                      ),

                      Text("Slot: ${data['bookingSlot']}"),

                      const SizedBox(height: 6),

                      Text(
                        "Complaint: ${data['complaint'] ?? "No complaint"}",
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Status: ${status.toUpperCase()}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: status == "pending"
                              ? Colors.orange
                              : status == "accepted"
                                  ? Colors.green
                                  : status == "completed"
                                      ? Colors.blue
                                      : status == "rejected"
                                          ? Colors.red
                                          : Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 10),

                      if (status == "pending")
                        Row(
                          children: [

                            ElevatedButton(
                              onPressed: () {
                                updateStatus(booking.id, "accepted");
                              },
                              child: const Text("Accept"),
                            ),

                            const SizedBox(width: 10),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                updateStatus(booking.id, "rejected");
                              },
                              child: const Text("Reject"),
                            ),
                          ],
                        ),

                      const SizedBox(height: 10),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CenterBookingDetailPage(
                                bookingId: booking.id,
                                bookingData: data,
                              ),
                            ),
                          );
                        },
                        child: const Text("View Details"),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}