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

  /// STRUCTURED COMPLAINT LIST

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

      /// CENTER SLOT CHECK

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

      /// USER SLOT CHECK

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

      /// CREATE BOOKING

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

        /// STRUCTURED COMPLAINT
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

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Book Service")),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              widget.categoryName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text("Price: ₹${widget.price}"),

            const SizedBox(height: 20),

            /// VEHICLE SELECT
            const Text(
              "Select Vehicle",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

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

            /// COMPLAINT SELECT
            const Text(
              "Select Issue",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

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
            ElevatedButton(
              onPressed: pickDate,
              child: Text(
                selectedDate == null
                    ? "Select Date"
                    : selectedDate.toString().split(" ")[0],
              ),
            ),

            const SizedBox(height: 20),

            /// SLOT
            const Text(
              "Select Time Slot",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            Wrap(
              spacing: 10,

              children: slots.map((slot) {
                bool isSelected = selectedSlot == slot;

                return ChoiceChip(
                  label: Text(slot),

                  selected: isSelected,

                  onSelected: (_) {
                    setState(() {
                      selectedSlot = slot;
                    });
                  },
                );
              }).toList(),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: isLoading ? null : createBooking,

                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Confirm Booking"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
