import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingDetailPage extends StatelessWidget {
  final String bookingId;

  const BookingDetailPage({super.key, required this.bookingId});

  Color statusColor(String status) {
    switch (status) {
      case "completed":
        return Colors.green;
      case "in_progress":
        return Colors.orange;
      case "pending":
        return Colors.blue;
      case "cancelled":
        return Colors.grey;
      case "rejected":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget statusBadge(String status) {
    Color color = statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        title: const Text(
          "Booking Details",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

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

          return Column(
            children: [
              /// SCROLLABLE CONTENT
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    /// HEADER CARD
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
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
                          /// TITLE + STATUS
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  data['centerName'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              statusBadge(data['status']),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Text("Service: ${data['categoryName']}"),
                          Text("Vehicle: ${data['vehicleNumber']}"),

                          const SizedBox(height: 6),

                          Text(
                            "Date: ${data['bookingDate'].toString().split("T")[0]}",
                          ),
                          Text("Slot: ${data['bookingSlot']}"),

                          const SizedBox(height: 10),

                          Text(
                            "Complaint: ${data['complaint'] ?? "No complaint"}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// SECTION TITLE
                    const Text(
                      "Service Progress",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// TIMELINE
                    updates.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(child: Text("No updates yet")),
                          )
                        : Column(
                            children: List.generate(updates.length, (index) {
                              var update = updates[index];

                              Color color = statusColor(
                                update["status"] ?? "pending",
                              );

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// DOT + LINE
                                  Column(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),

                                      if (index != updates.length - 1)
                                        Container(
                                          width: 2,
                                          height: 50,
                                          color: Colors.grey.shade300,
                                        ),
                                    ],
                                  ),

                                  const SizedBox(width: 12),

                                  /// CONTENT
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 6,
                                            color: Colors.black.withOpacity(
                                              .04,
                                            ),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            update["title"],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          const SizedBox(height: 4),

                                          Text(update["description"]),

                                          const SizedBox(height: 6),

                                          Text(
                                            update["status"]
                                                .toString()
                                                .toUpperCase(),
                                            style: TextStyle(
                                              color: color,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
////