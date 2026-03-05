import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  bool isLoading = true;

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
    }

    setState(() {
      isLoading = false;
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
        });

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
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: "Location",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: workingHoursController,
              decoration: const InputDecoration(
                labelText: "Working Hours",
                hintText: "Example: 9 AM - 6 PM",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              height: 45,
              child: ElevatedButton(
                onPressed: updateProfile,
                child: const Text("Update Profile"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
