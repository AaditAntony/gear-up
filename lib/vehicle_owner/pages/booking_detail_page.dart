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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Booking Timeline",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE2E8F0),
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('bookings').doc(bookingId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Booking not found."));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          List updates = data["serviceUpdates"] ?? [];
          String status = data['status'] ?? "pending";

          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            physics: const BouncingScrollPhysics(),
            children: [
              /// STATUS HEADER CARD
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['centerName'] ?? "Service Center",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1E293B),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Booking ID: #${bookingId.substring(0, 8).toUpperCase()}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        statusBadge(status),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 24),
                    _detailRow(Icons.build_circle_rounded, "Service Type", data['categoryName'] ?? "General"),
                    const SizedBox(height: 12),
                    _detailRow(Icons.directions_car_rounded, "Vehicle", data['vehicleNumber'] ?? "N/A"),
                    const SizedBox(height: 12),
                    _detailRow(Icons.calendar_today_rounded, "Date & Time",
                        "${data['bookingDate'].toString().split("T")[0]} • ${data['bookingSlot']}"),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              /// SECTION TITLE
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Service Progress",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// TIMELINE
              updates.isEmpty
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.query_builder_rounded, size: 40, color: const Color(0xFFCBD5E1)),
                          const SizedBox(height: 16),
                          const Text(
                            "Waiting for updates from center...",
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: List.generate(updates.length, (index) {
                        var update = updates[index];
                        String uStatus = update["status"] ?? "pending";
                        Color color = statusColor(uStatus);
                        bool isLast = index == updates.length - 1;

                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// DOT + LINE
                              Column(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: color, width: 3),
                                    ),
                                  ),
                                  if (!isLast)
                                    Expanded(
                                      child: Container(
                                        width: 2,
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                ],
                              ),

                              const SizedBox(width: 20),

                              /// CONTENT
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.02),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                      border: Border.all(color: const Color(0xFFF1F5F9)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              update["title"] ?? "Update",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 15,
                                                color: Color(0xFF1E293B),
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                            Text(
                                              uStatus.toUpperCase(),
                                              style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 10,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          update["description"] ?? "",
                                          style: const TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 13,
                                            height: 1.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),

              if (data['complaint'] != null && data['complaint'].isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  "Reported Complaint",
                  style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E293B), fontSize: 14),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    data['complaint'],
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.5),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 12),
        Text(
          "$label:",
          style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w700, fontSize: 13),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
////