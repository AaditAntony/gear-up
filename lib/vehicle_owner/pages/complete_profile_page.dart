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

  InputDecoration inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget sectionCard({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(.05)),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        title: const Text(
          "Complete Profile",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            /// PERSONAL
            sectionCard(
              title: "Personal Details",
              children: [
                TextField(
                  controller: nameController,
                  decoration: inputStyle("Full Name"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  decoration: inputStyle("Phone"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addressController,
                  decoration: inputStyle("Address"),
                ),
                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: selectedDistrict,
                  decoration: inputStyle("District"),
                  items: districts
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedDistrict = v),
                ),
              ],
            ),

            /// VEHICLE
            sectionCard(
              title: "Vehicle Details",
              children: [
                TextField(
                  controller: vehicleNumberController,
                  decoration: inputStyle("Vehicle Number"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: brandController,
                  decoration: inputStyle("Brand"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: modelController,
                  decoration: inputStyle("Model"),
                ),
                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: selectedFuelType,
                  decoration: inputStyle("Fuel Type"),
                  items: const [
                    DropdownMenuItem(value: "Petrol", child: Text("Petrol")),
                    DropdownMenuItem(value: "Diesel", child: Text("Diesel")),
                    DropdownMenuItem(
                      value: "Electric",
                      child: Text("Electric"),
                    ),
                    DropdownMenuItem(value: "Hybrid", child: Text("Hybrid")),
                  ],
                  onChanged: (v) => setState(() => selectedFuelType = v),
                ),

                const SizedBox(height: 10),
                TextField(
                  controller: yearController,
                  keyboardType: TextInputType.number,
                  decoration: inputStyle("Year"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: mileageController,
                  keyboardType: TextInputType.number,
                  decoration: inputStyle("Mileage"),
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: pickServiceDate,
                  child: Text(
                    lastServiceDate == null
                        ? "Select Last Service Date"
                        : lastServiceDate.toString().split(" ")[0],
                  ),
                ),
              ],
            ),

            /// SUBMIT
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isLoading ? null : submitProfile,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Profile"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
