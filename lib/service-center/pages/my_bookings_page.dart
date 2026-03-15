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

    return Container(
      color: const Color(0xFFFFF7ED),

      child: StreamBuilder<QuerySnapshot>(
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

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: bookings.length,

                    itemBuilder: (context, index) {
                      var booking = bookings[index];
                      var data = booking.data() as Map<String, dynamic>;

                      String status = data['status'];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(18),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
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

                            const SizedBox(height: 18),

                            /// DETAILS
                            Container(
                              padding: const EdgeInsets.all(12),

                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(.05),
                                borderRadius: BorderRadius.circular(10),
                              ),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.directions_car,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text("Vehicle: ${data['vehicleNumber']}"),
                                    ],
                                  ),

                                  const SizedBox(height: 6),

                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Date: ${data['bookingDate'].toString().split("T")[0]}",
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 6),

                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 16),
                                      const SizedBox(width: 6),
                                      Text("Slot: ${data['bookingSlot']}"),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              "Complaint: ${data['complaint'] ?? "No complaint"}",
                              style: const TextStyle(color: Colors.grey),
                            ),

                            const SizedBox(height: 16),

                            /// ACCEPT / REJECT
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

                              child: ElevatedButton.icon(
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

                                icon: const Icon(Icons.visibility),
                                label: const Text("View Details"),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
