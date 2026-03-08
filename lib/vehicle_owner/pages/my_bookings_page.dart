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

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("My Bookings")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var bookings = snapshot.data!.docs;

          if (bookings.isEmpty) {
            return const Center(child: Text("No bookings yet"));
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              var booking = bookings[index];
              var data = booking.data() as Map<String, dynamic>;

              String status = data['status'];

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['centerName'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text("Service: ${data['categoryName']}"),
                      Text("Vehicle: ${data['vehicleNumber']}"),

                      Text(
                        "Date: ${data['bookingDate'].toString().split("T")[0]}",
                      ),

                      Text("Slot: ${data['bookingSlot']}"),

                      const SizedBox(height: 6),

                      Text(
                        "Status: ${status.toUpperCase()}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: status == "pending"
                              ? Colors.orange
                              : status == "accepted"
                              ? Colors.green
                              : status == "rejected"
                              ? Colors.red
                              : status == "cancelled"
                              ? Colors.grey
                              : Colors.blue,
                        ),
                      ),

                      /// RATE BUTTON
                      if (status == "completed")
                        ElevatedButton(
                          onPressed: () {
                            showRatingSheet(context, data);
                          },
                          child: const Text("Rate Service"),
                        ),

                      const SizedBox(height: 10),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  BookingDetailPage(bookingId: booking.id),
                            ),
                          );
                        },
                        child: const Text("View Details"),
                      ),

                      if (status == "pending")
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () {
                              cancelBooking(booking.id);
                            },
                            child: const Text("Cancel Booking"),
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

  /// ⭐ RATING BOTTOM SHEET
  void showRatingSheet(BuildContext context, Map<String, dynamic> bookingData) {
    int rating = 5;
    TextEditingController reviewController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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

                  /// ⭐ STAR RATING
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 35,
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
                    decoration: const InputDecoration(
                      labelText: "Write your review",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        /// SAVE RATING
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

                        /// UPDATE CENTER AVG RATING
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
