import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingPage extends StatefulWidget {
  final String centerId;
  final String centerName;
  final String categoryId;
  final String categoryName;
  final double price;

  const BookingPage({
    super.key,
    required this.centerId,
    required this.centerName,
    required this.categoryId,
    required this.categoryName,
    required this.price,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? selectedDate;
  String? selectedSlot;
  String? selectedVehicleId;
  String? selectedVehicleNumber;
  String? selectedComplaint;
  bool isLoading = false;

  final List<String> slots = [
    "09:00 AM",
    "10:00 AM",
    "11:00 AM",
    "12:00 PM",
    "02:00 PM",
    "03:00 PM",
    "04:00 PM",
    "05:00 PM",
  ];

  final List<String> complaints = [
    "No Specific Issue",
    "Engine Noise",
    "Brake Noise",
    "Low Mileage",
    "Engine Overheating",
    "Battery Drain",
    "Starting Problem",
    "Vibration",
    "Oil Leakage",
  ];

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        selectedSlot = null;
      });
    }
  }

  Future<void> createBooking() async {
    if (selectedDate == null ||
        selectedSlot == null ||
        selectedVehicleId == null ||
        selectedComplaint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete booking details")),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      String uid = FirebaseAuth.instance.currentUser!.uid;
      String date = selectedDate!.toIso8601String();

      var centerCheck = await FirebaseFirestore.instance
          .collection('bookings')
          .where('centerId', isEqualTo: widget.centerId)
          .where('bookingDate', isEqualTo: date)
          .where('bookingSlot', isEqualTo: selectedSlot)
          .get();

      if (centerCheck.docs.isNotEmpty) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "This service center already has a booking in this slot",
            ),
          ),
        );
        return;
      }

      var userCheck = await FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: uid)
          .where('bookingDate', isEqualTo: date)
          .where('bookingSlot', isEqualTo: selectedSlot)
          .get();

      if (userCheck.docs.isNotEmpty) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "You already have another vehicle booked at this time",
            ),
          ),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('bookings').add({
        'userId': uid,
        'centerId': widget.centerId,
        'centerName': widget.centerName,
        'categoryId': widget.categoryId,
        'categoryName': widget.categoryName,
        'vehicleId': selectedVehicleId,
        'vehicleNumber': selectedVehicleNumber,
        'bookingDate': date,
        'bookingSlot': selectedSlot,
        'price': widget.price,
        'complaint': selectedComplaint,
        'status': 'pending',
        'createdAt': Timestamp.now(),
      });

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking created successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Booking failed")));
    }
  }

  Widget sectionTitle(String text, int step) {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: const Color(0xFF2563EB),
          child: Text(
            "$step",
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        title: const Text(
          "Book Service",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Column(
        children: [
          /// SCROLL
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                /// SERVICE SUMMARY
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.categoryName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "₹${widget.price}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// VEHICLE
                sectionTitle("Select Vehicle", 1),
                const SizedBox(height: 8),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('vehicles')
                      .where('userId', isEqualTo: uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    var vehicles = snapshot.data!.docs;

                    return DropdownButtonFormField<String>(
                      value: selectedVehicleId,
                      hint: const Text("Choose Vehicle"),
                      items: vehicles.map((doc) {
                        return DropdownMenuItem(
                          value: doc.id,
                          child: Text(doc['vehicleNumber']),
                          onTap: () {
                            selectedVehicleNumber = doc['vehicleNumber'];
                          },
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedVehicleId = value;
                        });
                      },
                    );
                  },
                ),

                const SizedBox(height: 20),

                /// ISSUE
                sectionTitle("Select Issue", 2),
                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  value: selectedComplaint,
                  hint: const Text("Choose Problem"),
                  items: complaints.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedComplaint = value;
                    });
                  },
                ),

                const SizedBox(height: 20),

                /// DATE
                sectionTitle("Select Date", 3),
                const SizedBox(height: 8),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: pickDate,
                  child: Text(
                    selectedDate == null
                        ? "Pick Date"
                        : selectedDate.toString().split(" ")[0],
                  ),
                ),

                const SizedBox(height: 20),

                /// SLOT
                sectionTitle("Select Time Slot", 4),
                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  children: slots.map((slot) {
                    bool isSelected = selectedSlot == slot;

                    return ChoiceChip(
                      label: Text(slot),

                      backgroundColor: Colors.white,
                      selected: isSelected,
                      selectedColor: const Color(0xFF2563EB),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                      onSelected: (_) {
                        setState(() {
                          selectedSlot = slot;
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          /// BUTTON
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,

            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: isLoading ? null : createBooking,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Confirm Booking"),
            ),
          ),
        ],
      ),
    );
  }
}
////