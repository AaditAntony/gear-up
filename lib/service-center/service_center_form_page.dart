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

  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController alternatePhoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? selectedDistrict;

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
    "Kasaragod"
  ];

  Uint8List? image1Bytes;
  Uint8List? image2Bytes;

  String? image1Base64;
  String? image2Base64;

  bool isLoading = false;

  Future<void> pickImage(int imageNumber) async {

    final picker = ImagePicker();

    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    Uint8List bytes = await pickedFile.readAsBytes();

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

    if (companyNameController.text.trim().isEmpty ||
        ownerNameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        selectedDistrict == null ||
        stateController.text.trim().isEmpty ||
        pincodeController.text.trim().isEmpty ||
        experienceController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        image1Base64 == null ||
        image2Base64 == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields.")),
      );
      return;
    }

    try {

      setState(() => isLoading = true);

      String uid = FirebaseAuth.instance.currentUser!.uid;
      String email = FirebaseAuth.instance.currentUser!.email ?? "";

      await FirebaseFirestore.instance
          .collection('service_center_details')
          .doc(uid)
          .set({

        'companyName': companyNameController.text.trim(),
        'ownerName': ownerNameController.text.trim(),
        'email': email,
        'phone': phoneController.text.trim(),
        'alternatePhone': alternatePhoneController.text.trim(),
        'location': locationController.text.trim(),
        'district': selectedDistrict,
        'state': stateController.text.trim(),
        'pincode': pincodeController.text.trim(),
        'gstNumber': gstController.text.trim(),
        'experienceYears': experienceController.text.trim(),
        'description': descriptionController.text.trim(),
        'image1': image1Base64,
        'image2': image2Base64,
        'status': 'pending',
        'createdAt': Timestamp.now(),
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({
        'profileCompleted': true,
      });

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Application submitted successfully.")),
      );

      Navigator.pop(context);

    } catch (e) {

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Submission failed.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 700,
            padding: const EdgeInsets.all(24),

            child: Column(

              children: [

                const Text(
                  "Service Center Registration Details",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 30),

                _buildField(companyNameController, "Company Name"),
                _buildField(ownerNameController, "Owner Name"),
                _buildField(phoneController, "Primary Phone"),
                _buildField(alternatePhoneController, "Alternate Phone"),
                _buildField(locationController, "Street Address"),

                const SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  value: selectedDistrict,
                  decoration: const InputDecoration(
                    labelText: "District",
                    border: OutlineInputBorder(),
                  ),
                  items: districts.map((district) {
                    return DropdownMenuItem(
                      value: district,
                      child: Text(district),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDistrict = value;
                    });
                  },
                ),

                const SizedBox(height: 15),

                _buildField(stateController, "State"),
                _buildField(pincodeController, "Pincode"),
                _buildField(gstController, "GST Number (Optional)"),
                _buildField(experienceController, "Years of Experience"),
                _buildField(descriptionController, "Company Description",
                    maxLines: 3),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [

                    Column(
                      children: [
                        image1Bytes != null
                            ? Image.memory(image1Bytes!, width: 120, height: 120)
                            : const Text("Business License"),
                        ElevatedButton(
                          onPressed: () => pickImage(1),
                          child: const Text("Upload License"),
                        ),
                      ],
                    ),

                    Column(
                      children: [
                        image2Bytes != null
                            ? Image.memory(image2Bytes!, width: 120, height: 120)
                            : const Text("Workshop Image"),
                        ElevatedButton(
                          onPressed: () => pickImage(2),
                          child: const Text("Upload Workshop"),
                        ),
                      ],
                    ),

                  ],
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: isLoading ? null : submitForm,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Submit Application"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}