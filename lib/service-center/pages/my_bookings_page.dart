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

  Color statusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.orange;
      case "accepted":
        return Colors.green;
      case "completed":
        return Colors.blue;
      case "rejected":
        return Colors.red;
      case "in_progress":
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget statusBadge(String status) {
    Color color = statusColor(status);

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

  @override
  Widget build(BuildContext context) {
    String centerId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7ED),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('centerId', isEqualTo: centerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No bookings yet", style: TextStyle(fontSize: 16)),
            );
          }

          var bookings = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              var booking = bookings[index];
              var data = booking.data() as Map<String, dynamic>;

              String status = data['status'];

              return Container(
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.black.withOpacity(.05),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.directions_car,
                            color: Colors.orange,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            data['categoryName'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        statusBadge(status),
                      ],
                    ),

                    const SizedBox(height: 15),

                    /// DETAILS
                    Text("Vehicle: ${data['vehicleNumber']}"),
                    Text(
                      "Date: ${data['bookingDate'].toString().split("T")[0]}",
                    ),
                    Text("Slot: ${data['bookingSlot']}"),

                    const SizedBox(height: 8),

                    Text(
                      "Complaint: ${data['complaint'] ?? "No complaint"}",
                      style: const TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 16),

                    /// ACTION BUTTONS
                    if (status == "pending")
                      Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              updateStatus(booking.id, "accepted");
                            },
                            icon: const Icon(Icons.check),
                            label: const Text("Accept"),
                          ),

                          const SizedBox(width: 10),

                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              updateStatus(booking.id, "rejected");
                            },
                            icon: const Icon(Icons.close),
                            label: const Text("Reject"),
                          ),
                        ],
                      ),

                    const SizedBox(height: 12),

                    /// VIEW DETAILS
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF97316),
                          foregroundColor: Colors.white,
                        ),
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
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
