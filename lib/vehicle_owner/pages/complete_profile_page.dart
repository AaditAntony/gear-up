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
  // Profile Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Vehicle Controllers
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController yearController = TextEditingController();

  String? selectedFuelType;
  String? selectedDistrict;

  bool isLoading = false;

  Future<void> submitProfile() async {
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        selectedDistrict == null ||
        vehicleNumberController.text.trim().isEmpty ||
        brandController.text.trim().isEmpty ||
        modelController.text.trim().isEmpty ||
        yearController.text.trim().isEmpty ||
        selectedFuelType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields.")),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Save user profile
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'district': selectedDistrict,
        'profileCompleted': true,
      });

      // Add first vehicle
      await FirebaseFirestore.instance.collection('vehicles').add({
        'userId': uid,
        'vehicleNumber': vehicleNumberController.text.trim(),
        'brand': brandController.text.trim(),
        'model': modelController.text.trim(),
        'fuelType': selectedFuelType,
        'year': yearController.text.trim(),
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
      ).showSnackBar(const SnackBar(content: Text("Something went wrong.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Profile")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            const Text(
              "Personal Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Address",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: selectedDistrict,
              decoration: const InputDecoration(
                labelText: "District",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Thiruvananthapuram",
                  child: Text("Thiruvananthapuram"),
                ),
                DropdownMenuItem(value: "Kollam", child: Text("Kollam")),
                DropdownMenuItem(
                  value: "Pathanamthitta",
                  child: Text("Pathanamthitta"),
                ),
                DropdownMenuItem(value: "Alappuzha", child: Text("Alappuzha")),
                DropdownMenuItem(value: "Kottayam", child: Text("Kottayam")),
                DropdownMenuItem(value: "Ernakulam", child: Text("Ernakulam")),
                DropdownMenuItem(value: "Thrissur", child: Text("Thrissur")),
                DropdownMenuItem(value: "Palakkad", child: Text("Palakkad")),
                DropdownMenuItem(
                  value: "Malappuram",
                  child: Text("Malappuram"),
                ),
                DropdownMenuItem(value: "Kozhikode", child: Text("Kozhikode")),
                DropdownMenuItem(value: "Wayanad", child: Text("Wayanad")),
                DropdownMenuItem(value: "Kannur", child: Text("Kannur")),
                DropdownMenuItem(value: "Kasaragod", child: Text("Kasaragod")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedDistrict = value;
                });
              },
            ),

            const SizedBox(height: 25),

            const Text(
              "Add Your Vehicle (Minimum 1 Required)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: vehicleNumberController,
              decoration: const InputDecoration(
                labelText: "Vehicle Number",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: brandController,
              decoration: const InputDecoration(
                labelText: "Brand",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: modelController,
              decoration: const InputDecoration(
                labelText: "Model",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: selectedFuelType,
              decoration: const InputDecoration(
                labelText: "Fuel Type",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "Petrol", child: Text("Petrol")),
                DropdownMenuItem(value: "Diesel", child: Text("Diesel")),
                DropdownMenuItem(value: "Electric", child: Text("Electric")),
                DropdownMenuItem(value: "Hybrid", child: Text("Hybrid")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedFuelType = value;
                });
              },
            ),

            const SizedBox(height: 10),

            TextField(
              controller: yearController,
              decoration: const InputDecoration(
                labelText: "Manufacturing Year",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: isLoading ? null : submitProfile,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Save Profile"),
            ),
          ],
        ),
      ),
    );
  }
}
