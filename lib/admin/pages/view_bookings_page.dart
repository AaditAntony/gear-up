import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewBookingsPage extends StatelessWidget {
  const ViewBookingsPage({super.key});

  Color statusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.orange;
      case "accepted":
        return Colors.blue;
      case "in_progress":
        return Colors.purple;
      case "completed":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "All Bookings",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          "Monitor all service bookings across the platform",
          style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        ),

        const SizedBox(height: 25),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('bookings')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    "No bookings available.",
                    style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                  ),
                );
              }

              var bookings = snapshot.data!.docs;

              return ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  var booking = bookings[index];
                  var data = booking.data() as Map<String, dynamic>;

                  String status = data['status'];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// SERVICE NAME
                        Text(
                          data['categoryName'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),

                        const SizedBox(height: 12),

                        infoRow(
                          Icons.directions_car,
                          "Vehicle: ${data['vehicleNumber']}",
                        ),

                        infoRow(
                          Icons.business,
                          "Service Center: ${data['centerName']}",
                        ),

                        infoRow(
                          Icons.calendar_today,
                          "Date: ${data['bookingDate']}",
                        ),

                        infoRow(
                          Icons.access_time,
                          "Slot: ${data['bookingSlot']}",
                        ),

                        const SizedBox(height: 10),

                        /// STATUS BADGE
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor(status).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              color: statusColor(status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
