import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'owner_dashboard.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController mileageController = TextEditingController();

  String? selectedFuelType;
  String? selectedDistrict;
  DateTime? lastServiceDate;

  bool isLoading = false;

  final List<String> districts = [
    "Thiruvananthapuram",
    "Kollam",
    "Pathanamthitta",
    "Alappuzha",
    "Kottayam",
    "Ernakulam",
    "Thrissur",
    "Palakkad",
    "Malappuram",
    "Kozhikode",
    "Wayanad",
    "Kannur",
    "Kasaragod",
  ];

  Future<void> pickServiceDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => lastServiceDate = picked);
    }
  }

  Future<void> submitProfile() async {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        addressController.text.isEmpty ||
        selectedDistrict == null ||
        vehicleNumberController.text.isEmpty ||
        brandController.text.isEmpty ||
        modelController.text.isEmpty ||
        yearController.text.isEmpty ||
        mileageController.text.isEmpty ||
        selectedFuelType == null ||
        lastServiceDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    try {
      setState(() => isLoading = true);

      String uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'district': selectedDistrict,
        'profileCompleted': true,
      });

      await FirebaseFirestore.instance.collection('vehicles').add({
        'userId': uid,
        'vehicleNumber': vehicleNumberController.text.trim(),
        'brand': brandController.text.trim(),
        'model': modelController.text.trim(),
        'fuelType': selectedFuelType,
        'year': int.parse(yearController.text.trim()),
        'mileage': int.parse(mileageController.text.trim()),
        'lastServiceDate': Timestamp.fromDate(lastServiceDate!),
        'createdAt': Timestamp.now(),
      });

      setState(() => isLoading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OwnerDashboard()),
      );
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong")));
    }
  }

  Widget sectionCard({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2563EB),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
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
          "Complete Your Profile",
          style: TextStyle(
            color: Color(0xFF2563EB),
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            /// PERSONAL
            sectionCard(
              title: "Personal Details",
              children: [
                _buildLabel("FULL NAME"),
                TextField(
                  controller: nameController,
                  decoration: _inputDecoration("Enter your name", Icons.person_rounded),
                ),
                const SizedBox(height: 20),
                _buildLabel("PHONE NUMBER"),
                TextField(
                  controller: phoneController,
                  decoration: _inputDecoration("Enter phone number", Icons.phone_rounded),
                ),
                const SizedBox(height: 20),
                _buildLabel("ADDRESS"),
                TextField(
                  controller: addressController,
                  decoration: _inputDecoration("Enter your address", Icons.location_on_rounded),
                ),
                const SizedBox(height: 20),
                _buildLabel("DISTRICT"),
                DropdownButtonFormField<String>(
                  value: selectedDistrict,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                  decoration: _inputDecoration("Select District", Icons.map_rounded),
                  items: districts
                      .map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))))
                      .toList(),
                  onChanged: (v) => setState(() => selectedDistrict = v),
                ),
              ],
            ),

            /// VEHICLE
            sectionCard(
              title: "Vehicle Details",
              children: [
                _buildLabel("VEHICLE NUMBER"),
                TextField(
                  controller: vehicleNumberController,
                  decoration: _inputDecoration("e.g. KL 01 AB 1234", Icons.numbers_rounded),
                ),
                const SizedBox(height: 20),
                _buildLabel("BRAND"),
                TextField(
                  controller: brandController,
                  decoration: _inputDecoration("e.g. Honda", Icons.directions_car_rounded),
                ),
                const SizedBox(height: 20),
                _buildLabel("MODEL"),
                TextField(
                  controller: modelController,
                  decoration: _inputDecoration("e.g. Activa", Icons.model_training_rounded),
                ),
                const SizedBox(height: 20),
                _buildLabel("FUEL TYPE"),
                DropdownButtonFormField<String>(
                  value: selectedFuelType,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                  decoration: _inputDecoration("Select Fuel Type", Icons.local_gas_station_rounded),
                  items: const [
                    DropdownMenuItem(value: "Petrol", child: Text("Petrol", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                    DropdownMenuItem(value: "Diesel", child: Text("Diesel", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                    DropdownMenuItem(value: "Electric", child: Text("Electric", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                    DropdownMenuItem(value: "Hybrid", child: Text("Hybrid", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                  ],
                  onChanged: (v) => setState(() => selectedFuelType = v),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("YEAR"),
                          TextField(
                            controller: yearController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration("Year", Icons.calendar_month_rounded),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("MILEAGE"),
                          TextField(
                            controller: mileageController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration("Km", Icons.speed_rounded),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildLabel("LAST SERVICE DATE"),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                      foregroundColor: const Color(0xFF2563EB),
                    ),
                    onPressed: pickServiceDate,
                    icon: const Icon(Icons.event_rounded, color: Color(0xFF2563EB), size: 20),
                    label: Text(
                      lastServiceDate == null
                          ? "Select Date"
                          : lastServiceDate.toString().split(" ")[0],
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),

            /// SUBMIT
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: isLoading ? null : submitProfile,
                child: isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : const Text(
                        "Complete Setup",
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 0.5),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: Color(0xFF94A3B8),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w500, fontSize: 14),
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
