import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gear_up/vehicle_owner/pages/booking_detail_page.dart';

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  Future<void> cancelBooking(String bookingId) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .update({'status': 'cancelled'});
  }

  Color statusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.orange;
      case "accepted":
        return Colors.green;
      case "rejected":
        return Colors.red;
      case "cancelled":
        return Colors.grey;
      case "completed":
        return Colors.blue;
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
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// PAGE HEADER
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Service Bookings",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2563EB),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Track and manage your vehicle service history",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('bookings')
                .where('userId', isEqualTo: uid)
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
                      Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text(
                        "No bookings found.",
                        style: TextStyle(fontSize: 16, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                );
              }

              var bookings = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                itemCount: bookings.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  var booking = bookings[index];
                  var data = booking.data() as Map<String, dynamic>;
                  String status = data['status'];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
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
                      border: Border.all(color: const Color(0xFFE2E8F0).withOpacity(0.5)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// CARD HEADER
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.store_rounded,
                                  color: Color(0xFF2563EB),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['centerName'] ?? "Service Center",
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF2563EB),
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      data['categoryName'] ?? "General Service",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              statusBadge(status),
                            ],
                          ),

                          const SizedBox(height: 20),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          const SizedBox(height: 20),

                          /// BOOKING INFO GRID
                          Row(
                            children: [
                              _buildInfoItem(Icons.directions_car_rounded, data['vehicleNumber'] ?? "N/A"),
                              const SizedBox(width: 16),
                              _buildInfoItem(Icons.event_available_rounded, data['bookingDate'].toString().split("T")[0]),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildInfoItem(Icons.access_time_rounded, data['bookingSlot'] ?? "N/A"),
                            ],
                          ),

                          const SizedBox(height: 24),

                          /// ACTIONS
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BookingDetailPage(bookingId: booking.id),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "View Details",
                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                  ),
                                ),
                              ),
                              if (status == "completed") ...[
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF59E0B),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    onPressed: () => showRatingSheet(context, data),
                                    child: const Text(
                                      "Rate Now",
                                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),

                          if (status == "pending")
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: SizedBox(
                                width: double.infinity,
                                child: TextButton(
                                  onPressed: () => cancelBooking(booking.id),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.redAccent,
                                    padding: const EdgeInsets.all(8),
                                  ),
                                  child: const Text(
                                    "Cancel Booking Request",
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
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

  Widget _buildInfoItem(IconData icon, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// ⭐ RATING SHEET (UI IMPROVED)
  void showRatingSheet(BuildContext context, Map<String, dynamic> bookingData) {
    int rating = 5;
    TextEditingController reviewController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),

      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Rate Service",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 34,
                        ),
                        onPressed: () {
                          setState(() {
                            rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: reviewController,
                    decoration: InputDecoration(
                      hintText: "Write your review...",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('ratings')
                            .add({
                              "centerId": bookingData['centerId'],
                              "centerName": bookingData['centerName'],
                              "serviceId": bookingData['categoryId'],
                              "serviceName": bookingData['categoryName'],
                              "userId": FirebaseAuth.instance.currentUser!.uid,
                              "rating": rating,
                              "review": reviewController.text.trim(),
                              "createdAt": Timestamp.now(),
                            });

                        var centerRef = FirebaseFirestore.instance
                            .collection('service_center_details')
                            .doc(bookingData['centerId']);

                        var centerDoc = await centerRef.get();

                        double currentAvg =
                            (centerDoc.data()?['avgRating'] ?? 0).toDouble();
                        int total = centerDoc.data()?['totalRatings'] ?? 0;

                        double newAvg =
                            ((currentAvg * total) + rating) / (total + 1);

                        await centerRef.update({
                          "avgRating": newAvg,
                          "totalRatings": total + 1,
                        });

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Rating submitted")),
                        );
                      },
                      child: const Text("Submit Rating"),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
////