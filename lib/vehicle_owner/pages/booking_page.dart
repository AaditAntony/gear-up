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

  final TextEditingController complaintController = TextEditingController();

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
        selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete booking details")),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Check if slot already booked
      var query = await FirebaseFirestore.instance
          .collection('bookings')
          .where('centerId', isEqualTo: widget.centerId)
          .where('bookingDate', isEqualTo: selectedDate!.toIso8601String())
          .where('bookingSlot', isEqualTo: selectedSlot)
          .get();

      if (query.docs.isNotEmpty) {
        setState(() => isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("This slot is already booked")),
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

        'bookingDate': selectedDate!.toIso8601String(),
        'bookingSlot': selectedSlot,

        'price': widget.price,

        // NEW FIELD
        'complaint': complaintController.text.trim(),

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

            const Text(
              "Describe Issue (Optional)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: complaintController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText:
                    "Example: engine noise, brake issue, AC not cooling...",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: pickDate,
              child: Text(
                selectedDate == null
                    ? "Select Date"
                    : selectedDate.toString().split(" ")[0],
              ),
            ),

            const SizedBox(height: 20),

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
