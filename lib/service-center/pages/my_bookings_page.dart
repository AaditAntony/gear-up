import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gear_up/service-center/widgets/service_theme.dart';
import 'package:gear_up/services/notification_service.dart';
import 'center_booking_detail_page.dart';

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  Future<void> updateStatus(String bookingId, String status) async {
    // Get booking data to find user ID
    var bookingDoc = await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .get();

    if (!bookingDoc.exists) return;
    var data = bookingDoc.data()!;
    String userId = data['userId'];

    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .update({'status': status});

    // Notify user
    String title = "Booking Status Updated";
    String message = "Your vehicle booking status is now $status.";
    if (status == "accepted") {
      title = "Booking Approved";
      message = "The service center has accepted your car's service request.";
    } else if (status == "rejected") {
      title = "Booking Rejected";
      message = "Sorry, your service request has been rejected by the center.";
    }

    await NotificationService.sendNotification(
      userId: userId,
      title: title,
      message: message,
      bookingId: bookingId,
    );
  }

  Color statusColor(String status) {
    switch (status) {
      case "pending":
        return ServiceTheme.warning;
      case "accepted":
        return ServiceTheme.info;
      case "completed":
        return ServiceTheme.success;
      case "rejected":
        return ServiceTheme.error;
      case "in_progress":
        return Colors.purpleAccent;
      default:
        return ServiceTheme.textSecondary;
    }
  }

  Widget statusBadge(String status) {
    Color color = statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String centerId = FirebaseAuth.instance.currentUser!.uid;

    return Container(
      color: Colors.white,
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 64, color: ServiceTheme.border.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    "No bookings scheduled", 
                    style: TextStyle(fontSize: 16, color: ServiceTheme.textSecondary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }

          var bookings = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(0),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              var booking = bookings[index];
              var data = booking.data() as Map<String, dynamic>;
              String status = data['status'];

              return Container(
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ServiceTheme.border.withOpacity(0.5)),
                  boxShadow: ServiceTheme.softShadow,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// HEADER BAR
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        color: ServiceTheme.background.withOpacity(0.5),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: ServiceTheme.accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.car_repair_rounded, color: ServiceTheme.accent, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                data['categoryName'],
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: ServiceTheme.textPrimary,
                                ),
                              ),
                            ),
                            statusBadge(status),
                          ],
                        ),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// GRID INFO
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("VEHICLE NUMBER", style: ServiceTheme.label),
                                      const SizedBox(height: 4),
                                      Text(
                                        data['vehicleNumber'],
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: ServiceTheme.textPrimary),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(width: 1, height: 30, color: ServiceTheme.border.withOpacity(0.5)),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("SCHEDULED FOR", style: ServiceTheme.label),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${data['bookingDate'].toString().split("T")[0]} · ${data['bookingSlot']}",
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: ServiceTheme.textPrimary),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                            const Divider(height: 1),
                            const SizedBox(height: 20),

                            const Text("CUSTOMER COMPLAINT", style: ServiceTheme.label),
                            const SizedBox(height: 6),
                            Text(
                              data['complaint'] ?? "General servicing and inspection required.",
                              style: const TextStyle(color: ServiceTheme.textSecondary, height: 1.4),
                            ),

                            const SizedBox(height: 24),

                            /// ACTIONS
                            Row(
                              children: [
                                if (status == "pending") ...[
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: ServiceTheme.success,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: () => updateStatus(booking.id, "accepted"),
                                      child: const Text("Accept Request", style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: ServiceTheme.error),
                                        foregroundColor: ServiceTheme.error,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: () => updateStatus(booking.id, "rejected"),
                                      child: const Text("Reject", style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ] else
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
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
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        decoration: BoxDecoration(
                                          color: ServiceTheme.accent.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: ServiceTheme.accent.withOpacity(0.1)),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.visibility_rounded, color: ServiceTheme.accent, size: 18),
                                            SizedBox(width: 8),
                                            Text(
                                              "View Full Details",
                                              style: TextStyle(
                                                color: ServiceTheme.accent,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
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
    );
  }
}
