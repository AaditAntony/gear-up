import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServiceCenterFormPage extends StatefulWidget {
  const ServiceCenterFormPage({super.key});

  @override
  State<ServiceCenterFormPage> createState() => _ServiceCenterFormPageState();
}

class _ServiceCenterFormPageState extends State<ServiceCenterFormPage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Uint8List? image1Bytes;
  Uint8List? image2Bytes;

  String? image1Base64;
  String? image2Base64;

  bool isLoading = false;

  Future<void> pickImage(int imageNumber) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile == null) return;

    Uint8List bytes = await pickedFile.readAsBytes();

    // 300 KB validation
    if (bytes.length > 300 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image must be under 300 KB")),
      );
      return;
    }

    String base64String = base64Encode(bytes);

    setState(() {
      if (imageNumber == 1) {
        image1Bytes = bytes;
        image1Base64 = base64String;
      } else {
        image2Bytes = bytes;
        image2Base64 = base64String;
      }
    });
  }

  Future<void> submitForm() async {
    if (phoneController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        image1Base64 == null ||
        image2Base64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields and upload images."),
        ),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Create service center details document
      await FirebaseFirestore.instance
          .collection('service_center_details')
          .doc(uid)
          .set({
            'phone': phoneController.text.trim(),
            'location': locationController.text.trim(),
            'description': descriptionController.text.trim(),
            'image1': image1Base64,
            'image2': image2Base64,
            'status': 'pending',
            'createdAt': Timestamp.now(),
          });

      // Update users collection
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'profileCompleted': true,
      });

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile submitted successfully.")),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      print("FORM ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Submission failed. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Complete Service Center Profile",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone",
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

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      image1Bytes != null
                          ? Image.memory(image1Bytes!, width: 100, height: 100)
                          : const Text("No Image 1"),
                      ElevatedButton(
                        onPressed: () => pickImage(1),
                        child: const Text("Upload Image 1"),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      image2Bytes != null
                          ? Image.memory(image2Bytes!, width: 100, height: 100)
                          : const Text("No Image 2"),
                      ElevatedButton(
                        onPressed: () => pickImage(2),
                        child: const Text("Upload Image 2"),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: isLoading ? null : submitForm,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
