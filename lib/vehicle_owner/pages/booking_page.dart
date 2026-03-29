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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Schedule Service",
          style: TextStyle(
            color: Color(0xFF2563EB),
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2563EB), size: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE2E8F0),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              physics: const BouncingScrollPhysics(),
              children: [
                /// SERVICE SUMMARY CARD
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.build_circle_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.categoryName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Estimated Price: ₹${widget.price}",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                /// FORM SECTIONS
                _inputHeader("Choose Your Vehicle", 1),
                const SizedBox(height: 12),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('vehicles')
                      .where('userId', isEqualTo: uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      );
                    }

                    var vehicles = snapshot.data?.docs ?? [];

                    return DropdownButtonFormField<String>(
                      value: selectedVehicleId,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2563EB)),
                      decoration: _inputDecoration(Icons.directions_car_rounded, "Select vehicle from garage"),
                      items: vehicles.map((doc) {
                        return DropdownMenuItem(
                          value: doc.id,
                          onTap: () => selectedVehicleNumber = doc['vehicleNumber'],
                          child: Text(doc['vehicleNumber']),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedVehicleId = value),
                    );
                  },
                ),

                const SizedBox(height: 24),

                _inputHeader("Reporting Issue", 2),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedComplaint,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2563EB)),
                  decoration: _inputDecoration(Icons.report_problem_rounded, "What's wrong with the vehicle?"),
                  items: complaints.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c));
                  }).toList(),
                  onChanged: (value) => setState(() => selectedComplaint = value),
                ),

                const SizedBox(height: 24),

                _inputHeader("Schedule Date", 3),
                const SizedBox(height: 12),
                InkWell(
                  onTap: pickDate,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, color: Color(0xFF64748B), size: 18),
                        const SizedBox(width: 12),
                        Text(
                          selectedDate == null ? "Pick a preferred date" : selectedDate.toString().split(" ")[0],
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: selectedDate == null ? const Color(0xFF94A3B8) : const Color(0xFF2563EB),
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF64748B)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                _inputHeader("Availability Slot", 4),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: slots.map((slot) {
                    bool isSelected = selectedSlot == slot;
                    return InkWell(
                      onTap: () => setState(() => selectedSlot = slot),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF2563EB).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [],
                        ),
                        child: Text(
                          slot,
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF475569),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          /// BOTTOM ACTION
          Container(
            padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: isLoading ? null : createBooking,
                child: isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : const Text(
                        "Confirm Service Booking",
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 0.5),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputHeader(String text, int step) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            "$step",
            style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w900, fontSize: 11),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFF475569),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(IconData icon, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w500, fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 18),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
    );
  }
}
////