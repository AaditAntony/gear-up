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

  Widget infoItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: Color(0xFF94A3B8),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFF3B82F6)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// PAGE HEADER
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 40, 40, 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Service Logistics",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                      letterSpacing: -1.0,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Real-time monitoring of all platform service requests.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
                  ],
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Icon(Icons.tune_rounded, color: Color(0xFF1E293B)),
              ),
            ],
          ),
        ),

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
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20),
                          ],
                        ),
                        child: Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "No dynamic records found.",
                        style: TextStyle(fontSize: 16, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }

              var bookings = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                physics: const BouncingScrollPhysics(),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  var booking = bookings[index];
                  var data = booking.data() as Map<String, dynamic>;
                  String status = data['status'] ?? "pending";

                  return Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Column(
                      children: [
                        /// TOP STRIP
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: statusColor(status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.engineering_rounded,
                                  color: statusColor(status),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['categoryName'] ?? "N/A",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF1E293B),
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    Text(
                                      "ID: ${booking.id.substring(0, 8).toUpperCase()}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF94A3B8),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _statusBadge(status),
                            ],
                          ),
                        ),

                        const Divider(height: 1, color: Color(0xFFF1F5F9)),

                        /// DATA SECTION (CLEANER SPACING)
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(child: infoItem(Icons.directions_car_rounded, "Vehicle", data['vehicleNumber'] ?? "N/A")),
                                  const SizedBox(width: 24),
                                  Expanded(child: infoItem(Icons.business_rounded, "Center", data['centerName'] ?? "N/A")),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(child: infoItem(Icons.calendar_today_rounded, "Booking Date", data['bookingDate'] ?? "N/A")),
                                  const SizedBox(width: 24),
                                  Expanded(child: infoItem(Icons.access_time_rounded, "Time Slot", data['bookingSlot'] ?? "N/A")),
                                ],
                              ),
                            ],
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

  Widget _statusBadge(String status) {
    Color color = statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 10,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}