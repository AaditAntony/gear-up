import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class EditCenterProfilePage extends StatefulWidget {
  const EditCenterProfilePage({super.key});

  @override
  State<EditCenterProfilePage> createState() => _EditCenterProfilePageState();
}

class _EditCenterProfilePageState extends State<EditCenterProfilePage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController workingHoursController = TextEditingController();

  String? selectedDistrict;

  bool isLoading = true;

  Uint8List? imageBytes;
  String? imageBase64;

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

  Future<void> loadProfile() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    var doc = await FirebaseFirestore.instance
        .collection('service_center_details')
        .doc(uid)
        .get();

    if (doc.exists) {
      var data = doc.data()!;

      phoneController.text = data['phone'] ?? "";
      locationController.text = data['location'] ?? "";
      descriptionController.text = data['description'] ?? "";
      workingHoursController.text = data['workingHours'] ?? "";

      selectedDistrict = data['district'];

      if (data['image'] != null) {
        imageBase64 = data['image'];
        imageBytes = base64Decode(data['image']);
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file == null) return;

    Uint8List bytes = await file.readAsBytes();

    setState(() {
      imageBytes = bytes;
      imageBase64 = base64Encode(bytes);
    });
  }

  Future<void> updateProfile() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('service_center_details')
        .doc(uid)
        .update({
          "phone": phoneController.text.trim(),
          "location": locationController.text.trim(),
          "description": descriptionController.text.trim(),
          "workingHours": workingHoursController.text.trim(),
          "district": selectedDistrict,
          "image": imageBase64,
        });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );

    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7ED),

      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: const Color(0xFFF97316),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: ListView(
          children: [
            /// PROFILE IMAGE
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.orange.withOpacity(.2),
                    backgroundImage: imageBytes != null
                        ? MemoryImage(imageBytes!)
                        : null,
                    child: imageBytes == null
                        ? const Icon(
                            Icons.store,
                            size: 40,
                            color: Colors.orange,
                          )
                        : null,
                  ),

                  const SizedBox(height: 10),

                  TextButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.upload),
                    label: const Text("Change Profile Image"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// PHONE
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: "Phone Number",
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// LOCATION
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: "Location",
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// DISTRICT
            DropdownButtonFormField<String>(
              value: selectedDistrict,
              decoration: InputDecoration(
                labelText: "District",
                prefixIcon: const Icon(Icons.map),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: districts.map((district) {
                return DropdownMenuItem(value: district, child: Text(district));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDistrict = value;
                });
              },
            ),

            const SizedBox(height: 15),

            /// DESCRIPTION
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Description",
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// WORKING HOURS
            TextField(
              controller: workingHoursController,
              decoration: InputDecoration(
                labelText: "Working Hours",
                hintText: "Example: 9 AM - 6 PM",
                prefixIcon: const Icon(Icons.access_time),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 25),

            /// UPDATE BUTTON
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: updateProfile,
                icon: const Icon(Icons.save),
                label: const Text(
                  "Update Profile",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
