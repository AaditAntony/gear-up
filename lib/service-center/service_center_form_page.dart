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
      backgroundColor: const Color(0xFFFFF7ED),

      appBar: AppBar(
        title: const Text("Service Center Registration"),
        backgroundColor: const Color(0xFFF97316),
      ),

      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 720,
            padding: const EdgeInsets.all(24),

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                const Text(
                  "Service Center Details",
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 30),

                _buildField(companyNameController, "Company Name", Icons.business),
                _buildField(ownerNameController, "Owner Name", Icons.person),
                _buildField(phoneController, "Primary Phone", Icons.phone),
                _buildField(alternatePhoneController, "Alternate Phone", Icons.phone_android),
                _buildField(locationController, "Street Address", Icons.location_on),

                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: selectedDistrict,
                  decoration: InputDecoration(
                    labelText: "District",
                    prefixIcon: const Icon(Icons.map),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
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

                _buildField(stateController, "State", Icons.public),
                _buildField(pincodeController, "Pincode", Icons.pin_drop),
                _buildField(gstController, "GST Number (Optional)", Icons.receipt),
                _buildField(experienceController, "Years of Experience", Icons.work),
                _buildField(descriptionController, "Company Description",
                    Icons.description, maxLines: 3),

                const SizedBox(height: 30),

                const Text(
                  "Upload Documents",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [

                    _imageUploadCard(
                        "Business License",
                        image1Bytes,
                        () => pickImage(1)
                    ),

                    _imageUploadCard(
                        "Workshop Image",
                        image2Bytes,
                        () => pickImage(2)
                    ),

                  ],
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton.icon(

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF97316),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    onPressed: isLoading ? null : submitForm,

                    icon: const Icon(Icons.send),

                    label: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Submit Application",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
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
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        maxLines: maxLines,

        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _imageUploadCard(
      String title,
      Uint8List? image,
      VoidCallback onTap,
      ) {

    return Column(
      children: [

        Container(
          width: 140,
          height: 140,

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade200,
          ),

          child: image != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(image, fit: BoxFit.cover),
                )
              : const Icon(Icons.image, size: 50, color: Colors.grey),
        ),

        const SizedBox(height: 10),

        Text(title),

        const SizedBox(height: 8),

        ElevatedButton.icon(

          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF97316),
            foregroundColor: Colors.white,
          ),

          onPressed: onTap,

          icon: const Icon(Icons.upload),
          label: const Text("Upload"),
        ),
      ],
    );
  }
}